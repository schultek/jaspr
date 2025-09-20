import * as vscode from "vscode";

import { dartExtensionApi, DartProcess } from "../api";
import {
  checkJasprInstalled,
  checkJasprVersion,
} from "../helpers/install_helper";
import { spawn } from "child_process";
import { minimumJasprVersion } from "../constants";

export class JasprToolingDaemon implements vscode.Disposable {
  private _disposables: vscode.Disposable[] = [];

  private statusItem: vscode.LanguageStatusItem | undefined;
  private process: DartProcess | undefined;

  private _onDidRestart: vscode.EventEmitter<void> =
    new vscode.EventEmitter<void>();
  public readonly onDidRestart: vscode.Event<void> = this._onDidRestart.event;

  private _isDevMode: boolean = false;
  public jasprVersion: string | undefined;

  async start(context: vscode.ExtensionContext): Promise<void> {
    const isInstalled = await checkJasprInstalled();
    if (!isInstalled) {
      return;
    }

    this._isDevMode = context.extensionMode === vscode.ExtensionMode.Development;

    this._disposables.push(
      vscode.commands.registerCommand(
        "jaspr.restartToolingDaemon",
        async () => {
          await this._startProcess();
          if (this.process) {
            this._onDidRestart.fire();
          }
        }
      )
    );

    this.statusItem = vscode.languages.createLanguageStatusItem(
      "jaspr_tooling_daemon",
      {
        language: "dart",
        scheme: "file",
      }
    );
    this.statusItem.name = "Jaspr Tooling Daemon";

    await this._startProcess();
    this._isDevMode = false;
  }

  public setBusy(busy: boolean) {
    if (!this.statusItem) {
      return;
    }
    this.statusItem!.busy = busy;
  }

  async _startProcess() {
    this.statusItem!.text = "Starting Jaspr Tooling Daemon...";
    this.statusItem!.severity = vscode.LanguageStatusSeverity.Information;
    this.statusItem!.command = undefined;
    this.statusItem!.busy = true;

    this.process?.kill();

    this.jasprVersion = await checkJasprVersion();

    if (this._isDevMode) {
      this.process = spawn("jaspr", ["tooling-daemon"], {
        stdio: ["pipe", "pipe", "pipe"],
        shell: true,
      });
    } else {
      const args = [
        "pub",
        "global",
        "run",
        "jaspr_cli:jaspr",
        "tooling-daemon",
      ];

      this.process = await dartExtensionApi.sdk.startDart("", args);
    }

    // Give it a moment to start before marking it as not busy.
    await new Promise((resolve) => setTimeout(resolve, 500));

    this.statusItem!.busy = false;

    if (!this.process) {
      this.statusItem!.severity = vscode.LanguageStatusSeverity.Error;
      this.statusItem!.text = "Failed to start Jaspr Tooling Daemon";
      this.statusItem!.command = {
        title: "Restart",
        command: "jaspr.restartToolingDaemon",
      };
      return;
    }

    this.statusItem!.severity = vscode.LanguageStatusSeverity.Information;
    this.statusItem!.text = "Jaspr Tooling Daemon";
    this.statusItem!.command = {
      title: "Restart",
      command: "jaspr.restartToolingDaemon",
    };

    this.process.stdout.setEncoding("utf8");
    this.process.stdout.on("data", (data: Buffer | string) => {
      this.handleData(data, false);
    });
    this.process.stderr.setEncoding("utf8");
    this.process.stderr.on("data", (data: Buffer | string) => {
      this.handleData(data, true);
    });
    const p = this.process;
    this.process.on("close", (code: any) => {
      if (this.statusItem && code) {
        this.statusItem!.severity = vscode.LanguageStatusSeverity.Error;
        this.statusItem!.text = `Jaspr Tooling Daemon exited with code ${code}`;
        this.statusItem!.command = {
          title: "Restart",
          command: "jaspr.restartToolingDaemon",
        };
      }

      if (this.process === p) {
        this.process = undefined;
      }
    });
  }

  private _currentLine: string = "";

  handleData(data: Buffer | string, isError: boolean) {
    let str = data.toString();
    let lines = str.trim().split("\n");
    for (let line of lines) {
      line = line.trim();
      if (line.length === 0) {
        continue;
      }

      if (line.startsWith("[{")) {
        this._currentLine = line;
      } else if (this._currentLine.length > 0) {
        this._currentLine += line;
      } else if (this._isDevMode) {
        console.log("Tooling Daemon Log:", line);
      }
      if (this._currentLine.endsWith("}]")) {
        let event: any;
        let currentLine = this._currentLine;
        this._currentLine = "";
        try {
          const json = JSON.parse(currentLine);
          event = json[0];
        } catch (_) {}
        if (event && event.event) {
          this.handleEvent(event);
        } else if (event && event.id) {
          this.handleResponse(event);
        } else if (this._isDevMode) {
          console.log("Tooling Daemon Log:", currentLine);
        }
      }
    }
  }

  handleEvent(event: any) {
    var eventName = event.event;
    var params = event.params;

    if (this._eventListeners[eventName]) {
      try {
        this._eventListeners[eventName](params);
      } catch (e) {
        console.error(`Error in event listener for ${eventName}:`, e);
      }
    } else if (this._isDevMode) {
      if (eventName === "daemon.log") {
        console.log("Tooling Daemon Log:", params.message);
      } else {
        console.log("Tooling Daemon Event:", eventName, params);
      }
    }
  }

  handleResponse(response: any) {
    var id = response.id;
    var result = response.result;
    var error = response.error;

    if (this._isDevMode) {
      console.log("Tooling Daemon Response:", id, result, error);
    }
    if (this._responseListeners[id]) {
      try {
        this._responseListeners[id](result, error);
      } catch (e) {
        console.error(`Error in response listener for ${id}:`, e);
      }
    }
  }

  private _responseListeners: {
    [id: string]: (result: any, error?: any) => void;
  } = {};

  async sendMessage(
    method: string,
    params: any,
    timeout?: number
  ): Promise<any> {
    if (!this.process) {
      console.error("Tooling Daemon is not running");
      return null;
    }

    const id = Math.random().toString(36).substring(2, 15);

    const message = JSON.stringify([{ method, params, id: id }]) + "\n";
    this.process.stdin.write(message);

    return new Promise((resolve, reject) => {
      this._responseListeners[id] = (response: any, error?: any) => {
        delete this._responseListeners[id];
        if (error) {
          reject(error);
          return;
        }
        resolve(response);
      };

      if (timeout) {
        setTimeout(() => {
          if (this._responseListeners[id]) {
            delete this._responseListeners[id];
            reject(
              new Error(
                `Timeout waiting for response from tooling daemon. Please try again.`
              )
            );
          }
        }, timeout);
      }
    });
  }

  private _eventListeners: { [name: string]: (params: any) => void } = {};

  onEvent(name: string, callback: (params: any) => void) {
    this._eventListeners[name] = callback;
  }

  async dispose() {
    this.process?.kill();
    this.process = undefined;
    this._disposables.forEach((d) => d.dispose());
    this._disposables = [];
    this.statusItem?.dispose();
    this.statusItem = undefined;
  }
}
