import * as vs from "vscode";
import { findJasprProjectFolders } from "../helpers/project_helper";
import { dartExtensionApi } from "../api";
import { lspToRange } from "../helpers/object_helper";
import path from "path";
import * as yaml from "yaml";
import { checkJasprVersion } from "../helpers/install_helper";

export class ServeCodeLensProvider implements vs.CodeLensProvider, vs.Disposable {

  private _onDidChangeCodeLenses: vs.EventEmitter<void> = new vs.EventEmitter<void>();
  public readonly onDidChangeCodeLenses: vs.Event<void> = this._onDidChangeCodeLenses.event;

  private folders: string[] = [];
  private serverTargets: string[] = [];
  private clientTargets: string[] = [];
  private suppressions: vs.Disposable[] = [];

  constructor() {
    this.loadEntrypoints();
    vs.workspace.onDidChangeWorkspaceFolders(async () => {
      await this.loadEntrypoints();
      this._onDidChangeCodeLenses.fire();
    });
    vs.workspace.onDidChangeTextDocument(async (e) => {
      if (e.document.languageId === "yaml" && e.document.fileName.endsWith("pubspec.yaml")) {
        await this.loadEntrypoints();
        this._onDidChangeCodeLenses.fire();
      }
    });
  }

  private async loadEntrypoints() {
    const v = await checkJasprVersion();
    if (!v || v < '0.22.0') {
      return;
    }

    const folders = await findJasprProjectFolders();

    const serverUris = await vs.workspace.findFiles('**/*.server.dart', '**/build/**');
    const clientUris = await vs.workspace.findFiles('**/*.client.dart', '**/build/**');

    const suppressionTargets: vs.Uri[] = [];
    const serverTargets: string[] = [];
    const clientTargets: string[] = [];

    for (let project of folders) {

      const pubspecPath = path.join(project, "pubspec.yaml");
      const pubspecContent = await vs.workspace.fs.readFile(vs.Uri.file(pubspecPath));
      const pubspec = await yaml.parse(Buffer.from(pubspecContent).toString("utf8"));

      const mode = pubspec?.jaspr?.mode;

      const projectServerUris = serverUris.filter((uri) => uri.fsPath.startsWith(project));
      const projectClientUris = clientUris.filter((uri) => uri.fsPath.startsWith(project));

      suppressionTargets.push(...projectClientUris, ...projectServerUris);

      if (mode === "server" || mode === "static") {
        serverTargets.push(...projectServerUris.map((u) => u.fsPath));
      }

      if (mode === "client") {
        clientTargets.push(...projectClientUris.map((u) => u.fsPath));
      }
    }

    this.folders = folders;
    this.serverTargets = serverTargets;
    this.clientTargets = clientTargets;

    this.suppressions.forEach((s) => s.dispose());
    this.suppressions = [
      dartExtensionApi.features.codeLens.suppress(suppressionTargets, { main: true }),
    ];
  }

  public async provideCodeLenses(document: vs.TextDocument, token: vs.CancellationToken): Promise<vs.CodeLens[] | undefined> {
    const isServerTarget = !!this.serverTargets.find((t) => t === document.uri.fsPath);
    const isClientTarget = !!this.clientTargets.find((t) => t === document.uri.fsPath);
    if (!isServerTarget && !isClientTarget) {
      return;
    }

    const outline = await dartExtensionApi.workspace.getOutline(document, token);
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
        arguments: [isServerTarget ? input : undefined, folder],
      }),
    ];
  }

  public dispose() {
    this.suppressions.forEach((s) => s.dispose());
  }
}
