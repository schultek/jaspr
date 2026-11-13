import * as vscode from "vscode";

import * as path from "path";
import { JasprServeDaemon } from "./jaspr/serve_daemon";
import { findJasprProjectFolders, fsPath } from "./helpers/project_helper";

export class JasprDebugConfigurationProvider
  implements vscode.DebugConfigurationProvider, vscode.Disposable
{
  constructor(private context: vscode.ExtensionContext) {}

  private _disposables: vscode.Disposable[] = [];

  dispose() {
    this._disposables.forEach((d) => d.dispose());
  }

  async resolveDebugConfiguration(
    folder: vscode.WorkspaceFolder | undefined,
    debugConfiguration: vscode.DebugConfiguration,
    token?: vscode.CancellationToken
  ): Promise<vscode.DebugConfiguration | undefined> {
    const process = new JasprServeDaemon();
    this._disposables.push(process);

    process.start(this.context, folder, debugConfiguration);

    return undefined;
  }
}

export class InitialLaunchJsonDebugConfigProvider
  implements vscode.DebugConfigurationProvider
{
  public async provideDebugConfigurations(
    folder: vscode.WorkspaceFolder | undefined,
    token?: vscode.CancellationToken
  ): Promise<vscode.DebugConfiguration[]> {
    const results: vscode.DebugConfiguration[] = [];

    const projectFolders = await findJasprProjectFolders();
    const rootFolder = folder ? fsPath(folder.uri) : undefined;

    if (projectFolders.length) {
      for (const projectFolder of projectFolders) {
        const name = path.basename(projectFolder);
        // Compute cwd, using undefined instead of empty if rootFolder === projectFolder
        const cwd = rootFolder
          ? path.relative(rootFolder, projectFolder) || undefined
          : undefined;

        results.push({
          name,
          cwd,
          request: "launch",
          type: "jaspr",
        });
        results.push({
          name: `${name} (release mode)`,
          cwd,
          request: "launch",
          type: "jaspr",
          args: ["--release"],
        });
      }
    } else {
      results.push({
        name: "Jaspr",
        request: "launch",
        type: "jaspr",
      });
    }

    return results;
  }
}

export class DynamicDebugConfigProvider
  implements vscode.DebugConfigurationProvider
{
  public async provideDebugConfigurations(
    folder: vscode.WorkspaceFolder | undefined,
    token?: vscode.CancellationToken
  ): Promise<vscode.DebugConfiguration[]> {
    const results: vscode.DebugConfiguration[] = [];

    const rootFolder = folder ? fsPath(folder.uri) : undefined;
    const projectFolders = await findJasprProjectFolders();
    for (const projectFolder of projectFolders) {
      const name = path.basename(projectFolder);
      // Compute cwd, using undefined instead of empty if rootFolder === projectFolder
      const cwd = rootFolder
        ? path.relative(rootFolder, projectFolder) || undefined
        : undefined;

      results.push({
        name: `${name} (Jaspr)`,
        cwd,
        request: "launch",
        type: "jaspr",
      });
      results.push({
        name: `${name} (Jaspr release mode)`,
        cwd,
        request: "launch",
        type: "jaspr",
        args: ["--release"],
      });
    }
    return results;
  }
}

export class JasprDebugAdapterTrackerFactory
  implements vscode.DebugAdapterTrackerFactory
{
  createDebugAdapterTracker(
    session: vscode.DebugSession
  ): vscode.ProviderResult<vscode.DebugAdapterTracker> {
    const processId = session.configuration._processId;
    if (!processId) {
      return undefined;
    }
    const daemon = JasprServeDaemon.getDaemonByProcessId(processId);
    if (!daemon) {
      return undefined;
    }

    return {
      onWillReceiveMessage(message: any) {
        if (message?.type === "request") {
          if (message.command === "hotReload") {
            daemon.reload();
          } else if (
            message.command === "restart" ||
            message.command === "hotRestart" ||
            ((message.command === "disconnect" ||
              message.command === "terminate") &&
              Boolean(message.arguments?.restart))
          ) {
            daemon.restart();
          }
        }
      },
    };
  }
}
