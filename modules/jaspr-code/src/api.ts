import * as vscode from "vscode";
import { PublicDartExtensionApi, PublicStartResult } from "dart-code/src/extension/api/interfaces";

export const dartExtensionApi: PublicDartExtensionApi =
  getDartExtensionApi();

export type DartProcess = PublicStartResult;

function getDartExtensionApi(): PublicDartExtensionApi {
  const dartCode = vscode.extensions.getExtension("dart-code.dart-code");

  if (!dartCode) {
    // This should not happen since the Jaspr extension has a dependency on the Dart one
    // but just in case, we'd like to give a useful error message.
    throw new Error(
      "The Dart extension is not installed, Jaspr extension cannot be used."
    );
  }

  const dartExtensionApi = dartCode.exports as PublicDartExtensionApi;
  if (dartExtensionApi.version !== 2) {
    throw new Error(`Incompatible Dart extension version. Make sure you switch to the pre-release version of the Dart extension.`);
  }

  return dartExtensionApi;
}
