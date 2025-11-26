import * as vscode from "vscode";
import { JasprToolingDaemon } from "./tooling_daemon";
import { findJasprProjectFolders } from "../helpers/project_helper";
import { join } from "path";

export type ScopeResults = Record<string, ScopeLibraryResult>;

export type ScopeLibraryResult = {
  components?: string[];
  clientScopeRoots?: ScopeTarget[];
  serverScopeRoots?: ScopeTarget[];
  invalidDependencies?: InvalidDependency[];
};

export type ScopeTarget = {
  path: string;
  name: string;
  line: number;
  character: number;
};

export type InvalidDependency = {
  uri: string;
  invalidOnClient?: DependencyTarget;
  invalidOnServer?: DependencyTarget;
};

export type DependencyTarget = {
  uri: string;
  target: string;
  line: number;
  character: number;
  length: number;
};

export class ScopesDomain implements vscode.Disposable {
  private toolingDaemon: JasprToolingDaemon;
  private diagnosticCollection: vscode.DiagnosticCollection;
  private workspaceSubscriptions: vscode.Disposable;
  private configurationSubscriptions: vscode.Disposable;
  private statusBarItem: vscode.StatusBarItem | undefined;

  private _onDidChangeScopes: vscode.EventEmitter<ScopeResults> =
    new vscode.EventEmitter<ScopeResults>();
  public readonly onDidChangeScopes: vscode.Event<ScopeResults> =
    this._onDidChangeScopes.event;

  private scopeResults: ScopeResults = {};

  constructor(toolingDaemon: JasprToolingDaemon) {
    this.toolingDaemon = toolingDaemon;
    this.diagnosticCollection =
      vscode.languages.createDiagnosticCollection("jaspr");
    this.registerFolders();
    this.workspaceSubscriptions = vscode.workspace.onDidChangeWorkspaceFolders(
      (_) => this.registerFolders()
    );
    this.toolingDaemon.onDidRestart(() => this.registerFolders());
    this.configurationSubscriptions = vscode.workspace.onDidChangeConfiguration(
      (_) => this.updateDiagnostics()
    );
  }

  private async registerFolders() {
    var folders = await findJasprProjectFolders();
    folders = folders.map((f) => join(f, "lib", 'main.dart'));

    this.statusBarItem?.dispose();
    this.statusBarItem = vscode.window.createStatusBarItem(
      vscode.StatusBarAlignment.Left,
      1
    );
    this.statusBarItem.text = `$(loading~spin) Analyzing Jaspr Scopes`;
    this.statusBarItem.command = "jaspr.action.showScopeHint";
    
    this.toolingDaemon.sendMessage("scopes.register", { folders: folders });
    this.toolingDaemon.onEvent("scopes.result", (results: ScopeResults) => {
      this.scopeResults = results;
      this._onDidChangeScopes.fire(results);
      this.updateDiagnostics();
    });

    let didReceiveStatus = false;

    this.toolingDaemon.onEvent(
      "scopes.status",
      (results: Record<string, boolean>) => {
        if (!this.statusBarItem) {
          return;
        }
        didReceiveStatus = true;
        var isBusy = Object.values(results).some((status) => status);
        if (isBusy) {
          this.statusBarItem!.show();
          this.toolingDaemon.setBusy(true);
        } else {
          this.statusBarItem!.hide();
          this.toolingDaemon.setBusy(false);
          this.statusBarItem!.dispose();
          this.statusBarItem = undefined;
        }
      }
    );

    setTimeout(() => {
      if (!didReceiveStatus && this.statusBarItem) {
        this.statusBarItem.dispose();
        this.statusBarItem = undefined;
      }
    }, 30000);
  }

  private updateDiagnostics() {
    this.diagnosticCollection.clear();

    let diagnosticsEnabled = vscode.workspace
      .getConfiguration("jaspr.scopes")
      .get("showUnsafeImportDiagnostics", true);
    if (!diagnosticsEnabled) {
      return;
    }

    let diagnosticsSeverity =
      vscode.DiagnosticSeverity[
        vscode.workspace
          .getConfiguration("jaspr.scopes")
          .get("unsafeImportDiagnosticSeverity", "Error")
      ];

    for (let path in this.scopeResults) {
      const result = this.scopeResults[path];
      if (result.invalidDependencies) {
        let diagnostics: vscode.Diagnostic[] = [];

        const messageSuffix = "or change the component scope.";

        for (let dep of result.invalidDependencies) {
          if (dep.invalidOnClient) {
            const c = dep.invalidOnClient;
            const range = new vscode.Range(
              new vscode.Position(c.line - 1, c.character - 1),
              new vscode.Position(c.line - 1, c.character - 1 + c.length)
            );

            let message = `Unsafe import: '${dep.invalidOnClient.uri}' depends on '${dep.invalidOnClient.target}', which is not available on the client.\nTry using a platform-independent library ${messageSuffix}`;
            if (c.uri === "package:jaspr/server.dart") {
              message = `Unsafe import: '${c.uri}' is not available on the client.\nTry using 'package:jaspr/jaspr.dart' instead ${messageSuffix}`;
            } else if (dep.invalidOnClient.uri === dep.invalidOnClient.target) {
              message = `Unsafe import: '${dep.invalidOnClient.uri}' is not available on the client.\nTry using a platform-independent library ${messageSuffix}`;
            }
            diagnostics.push(
              new vscode.Diagnostic(range, message, diagnosticsSeverity)
            );
          }
          if (dep.invalidOnServer) {
            const s = dep.invalidOnServer;
            const range = new vscode.Range(
              new vscode.Position(s.line - 1, s.character - 1),
              new vscode.Position(s.line - 1, s.character - 1 + s.length)
            );

            let message = `Unsafe import: '${dep.invalidOnServer.uri}' depends on '${dep.invalidOnServer.target}', which is not available on the server.\nTry using a platform-independent library ${messageSuffix}`;
            if (s.uri === "package:jaspr/client.dart") {
              message = `Unsafe import: '${s.uri}' is not available on the server.\nTry using 'package:jaspr/jaspr.dart' instead ${messageSuffix}`;
            } else if (
              s.uri === "package:web/web.dart" ||
              s.uri === "dart:js_interop"
            ) {
              message = `Unsafe import: '${s.uri}' is not available on the server.\nTry using the 'universal_web' package instead ${messageSuffix}`;
            } else if (dep.invalidOnServer.uri === dep.invalidOnServer.target) {
              message = `Unsafe import: '${dep.invalidOnServer.uri}' is not available on the server.\nTry using a platform-independent library ${messageSuffix}`;
            }
            diagnostics.push(
              new vscode.Diagnostic(range, message, diagnosticsSeverity)
            );
          }
        }

        this.diagnosticCollection.set(vscode.Uri.file(path), diagnostics);
      }
    }
  }

  public dispose() {
    this.diagnosticCollection.dispose();
    this._onDidChangeScopes.dispose();
    this.workspaceSubscriptions.dispose();
    this.configurationSubscriptions.dispose();
    if (this.statusBarItem) {
      this.statusBarItem.dispose();
      this.statusBarItem = undefined;
    }
  }
}
