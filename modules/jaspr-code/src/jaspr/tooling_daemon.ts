import * as vscode from "vscode";

import { dartExtensionApi, DartProcess } from "../api";
import { checkJasprInstalled } from "../helpers/install_helper";

export class JasprToolingDaemon implements vscode.Disposable {
  private _disposables: vscode.Disposable[] = [];

  private statusItem: vscode.LanguageStatusItem | undefined;
  private process: DartProcess | undefined;

  async start(context: vscode.ExtensionContext): Promise<void> {
    const isInstalled = await checkJasprInstalled();
    if (!isInstalled) {
      return;
    }

    this._disposables.push(
      vscode.commands.registerCommand("jaspr.restartToolingDaemon", () => {
        this._startProcess();
      })
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
  }

  async _startProcess() {
    this.statusItem!.text = "$(loading~spin) Starting Jaspr Tooling Daemon...";
    this.statusItem!.severity = vscode.LanguageStatusSeverity.Information;
    this.statusItem!.command = undefined;
    this.statusItem!.busy = true;

    const args = ["pub", "global", "run", "jaspr_cli:jaspr", "tooling-daemon"];

    this.process = await dartExtensionApi.sdk.startDart("", args);

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

    this.statusItem!.text = "Jaspr Tooling Daemon";

    this.process.stdout.setEncoding("utf8");
    this.process.stdout.on("data", (data: Buffer | string) => {
      this.handleData(data, false);
    });
    this.process.stderr.setEncoding("utf8");
    this.process.stderr.on("data", (data: Buffer | string) => {
      this.handleData(data, true);
    });
    this.process.on("close", (code: any) => {
      if (this.statusItem) {
        this.statusItem!.severity = vscode.LanguageStatusSeverity.Error;
        this.statusItem!.text = `Jaspr Tooling Daemon exited with code ${code}`;
        this.statusItem!.command = {
          title: "Restart",
          command: "jaspr.restartToolingDaemon",
        };
      }
    });
    this.process.on("exit", (code: any) => {
      console.log("exit", code);
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
      } else {
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
        } else {
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
    } else if (eventName === "daemon.log") {
      console.log("Tooling Daemon Log:", params.message);
    } else {
      console.log("Tooling Daemon Event:", eventName, params);
    }
  }

  sendMessage(method: string, params: any): void {
    if (!this.process) {
      console.error("Tooling Daemon is not running");
      return;
    }

    const message = JSON.stringify([{ method, params, id: "0" }]) + "\n";
    this.process.stdin.write(message);
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
