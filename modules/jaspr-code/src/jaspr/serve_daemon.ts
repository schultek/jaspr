import * as vscode from "vscode";

import * as path from "path";
import { checkJasprInstalled } from "../helpers/install_helper";
import { SpawnedProcess, startJaspr } from "../helpers/process_helper";

let chalk: any;
(async () => {
  chalk = new (await import("chalk")).Chalk({ level: 1 });
})();

export class JasprServeDaemon implements vscode.Disposable {
  private _disposables: vscode.Disposable[] = [];

  private statusBarItem: vscode.StatusBarItem | undefined;
  private statusBarCloseItem: vscode.StatusBarItem | undefined;
  private displayStatus:
    | "starting"
    | "running"
    | "failed"
    | "stopped"
    | undefined;

  private emitter: vscode.EventEmitter<string> =
    new vscode.EventEmitter<string>();
  private terminal: vscode.Terminal | undefined;
  private sessions: vscode.DebugSession[] = [];
  private process: SpawnedProcess | undefined;

  private status: "running" | "stopped" | "disposed" = "running";
  private folder: vscode.WorkspaceFolder | undefined;
  private randomId: number = 0;
  private runName: string = "";

  private static _activeDaemons: Map<number, JasprServeDaemon> = new Map();
  public static activeDaemon: JasprServeDaemon | undefined;

  public static getDaemonByProcessId(
    processId: number
  ): JasprServeDaemon | undefined {
    return this._activeDaemons.get(processId);
  }

  public static getActiveDaemon(): JasprServeDaemon | undefined {
    if (this.activeDaemon && this.activeDaemon.status === "running") {
      return this.activeDaemon;
    }
    const activeSession = vscode.debug.activeDebugSession;
    if (activeSession?.configuration?._processId) {
      const daemon = this.getDaemonByProcessId(
        activeSession.configuration._processId
      );
      if (daemon && daemon.status === "running") {
        return daemon;
      }
    }
    for (const daemon of this._activeDaemons.values()) {
      if (daemon.status === "running") {
        return daemon;
      }
    }
    return undefined;
  }

  private nextRequestId: number = 1;
  private lastReloadTime: number = 0;
  private lastRestartTime: number = 0;

  async start(
    context: vscode.ExtensionContext,
    folder?: vscode.WorkspaceFolder,
    debugConfiguration?: vscode.DebugConfiguration
  ): Promise<void> {
    const isInstalled = await checkJasprInstalled();
    if (!isInstalled) {
      return;
    }

    this.folder = folder;
    this.randomId = Math.floor(Math.random() * 1000000);
    this.runName = debugConfiguration?.name ?? "Jaspr";

    JasprServeDaemon.activeDaemon = this;
    JasprServeDaemon._activeDaemons.set(this.randomId, this);
    void vscode.commands.executeCommand("setContext", "jaspr:isRunning", true);

    this.statusBarItem = await vscode.window.createStatusBarItem(
      vscode.StatusBarAlignment.Left,
      2
    );
    this.statusBarCloseItem = await vscode.window.createStatusBarItem(
      vscode.StatusBarAlignment.Left,
      1
    );

    this._disposables.push(
      vscode.commands.registerCommand(
        `jaspr.statusClicked.${this.randomId}`,
        () => {
          if (this.displayStatus === "stopped") {
            this.dispose();
          } else {
            this.terminal?.show();
          }
        }
      )
    );

    this._disposables.push(
      vscode.commands.registerCommand(
        `jaspr.closeClicked.${this.randomId}`,
        () => {
          this.dispose();
        }
      )
    );

    this.statusBarItem.name = "Jaspr Status";
    this.statusBarItem.text = "$(loading~spin) Starting Jaspr...";
    this.statusBarItem.command = `jaspr.statusClicked.${this.randomId}`;
    this.statusBarItem.tooltip = "Click to show the Jaspr terminal";

    this.statusBarCloseItem.name = "Close Jaspr";
    this.statusBarCloseItem.text = "$(debug-stop) Stop Jaspr";
    this.statusBarCloseItem.command = `jaspr.closeClicked.${this.randomId}`;
    this.statusBarCloseItem.tooltip = "Stop Jaspr";

    this.statusBarItem.show();
    this.displayStatus = "starting";

    await this._startJaspr(context, debugConfiguration);
  }

  async _startJaspr(
    context: vscode.ExtensionContext,
    debugConfiguration?: vscode.DebugConfiguration
  ) {
    await this._startTerminal(context);

    await this._startProcess(debugConfiguration);

    this._disposables.push(
      vscode.debug.onDidStartDebugSession((session) => {
        if (session.configuration._processId !== this.randomId) {
          return;
        }
        this.sessions.push(session);
        if (this.displayStatus === "starting") {
          this.statusBarItem!.text = "$(zap) Jaspr is running";
          this.statusBarCloseItem?.show();
          this.displayStatus = "running";
        }
      })
    );

    this._disposables.push(
      vscode.debug.onDidTerminateDebugSession((session) => {
        const index = this.sessions.indexOf(session);
        if (index !== -1) {
          this.sessions.splice(index, 1);
        }
      })
    );
  }

  async _startTerminal(context: vscode.ExtensionContext) {
    const terminalReady = new Promise<vscode.Terminal>((resolve) => {
      const terminal = vscode.window.createTerminal({
        name: "Jaspr",
        iconPath: vscode.Uri.file(
          context.asAbsolutePath("media/icons/jaspr.svg")
        ),
        pty: {
          onDidWrite: this.emitter.event,
          handleInput: (data: string) => {
            if (this.status === "disposed") {
              return;
            }
            if (this.status === "stopped") {
              this.dispose();
              return;
            }

            if (data.length === 1 && data.charCodeAt(0) === 3) {
              // Ctrl+C
              this.stop();
              return;
            }

            if (data === "r") {
              this.reload();
            } else if (data === "R") {
              this.restart();
            } else if (data === "q") {
              this.stop();
            }
          },
          open: () => resolve(terminal),
          close: () => this.dispose(),
        },
      });
    });

    this.terminal = await terminalReady;
    this.terminal.show();
  }

  async _startProcess(debugConfiguration?: vscode.DebugConfiguration) {
    const args = [
      "daemon",
      ...(debugConfiguration?.args ?? []),
    ];

    let folder = this.folder?.uri.fsPath;
    if (debugConfiguration?.cwd) {
      folder = path.resolve(folder ?? "", debugConfiguration.cwd);
    }

    this.process = startJaspr(args, folder ?? "");
    if (!this.process) {
      this.emitter.fire("Failed to start Jaspr process.\r\n");
      return;
    }
    this.process.stdout.setEncoding("utf8");
    this.process.stdout.on("data", (data: Buffer | string) => {
      this.handleData(data, false);
    });
    this.process.stderr.setEncoding("utf8");
    this.process.stderr.on("data", (data: Buffer | string) => {
      this.handleData(data, true);
    });
    this.process.on("close", (code: any) => {
      if (!code) {
        this.emitter.fire("Jaspr Serve exited successfully.\r\n");
        this.emitter.fire("Press any key to close the terminal.\r\n");
      } else {
        this.emitter.fire(`Jaspr Serve exited with code ${code}.\r\n`);
        this.emitter.fire("Press any key to close the terminal.\r\n");
        if (this.displayStatus === "starting" && this.status !== "stopped") {
          this.statusBarItem!.text = "$(warning) Jaspr failed to start";
          this.displayStatus = "failed";
          this.terminal?.show();
        }
      }
      if (this.displayStatus !== "stopped") {
        this.statusBarItem!.text = "$(check) Jaspr stopped (click to close)";
        this.statusBarItem!.tooltip = "Click to close Jaspr";
        this.displayStatus = "stopped";
      }
      this.stop();
    });
    this.process.on("exit", (code: any) => {
      console.log("exit", code);
    });
  }

  public reload(): void {
    const now = Date.now();
    if (now - this.lastReloadTime < 250) {
      return;
    }
    this.lastReloadTime = now;
    this.sendRequest("client.restart", { fullRestart: false });
  }

  public restart(): void {
    const now = Date.now();
    if (now - this.lastRestartTime < 250) {
      return;
    }
    this.lastRestartTime = now;
    this.sendRequest("client.restart", { fullRestart: true });
  }

  public sendRequest(method: string, params?: any): void {
    if (this.status !== "running" || !this.process) {
      return;
    }
    const id = `${++this.nextRequestId}`;
    const request = [{ method, params, id }];
    this.process.stdin.write(JSON.stringify(request) + "\n");
  }

  async stop(): Promise<void> {
    if (JasprServeDaemon.activeDaemon === this) {
      JasprServeDaemon.activeDaemon = undefined;
    }
    JasprServeDaemon._activeDaemons.delete(this.randomId);
    if (JasprServeDaemon._activeDaemons.size === 0) {
      void vscode.commands.executeCommand("setContext", "jaspr:isRunning", false);
    }
    this.process?.stdin.write('[{"method":"daemon.shutdown", "id": "0"}]\n');
    this.statusBarCloseItem?.hide();
    const sess = this.sessions;
    this.sessions = [];
    this.status = "stopped";
    for (const session of sess) {
      vscode.debug.stopDebugging(session);
    }
  }

  async dispose() {
    if (JasprServeDaemon.activeDaemon === this) {
      JasprServeDaemon.activeDaemon = undefined;
    }
    JasprServeDaemon._activeDaemons.delete(this.randomId);
    if (JasprServeDaemon._activeDaemons.size === 0) {
      void vscode.commands.executeCommand("setContext", "jaspr:isRunning", false);
    }
    this.stop();

    this.statusBarItem?.dispose();
    this.statusBarItem = undefined;
    this.process?.kill();
    this.process = undefined;
    this.terminal?.dispose();
    this.terminal = undefined;
    this.emitter.dispose();
    this._disposables.forEach((d) => d.dispose());
    this._disposables = [];
    this.status = "disposed";
  }

  handleData(data: Buffer | string, isError: boolean) {
    let str = data.toString();
    let lines = str.trimEnd().split("\n");
    for (let line of lines) {
      line = line.trimEnd();

      if (line.startsWith("[{") && line.endsWith("}]")) {
        let event: any;
        try {
          const json = JSON.parse(line);
          event = json[0];
        } catch (_) {}
        if (event) {
          this.handleEvent(event);
          continue;
        }
      }

      this.handleEvent({
        event: "daemon.log",
        params: { message: chalk.gray(line) },
      });
    }
  }

  handleEvent(event: any) {
    var eventName = event.event;
    var params = event.params;

    if (eventName === "daemon.log") {
      let log: string = params.message || "";
      log = log.replaceAll("\\033", "\x1b").split('\r\n').flatMap(line => line.split('\n')).join('\r\n');

      this.emitter.fire(log + "\r\n");
      return;
    }

    if (eventName === "client.debugPort") {
      this.attachDebugger("Client", params.wsUri);
      return;
    }
    if (eventName === "client.stop") {
      const session = this.sessions.find(
        (s) =>
          s.configuration._processId === this.randomId &&
          s.configuration._appId === params.appId
      );
      if (session !== undefined) {
        vscode.debug.stopDebugging(session);
      }
      return;
    }

    if (eventName === "server.started") {
      this.attachDebugger("Server", params.vmServiceUri);
      return;
    }

    //this.emitter.fire(JSON.stringify(event) + "\r\n");
  }

  attachDebugger(name: string, vmServiceUri: string) {
    if (
      this.sessions.find((s) => s.configuration.vmServiceUri === vmServiceUri)
    ) {
      return;
    }

    const debugConfig: vscode.DebugConfiguration = {
      name: name + " | " + this.runName,
      request: "attach",
      type: "dart",
      vmServiceUri: vmServiceUri,
      _processId: this.randomId,
    };

    vscode.debug.startDebugging(this.folder, debugConfig);
  }
}
