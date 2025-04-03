import * as vscode from "vscode";
import { JasprServeProcess } from "./process";

export class JasprDebugConfigurationProvider
  implements vscode.DebugConfigurationProvider, vscode.Disposable
{
  constructor(private context: vscode.ExtensionContext, private dartExtensionApi: any) {}

  private _disposables: vscode.Disposable[] = [];

  dispose() {
    this._disposables.forEach((d) => d.dispose());
  }

  provideDebugConfigurations(
    folder: vscode.WorkspaceFolder | undefined,
    token?: vscode.CancellationToken
  ): vscode.ProviderResult<vscode.DebugConfiguration[]> {
    if (folder) {
      return [];
    }
    return [
      {
        name: "Jaspr",
        request: "launch",
        type: "jaspr",
        args: [],
      },
    ];
  }

  async resolveDebugConfiguration(
    folder: vscode.WorkspaceFolder | undefined,
    debugConfiguration: vscode.DebugConfiguration,
    token?: vscode.CancellationToken
  ): Promise<vscode.DebugConfiguration | undefined> {


    const process = new JasprServeProcess(this.dartExtensionApi);
    this._disposables.push(process);

    process.start(this.context, folder, debugConfiguration);

    return undefined;
  }
}
