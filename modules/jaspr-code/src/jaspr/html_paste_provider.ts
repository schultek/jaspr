import * as vscode from "vscode";
import { runJaspr } from "../helpers/process_helper";
import { cwd } from "process";

export class HtmlPasteProvider
  implements vscode.DocumentPasteEditProvider, vscode.Disposable {
  private pasteEditProviderDisposable: vscode.Disposable | undefined;

  static readonly kind = vscode.DocumentDropOrPasteEditKind.Empty.append(
    "text",
    "custom",
    "jaspr"
  );

  constructor() {
    this.pasteEditProviderDisposable =
      vscode.languages.registerDocumentPasteEditProvider(
        { language: "dart" },
        this,
        {
          providedPasteEditKinds: [HtmlPasteProvider.kind],
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


    const content = await data.get("text/plain")?.asString();
    if (content && /^<[a-z]+(\s+[^>]*)*>/i.test(content)) {
      try {
        const output = await runJaspr(['convert-html', '--html', JSON.stringify(content), '--json'], cwd());
        if (token.isCancellationRequested) {
          return;
        }
        const result = output.split('\n').find((line) => line.startsWith('{"result":'));
        if (!result) {
          vscode.window.showErrorMessage("Failed to convert HTML to Jaspr: " + output);
          return;
        }

        return [
          new vscode.DocumentPasteEdit(
            JSON.parse(result)['result'],
            "Convert to Jaspr",
            HtmlPasteProvider.kind
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
