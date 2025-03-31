import * as vscode from "vscode";
import { DartExtensionApi, SpawnedProcess } from "./interfaces";
import * as path from "path";
import { dartVMPath } from "./constants";

let chalk: any;
(async () => {
  chalk = new (await import("chalk")).Chalk({ level: 1 });
})();

export class JasprServeProcess implements vscode.Disposable {
  constructor(private dartExtensionApi: DartExtensionApi) {}

  private _disposables: vscode.Disposable[] = [];

  private emitter: vscode.EventEmitter<string> =
    new vscode.EventEmitter<string>();
  private terminal: vscode.Terminal | undefined;
  private sessions: vscode.DebugSession[] = [];
  private process: SpawnedProcess | undefined;

  private status: "running" | "stopped" | "disposed" = "running";
  private folder: vscode.WorkspaceFolder | undefined;
  private randomId: number = 0;
  private runName: string = "";

  async start(
    context: vscode.ExtensionContext,
    folder: vscode.WorkspaceFolder | undefined,
    debugConfiguration: vscode.DebugConfiguration
  ): Promise<void> {
    const isInstalled = await this.install();
    if (!isInstalled) {
      return;
    }

    this.folder = folder;
    this.randomId = Math.floor(Math.random() * 1000000);
    this.runName = debugConfiguration.name ?? "Jaspr";

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
            }
          },
          open: () => resolve(terminal),
          close: () => this.dispose(),
        },
      });
    });

    this.terminal = await terminalReady;
    this.terminal.show();

    const pubExecution = {
      args: [
        "pub",
        "global",
        "run",
        "jaspr_cli:jaspr",
        "daemon",
        ...(debugConfiguration.args ?? []),
      ],
      executable: path.join(
        this.dartExtensionApi.workspaceContext.sdks.dart,
        dartVMPath
      ),
    };

    this.process = this.dartExtensionApi.safeToolSpawn(
      folder?.uri.fsPath,
      pubExecution.executable,
      pubExecution.args
    );
    this.process.stdout.setEncoding("utf8");
    this.process.stdout.on("data", (data: Buffer | string) => {
      this.handleData(data, false);
    });
    this.process.stdout.setEncoding("utf8");
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
      }
      this.stop();
    });
    this.process.on("exit", (code: any) => {
      console.log("exit", code);
    });

    this._disposables.push(
      vscode.debug.onDidStartDebugSession((session) => {
        if (session.configuration._processId !== this.randomId) {
          return;
        }
        this.sessions.push(session);
      })
    );
  }

  async install(): Promise<boolean> {
    const v = await this.dartExtensionApi.pubGlobal.installIfRequired({
      packageName: "jaspr",
      packageID: "jaspr_cli",
    });
    return v !== undefined;
  }

  async stop(): Promise<void> {
    this.process?.stdin.write('[{"method":"daemon.shutdown", "id": "0"}]\n');
    const sess = this.sessions;
    this.sessions = [];
    this.status = "stopped";
    for (const session of sess) {
      vscode.debug.stopDebugging(session);
    }
  }

  async dispose() {
    this.stop();

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
    let lines = str.trim().split("\n");
    for (let line of lines) {
      line = line.trim();
      if (line.length === 0) {
        continue;
      }

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

      this.handleEvent({ event: "daemon.log", params: { message: chalk.gray(line) } });
    }
  }

  handleEvent(event: any) {
    var eventName = event.event;
    var params = event.params;

    if (eventName === "daemon.log") {
      let log: string = params.message || "";
      log = log.replaceAll("\\033", "\x1b");

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