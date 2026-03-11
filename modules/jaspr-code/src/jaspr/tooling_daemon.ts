import * as vscode from "vscode";
import { WebSocket } from "ws";

import { dartExtensionApi, DartProcess } from "../api";
import {
  checkJasprInstalled,
  checkJasprVersion,
} from "../helpers/install_helper";
import { spawn } from "child_process";
import { runProcess } from "../helpers/process_helper";

export class JasprToolingDaemon implements vscode.Disposable {
  private _disposables: vscode.Disposable[] = [];

  private statusItem: vscode.LanguageStatusItem | undefined;
  private socket: WebSocket | undefined;

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

    this._isDevMode =
      context.extensionMode === vscode.ExtensionMode.Development;

    this._disposables.push(
      vscode.commands.registerCommand(
        "jaspr.restartToolingDaemon",
        async () => {
          if (this.socket) {
            await this.sendMessage("daemon.shutdown", {});
          }
          await this._startProcess();
          if (this.socket) {
            this._onDidRestart.fire();
          }
        },
      ),
    );

    this.statusItem = vscode.languages.createLanguageStatusItem(
      "jaspr_tooling_daemon",
      {
        language: "dart",
        scheme: "file",
      },
    );
    this.statusItem.name = "Jaspr Tooling Daemon";

    await this._startProcess();
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

    this.socket?.close();
    this.socket = undefined;

    this.jasprVersion = await checkJasprVersion();

    let process: DartProcess | undefined;

    if (this._isDevMode) {
      process = spawn("jaspr", ["tooling-daemon"], {
        stdio: ["ignore", "pipe", "pipe"],
        shell: true,
      }) as any;
    } else {
      const args = [
        "pub",
        "global",
        "run",
        "jaspr_cli:jaspr",
        "tooling-daemon",
      ];

      process = await dartExtensionApi.sdk.startDart("", args);
    }

    if (!process) {
      this.statusItem!.severity = vscode.LanguageStatusSeverity.Error;
      this.statusItem!.text = "Failed to start Jaspr Tooling Daemon";
      this.statusItem!.command = {
        title: "retry",
        command: "jaspr.restartToolingDaemon",
      };
      this.statusItem!.busy = false;
      return;
    }

    const result = await runProcess(process);

    var port: number | undefined;

    if (!result.exitCode) {
      const lines = result.stdout.split("\n");
      for (const line of lines) {
        if (line.startsWith("[{") && line.endsWith("}]")) {
          try {
            const msg = JSON.parse(line);
            if (msg[0] && msg[0].port) {
              port = msg[0].port;
              break;
            }
          } catch (e) {}
        }
      }
    }

    if (result.exitCode || !port) {
      console.error(
        "Failed to start Jaspr Tooling Daemon\n",
        result.stdout,
        result.stderr,
      );

      this.statusItem!.severity = vscode.LanguageStatusSeverity.Error;
      this.statusItem!.text = "Failed to start Jaspr Tooling Daemon";
      this.statusItem!.command = {
        title: "retry",
        command: "jaspr.restartToolingDaemon",
      };
      this.statusItem!.busy = false;
      return;
    }

    this.socket = new WebSocket(`ws://localhost:${port}`);

    await new Promise<void>((resolve, reject) => {
      this.socket!.on("open", () => resolve());
      this.socket!.on("error", (e) => reject(e));
    }).catch((err) => {
      console.error("Failed to connect to Jaspr Tooling Daemon:", err);
      this.socket = undefined;
    });

    if (!this.socket) {
      this.statusItem!.severity = vscode.LanguageStatusSeverity.Error;
      this.statusItem!.text = "Failed to connect to Jaspr Tooling Daemon";
      this.statusItem!.command = {
        title: "retry",
        command: "jaspr.restartToolingDaemon",
      };
      this.statusItem!.busy = false;
      return;
    }

    this.statusItem!.busy = false;
    this.statusItem!.severity = vscode.LanguageStatusSeverity.Information;
    this.statusItem!.text = "Jaspr Tooling Daemon";
    this.statusItem!.command = {
      title: "restart",
      command: "jaspr.restartToolingDaemon",
    };

    this.socket.on("message", (data) => {
      this.handleData(data.toString());
    });

    this.socket.on("close", () => {
      if (!this.socket) {
        return;
      }

      if (this.statusItem) {
        this.statusItem!.severity = vscode.LanguageStatusSeverity.Error;
        this.statusItem!.text = `Jaspr Tooling Daemon connection closed`;
        this.statusItem!.command = {
          title: "restart",
          command: "jaspr.restartToolingDaemon",
        };
      }
      this.socket = undefined;
    });
  }

  handleData(data: string) {
    try {
      const json = JSON.parse(data);
      const event = json[0];
      if (event && event.event) {
        this.handleEvent(event);
      } else if (event && event.id) {
        this.handleResponse(event);
      } else if (this._isDevMode) {
        console.log("Tooling Daemon Log:", data);
      }
    } catch (e) {
      if (this._isDevMode) {
        console.log("Tooling Daemon Log (raw):", data);
      }
    }
  }

  handleEvent(event: any) {
    var eventName = event.event;
    var params = event.params;
    
    if (this._isDevMode) {
      if (eventName === "daemon.log") {
        console.log("Tooling Daemon Log:", params.message);
      } else {
        console.log("Tooling Daemon Event:", eventName, params);
      }
    }

    if (this._eventListeners[eventName]) {
      try {
        this._eventListeners[eventName](params);
      } catch (e) {
        console.error(`Error in event listener for ${eventName}:`, e);
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
    timeout?: number,
  ): Promise<any> {
    if (!this.socket) {
      console.error("Tooling Daemon is not connected");
      return null;
    }

    const id = Math.random().toString(36).substring(2, 15);

    const message = JSON.stringify([{ method, params, id: id }]);
    this.socket.send(message);

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
                `Timeout waiting for response from tooling daemon. Please try again.`,
              ),
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
    this.socket?.close();
    this.socket = undefined;
    this._disposables.forEach((d) => d.dispose());
    this._disposables = [];
    this.statusItem?.dispose();
    this.statusItem = undefined;
  }
}
