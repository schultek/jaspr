import * as vs from "vscode";
import { PublicOutline } from "dart-code/src/extension/api/interfaces";

export type ScopeResults = {
  locations: Record<string, ScopeLocation>;
  scopes: Record<string, ScopeLibraryResult>;
}

export type ScopeLibraryResult = {
  components: string[];
  clientScopeRoots?: string[];
  serverScopeRoots?: string[];
};

export type ScopeLocation = {
  path: string;
  name: string;
  line: number;
  char: number;
  length: number;
};


export class ComponentCodeLensProvider implements vs.CodeLensProvider, vs.Disposable {
  private watcher: vs.FileSystemWatcher;

  private _onDidChangeCodeLenses: vs.EventEmitter<void> = new vs.EventEmitter<void>();
  public readonly onDidChangeCodeLenses: vs.Event<void> = this._onDidChangeCodeLenses.event;

  private hintCommand: vs.Disposable;
  private scopeResults: Record<string, ScopeResults> = {};

  constructor() {

    this.watcher = vs.workspace.createFileSystemWatcher("**/.dart_tool/jaspr/scopes.json");

    this.watcher.onDidChange(async (uri) => {
      await this.loadScopes(uri);
      this._onDidChangeCodeLenses.fire();
    });

    this.watcher.onDidCreate(async (uri) => {
      await this.loadScopes(uri);
      this._onDidChangeCodeLenses.fire();
    });

    this.hintCommand = vs.commands.registerCommand(
      "jaspr.action.showScopeHint",
      async () => {
        let result = await vs.window.showInformationMessage(
          `Component Scopes define where a component is rendered: server, client or both. For example, any component that is a descendant of an '@client' component will be in that component's client scope. Scopes also limit which platform-specific imports are available for a component.`,
          "Learn More",
          "Close",
          "Never Show Again"
        );

        if (result === "Learn More") {
          await vs.env.openExternal(
            vs.Uri.parse("https://docs.jaspr.site/dev/server#component-scopes")
          );
        } else if (result === "Never Show Again") {
          await vs.workspace
            .getConfiguration("jaspr.scopes")
            .update("showHint", false, vs.ConfigurationTarget.Global);
        }
      }
    );
  }

  private async loadScopes(uri: vs.Uri) {
    const content = await vs.workspace.fs.readFile(uri);
    this.scopeResults[uri.fsPath] = JSON.parse(content.toString());
  }

  public provideCodeLenses(
    document: vs.TextDocument,
    token: vs.CancellationToken
  ): vs.CodeLens[] | undefined {
    const results: vs.CodeLens[] = [];

    let scopeResults: ScopeResults | null = null;
    let item: ScopeLibraryResult | null = null;
    for (const key in this.scopeResults) {
      scopeResults = this.scopeResults[key];
      item = scopeResults.scopes[document.uri.fsPath];

      if (item) break;
    }

    if (!scopeResults || !item) {
      return;
    }

    const mapIdsToLocations = (ids?: string[]): vs.Location[] => {
      if (!ids) return [];
      return ids.map((id) => scopeResults.locations[id]).map(this.scopeLocationToLocation);
    };

    const serverRootLocations = mapIdsToLocations(item.serverScopeRoots);
    const clientRootLocations = mapIdsToLocations(item.clientScopeRoots);

    const showScopeHint = (serverRootLocations.length > 0 || clientRootLocations.length > 0) && vs.workspace
      .getConfiguration("jaspr.scopes", document)
      .get("showHint", true);

    for (let componentId of item.components) {

      const location = scopeResults.locations[componentId];
      const range = this.scopeLocationToRange(location);

      if (serverRootLocations.length > 0) {
        results.push(
          new vs.CodeLens(range, {
            arguments: [document.uri, range.start, serverRootLocations, "peek"],
            command: "editor.action.peekLocations",
            title: "Server Scope",
          })
        );
      }

      if (clientRootLocations.length > 0) {
        results.push(
          new vs.CodeLens(range, {
            arguments: [document.uri, range.start, clientRootLocations, "peek"],
            command: "editor.action.peekLocations",
            title: "Client Scope",
          })
        );
      }

      if (showScopeHint) {
        results.push(
          new vs.CodeLens(range, {
            command: "jaspr.action.showScopeHint",
            title: "What is this?",
          })
        );
      }
    }

    return results;
  }

  private scopeLocationToLocation(location: ScopeLocation): vs.Location {
    return new vs.Location(
      vs.Uri.file(location.path),
      new vs.Position(location.line - 1, location.char)
    );
  }

  private scopeLocationToRange(location: ScopeLocation): vs.Range {
    return new vs.Range(
      new vs.Position(location.line - 1, location.char),
      new vs.Position(location.line - 1, location.char + location.length)
    );
  }

  public dispose(): any {
    this._onDidChangeCodeLenses.dispose();
    this.watcher.dispose();
    this.hintCommand.dispose();
  }
}