import * as vs from "vscode";
import { dartExtensionApi } from "./api";
import { findJasprProjectFolders } from "./helpers/project_helper";
import { JasprToolingDaemon } from "./jaspr/tooling_daemon";
import { PublicOutline } from "dart-code/src/extension/api/interfaces";

type ScopeResults = {
  root: ScopeTarget;
  data: Record<string, ScopeFileResult>;
};

type ScopeFileResult = {
  components: string[];
  clientScopeRoots: ScopeTarget[];
};

type ScopeTarget = {
  path: string;
  name: string;
  line: number;
  character: number;
};

export class ComponentCodeLensProvider
  implements vs.CodeLensProvider, vs.Disposable
{
  private toolingDaemon: JasprToolingDaemon;

  private _onDidChangeCodeLenses: vs.EventEmitter<void> =
    new vs.EventEmitter<void>();
  public readonly onDidChangeCodeLenses: vs.Event<void> =
    this._onDidChangeCodeLenses.event;

  private scopeResults: Record<string, ScopeResults> = {};

  constructor(toolingDaemon: JasprToolingDaemon) {
    this.toolingDaemon = toolingDaemon;
    this.registerFolders();
  }

  private async registerFolders() {
    var folders = await findJasprProjectFolders();
    this.toolingDaemon.sendMessage("scopes.register", { folders: folders });
    this.toolingDaemon.onEvent("scopes.result", (results: ScopeResults) => {
      this.scopeResults[results.root.path] = results;
      this._onDidChangeCodeLenses.fire();
    });
  }

  public async provideCodeLenses(
    document: vs.TextDocument,
    token: vs.CancellationToken
  ): Promise<vs.CodeLens[] | undefined> {
    const outline = await dartExtensionApi.workspace.getOutline(
      document,
      token
    );
    if (!outline?.children?.length) {
      return;
    }

    const results: vs.CodeLens[] = [];

    const serverRoots: ScopeTarget[] = [];
    const clientRoots: ScopeTarget[] = [];
    const components: PublicOutline[] = [];

    for (let root in this.scopeResults) {
      const scope = this.scopeResults[root];
      const items = scope.data;
      if (!items) {
        continue;
      }
      const item = items[document.uri.fsPath];
      if (!item) {
        continue;
      }

      for (let child of outline.children) {
        const component = item.components.find((c) => c === child.element.name);
        if (!component) {
          continue;
        }

        serverRoots.push(scope.root);
        clientRoots.push(...item.clientScopeRoots);
        if (!components.includes(child)) {
          components.push(child);
        }
      }
    }

    for (let component of components) {
      results.push(
        this.createCodeLens(
          document,
          component,
          "Server Scope",
          serverRoots.map(targetToLocation)
        )
      );

      if (clientRoots.length > 0) {
        results.push(
          this.createCodeLens(
            document,
            component,
            "Client Scope",
            clientRoots.map(targetToLocation)
          )
        );
      }
    }

    return results;
  }

  private createCodeLens(
    document: vs.TextDocument,
    element: any,
    name: string,
    targets: vs.Location[]
  ): vs.CodeLens {
    var range = lspToRange(element.codeRange);
    return new vs.CodeLens(range, {
      arguments: [document.uri, range.start, targets, "peek"],
      command: "editor.action.peekLocations",
      title: name,
    });
  }

  public dispose(): any {
    this._onDidChangeCodeLenses.dispose();
  }
}

function targetToLocation(target: ScopeTarget): vs.Location {
  return new vs.Location(
    vs.Uri.file(target.path),
    new vs.Position(target.line - 1, target.character)
  );
}

export function lspToRange(range: any): vs.Range {
  return new vs.Range(lspToPosition(range.start), lspToPosition(range.end));
}

export function lspToPosition(position: any): vs.Position {
  return new vs.Position(position.line, position.character);
}
