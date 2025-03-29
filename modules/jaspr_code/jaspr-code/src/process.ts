import * as vscode from "vscode";
import { DartExtensionApi, SpawnedProcess } from "./interfaces";
import * as path from "path";
import { dartVMPath } from "./constants";

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
    folder: vscode.WorkspaceFolder | undefined,
    debugConfiguration: vscode.DebugConfiguration
  ): Promise<void> {
    const isInstalled = await this.install();
    if (!isInstalled) {
      return;
    }

    this.folder = folder;
    this.randomId = Math.floor(Math.random() * 1000000);
    this.runName = debugConfiguration.name ?? "Jaspr Serve";

    const terminalReady = new Promise<vscode.Terminal>((resolve) => {
      const terminal = vscode.window.createTerminal({
        name: "Jaspr",
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
    this.status = "stopped";

    this.process?.stdin.write('[{"method":"daemon.shutdown", "id": "0"}]\n');
    for (const session of this.sessions) {
      await vscode.debug.stopDebugging(session);
    }
    this.sessions = [];
  }

  async dispose() {
    this.stop();

    this.status = "disposed";
    this.process?.kill();
    this.process?.disconnect();
    this.process = undefined;
    this.terminal?.dispose();
    this.terminal = undefined;
    this.emitter.dispose();
    this._disposables.forEach((d) => d.dispose());
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
        try {
          const json = JSON.parse(line);
          const event = json[0];
          this.handleEvent(event);
          continue;
        } catch (_) {}
      }

      this.handleEvent({ event: "daemon.log", params: { message: line } });
    }
  }

  handleEvent(event: any) {
    var eventName = event.event;
    var params = event.params;

    if (eventName === "daemon.log") {
      const tag = params.tag;
      const level = params.level;

      if (
        tag === "SERVER" &&
        params.message.startsWith("The Dart VM service is listening on ")
      ) {
        var url = params.message.substring(
          "The Dart VM service is listening on ".length
        );
        this.attachDebugger("Server", url);
        return;
      }

      let message = params.message + "\r\n";
      if (level !== undefined) {
        message = `(${level}) ${message}`;
      }
      if (tag !== undefined) {
        message = `[${tag}] ${message}`;
      }
      this.emitter.fire(message);
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
    }

    this.emitter.fire(JSON.stringify(event) + "\r\n");
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
