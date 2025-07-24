import * as vscode from "vscode";
import {
  DynamicDebugConfigProvider,
  InitialLaunchJsonDebugConfigProvider,
  JasprDebugConfigurationProvider,
} from "./debug";

import { JasprServeProcess } from "./process";
import { findJasprProjectFolders, projectReferencesJaspr } from "./utils";
import { createJasprProject, handleNewProjects } from "./create";
import { jasprClean, jasprDoctor } from "./commands";
import { ComponentCodeLensProvider } from "./code_lens";

export async function activate(context: vscode.ExtensionContext) {
  let projects = await findJasprProjectFolders();
  void vscode.commands.executeCommand(
    "setContext",
    "jaspr-code:anyJasprProjectLoaded",
    projects.length > 0
  );

  await handleNewProjects();

  const provider = new JasprDebugConfigurationProvider(context);
  context.subscriptions.push(
    vscode.debug.registerDebugConfigurationProvider("jaspr", provider)
  );
  context.subscriptions.push(provider);

  if (vscode.DebugConfigurationProviderTriggerKind) {
    // Temporary workaround for GitPod/Theia not having this enum.
    context.subscriptions.push(
      vscode.debug.registerDebugConfigurationProvider(
        "jaspr",
        new InitialLaunchJsonDebugConfigProvider(),
        vscode.DebugConfigurationProviderTriggerKind.Initial
      )
    );
    context.subscriptions.push(
      vscode.debug.registerDebugConfigurationProvider(
        "jaspr",
        new DynamicDebugConfigProvider(),
        vscode.DebugConfigurationProviderTriggerKind.Dynamic
      )
    );
  }

  context.subscriptions.push(
    vscode.commands.registerCommand("jaspr.create", createJasprProject)
  );

  context.subscriptions.push(
    vscode.commands.registerCommand("jaspr.clean", jasprClean)
  );

  context.subscriptions.push(
    vscode.commands.registerCommand("jaspr.doctor", jasprDoctor)
  );

  context.subscriptions.push(
    vscode.commands.registerCommand("jaspr.serve", async () => {
      const process = new JasprServeProcess();
      context.subscriptions.push(process);

      process.start(context);
    })
  );
  context.subscriptions.push(
    vscode.languages.registerCodeLensProvider(
      { language: "dart", scheme: "file" },
      new ComponentCodeLensProvider()
    )
  );
}
