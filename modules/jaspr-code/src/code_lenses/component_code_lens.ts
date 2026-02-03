import { lspToRange } from "../helpers/object_helper";
import * as vs from "vscode";
import { ScopeResults, ScopesDomain, ScopeTarget } from "../jaspr/scopes_domain";
import { dartExtensionApi } from "../api";
import { PublicOutline } from "dart-code/src/extension/api/interfaces";

export class ComponentCodeLensProvider implements vs.CodeLensProvider, vs.Disposable {
  private scopesDomain: ScopesDomain;

  private _onDidChangeCodeLenses: vs.EventEmitter<void> = new vs.EventEmitter<void>();
  public readonly onDidChangeCodeLenses: vs.Event<void> = this._onDidChangeCodeLenses.event;

  private hintCommand: vs.Disposable;
  private scopeResults: ScopeResults = {};

  constructor(scopesDomain: ScopesDomain) {
    this.scopesDomain = scopesDomain;
    this.scopesDomain.onDidChangeScopes((results: ScopeResults) => {
      this.scopeResults = results;
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

    const item = this.scopeResults[document.uri.fsPath];
    if (!item) {
      return;
    }

    for (let child of outline.children) {
      const component = item.components?.find((c) => c === child.element.name);
      if (!component) {
        continue;
      }

      serverRoots.push(...(item.serverScopeRoots ?? []));
      clientRoots.push(...(item.clientScopeRoots ?? []));
      components.push(child);
    }

    for (let component of components) {
      if (serverRoots.length > 0) {
        results.push(
          this.createCodeLens(
            document,
            component,
            "Server Scope",
            serverRoots.map(targetToLocation)
          )
        );
      }

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

      if (
        (serverRoots.length > 0 || clientRoots.length > 0) &&
        vs.workspace
          .getConfiguration("jaspr.scopes", document)
          .get("showHint", true)
      ) {
        var range = lspToRange(component.codeRange);
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
    this.hintCommand.dispose();
  }
}

function targetToLocation(target: ScopeTarget): vs.Location {
  return new vs.Location(
    vs.Uri.file(target.path),
    new vs.Position(target.line - 1, target.character)
  );
}
