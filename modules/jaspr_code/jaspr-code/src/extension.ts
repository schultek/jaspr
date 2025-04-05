import * as vscode from "vscode";
import { JasprDebugConfigurationProvider } from "./debug";
import { DartExtensionApi } from "./interfaces";


export function activate(context: vscode.ExtensionContext) {
  const dartCode = vscode.extensions.getExtension("dart-code.dart-code");

  if (!dartCode) {
    // This should not happen since the Jaspr extension has a dependency on the Dart one
    // but just in case, we'd like to give a useful error message.
    throw new Error(
      "The Dart extension is not installed, Jaspr extension is unable to activate."
    );
  }

  const dartExtensionApi = dartCode.exports._privateApi as DartExtensionApi;

  const provider = new JasprDebugConfigurationProvider(context, dartExtensionApi);
	vscode.debug.registerDebugConfigurationProvider(
		"jaspr",
		provider,
		vscode.DebugConfigurationProviderTriggerKind.Dynamic,
	);

  context.subscriptions.push(provider);
	
  


}

