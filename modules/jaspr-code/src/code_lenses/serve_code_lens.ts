import * as vs from "vscode";
import { findJasprProjectFolders } from "../helpers/project_helper";
import path from "path";
import * as yaml from "yaml";
import { dartExtensionApi } from "../api";
import { lspToRange } from "../helpers/object_helper";

export class ServeCodeLensProvider implements vs.CodeLensProvider, vs.Disposable {

  private _onDidChangeCodeLenses: vs.EventEmitter<void> = new vs.EventEmitter<void>();
  public readonly onDidChangeCodeLenses: vs.Event<void> = this._onDidChangeCodeLenses.event;

  private folders: string[] = [];
  private targets: string[] = [];
  private suppressions: vs.Disposable[] = [];

  constructor() {
    this.loadTargets();
    vs.workspace.onDidChangeWorkspaceFolders(async () => {
      await this.loadTargets();
      this._onDidChangeCodeLenses.fire();
    });
    vs.workspace.onDidChangeTextDocument(async (e) => {
      if (e.document.languageId === "yaml" && e.document.fileName.endsWith("pubspec.yaml")) {
        await this.loadTargets();
        this._onDidChangeCodeLenses.fire();
      }
    });
  }

  private async loadTargets() {
    const folders = await findJasprProjectFolders();
    const targets: string[] = [];

    for (let project of folders) {
      const pubspecPath = path.join(project, "pubspec.yaml");
      const pubspecContent = await vs.workspace.fs.readFile(vs.Uri.file(pubspecPath));
      const pubspec = await yaml.parse(Buffer.from(pubspecContent).toString("utf8"));

      const target = pubspec?.jaspr?.target as string | string[] | undefined;
      if (typeof target === "string") {
        targets.push(path.join(project, target));
      } else if (Array.isArray(target)) {
        for (let t of target) {
          targets.push(path.join(project, t));
        }
      } else {
        targets.push(path.join(project, "lib", "main.dart"));
      }
    }

    this.folders = folders;
    this.targets = targets;

    this.suppressions.forEach((s) => s.dispose());
    this.suppressions = [];
    this.suppressions.push(
      dartExtensionApi.features.codeLens.suppress(this.targets.map((t) => vs.Uri.file(t)), { main: true })
    );
  }

  public async provideCodeLenses(document: vs.TextDocument, token: vs.CancellationToken): Promise<vs.CodeLens[] | undefined> {
    let isTarget = !!this.targets.find((t) => t === document.uri.fsPath);
    if (!isTarget) {
      return;
    }

    const outline = await dartExtensionApi.workspace.getOutline(
      document,
      token
    );
    if (!outline?.children?.length) {
      return;
    }

    const main = outline.children.find((c) => c.element.name === "main");

    if (!main) {
      return;
    }

    const folder = this.folders.find((f) => document.uri.fsPath.startsWith(f));
    if (!folder) {
      return;
    }

    const input = document.uri.fsPath.substring(folder.length + 1);
    const range = lspToRange(main.codeRange);
    return [
      new vs.CodeLens(range, {
        command: "jaspr.serve",
        title: "Serve",
        arguments: [input, folder],
      }),
    ];
  }

  public dispose() {
    this.suppressions.forEach((s) => s.dispose());
  }
}
