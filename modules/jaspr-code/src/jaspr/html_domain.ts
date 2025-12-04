import * as vscode from "vscode";
import { JasprToolingDaemon } from "./tooling_daemon";

export class HtmlDomain
  implements vscode.DocumentPasteEditProvider, vscode.Disposable
{
  private toolingDaemon: JasprToolingDaemon;
  private pasteEditProviderDisposable: vscode.Disposable | undefined;

  static readonly kind = vscode.DocumentDropOrPasteEditKind.Empty.append(
    "text",
    "custom",
    "jaspr"
  );

  constructor(toolingDaemon: JasprToolingDaemon) {
    this.toolingDaemon = toolingDaemon;

    this.pasteEditProviderDisposable =
      vscode.languages.registerDocumentPasteEditProvider(
        { language: "dart" },
        this,
        {
          providedPasteEditKinds: [HtmlDomain.kind],
          pasteMimeTypes: ["text/plain"],
        }
      );
  }

  async provideDocumentPasteEdits(
    document: vscode.TextDocument,
    ranges: readonly vscode.Range[],
    data: vscode.DataTransfer,
    context: vscode.DocumentPasteEditContext,
    token: vscode.CancellationToken
  ) {
    if (
      this.toolingDaemon.jasprVersion === undefined ||
      this.toolingDaemon.jasprVersion < "0.21.2"
    ) {
      return;
    }

    const content = await data.get("text/plain")?.asString();
    if (content?.startsWith("<")) {
      try {
        const result = await this.toolingDaemon.sendMessage(
          "html.convert",
          { html: content },
          1000
        );

        if (token.isCancellationRequested) {
          return;
        }
        return [
          new vscode.DocumentPasteEdit(
            result,
            "Convert to Jaspr",
            HtmlDomain.kind
          ),
        ];
      } catch (e) {
        vscode.window.showErrorMessage("Failed to convert HTML to Jaspr: " + e);
        return;
      }
    }
  }

  public dispose() {
    this.pasteEditProviderDisposable?.dispose();
  }
}
