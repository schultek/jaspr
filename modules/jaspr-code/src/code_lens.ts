import {
  CancellationToken,
  CodeLens,
  CodeLensProvider,
  Disposable,
  Location,
  Position,
  Range,
  TextDocument,
  Uri,
} from "vscode";
import { dartExtensionApi } from "./api";
import { findJasprProjectFolders } from "./helpers/project_helper";
import { runJasprInFolder } from "./helpers/process_helper";

export class ComponentCodeLensProvider implements CodeLensProvider, Disposable {
  private disposables: Disposable[] = [];

  private inspectResults: Record<string, Thenable<any> | undefined> = {};

  constructor() {}

  public async provideCodeLenses(
    document: TextDocument,
    token: CancellationToken
  ): Promise<CodeLens[] | undefined> {
    // Without version numbers, the best we have to tell if an outline is likely correct or stale is
    // if its length matches the document exactly.
    const expectedLength = document.getText().length;
    const outline = await (
      dartExtensionApi as any
    ).analyzer.fileTracker.waitForOutlineWithLength(
      document,
      expectedLength,
      token
    );
    if (!outline?.children?.length) {
      return;
    }

    var folders = await findJasprProjectFolders();

    var folder = folders.find((f) => document.uri.path.startsWith(f));
    if (!folder) {
      return;
    }

    if (!this.inspectResults[folder]) {
      this.inspectResults[folder] = runJasprInFolder(
        folder,
        ["inspect"],
        undefined
      );
    }

    var mainFileLocation = folder + "/lib/main.dart";
    var result = (await this.inspectResults[folder]).stdout as string;
    var start = result.indexOf("<<__");
    var end = result.indexOf("__>>");

    var data = JSON.parse(result.substring(start + 4, end));
    var item = data[document.uri.path];

    const results: CodeLens[] = [];

    for (let child of outline.children) {
      if (item.components.includes(child.element.name)) {
        results.push(this.createCodeLens(document, child, "Server Scope", mainFileLocation));
        if (item.isClient || item.isClientDependent) {
          results.push(this.createCodeLens(document, child, "Client Scope", mainFileLocation));
        }
      }
    }

    return results;
  }

  private createCodeLens(
    document: TextDocument,
    element: any,
    name: string,
    location: string
  ): CodeLens {
    var range = lspToRange(element.codeRange);
    return new CodeLens(range, {
      arguments: [
        document.uri,
        range.start,
        [
          new Location(
            Uri.parse(location),
            new Position(0, 0),
          ),
        ],
        "peek"
      ],
      command: "editor.action.peekLocations",
      title: name,
    });
  }

  public dispose(): any {}
}

export function lspToRange(range: any): Range {
  return new Range(lspToPosition(range.start), lspToPosition(range.end));
}

export function lspToPosition(position: any): Position {
  return new Position(position.line, position.character);
}
