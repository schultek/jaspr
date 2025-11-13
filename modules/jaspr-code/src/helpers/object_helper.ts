import * as vs from "vscode";

export function lspToRange(range: any): vs.Range {
  return new vs.Range(lspToPosition(range.start), lspToPosition(range.end));
}

export function lspToPosition(position: any): vs.Position {
  return new vs.Position(position.line, position.character);
}
