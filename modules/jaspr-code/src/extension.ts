import * as vscode from "vscode";
import {
  DynamicDebugConfigProvider,
  InitialLaunchJsonDebugConfigProvider,
  JasprDebugConfigurationProvider,
} from "./debug";

import { createJasprProject, handleNewProjects } from "./create";
import { jasprClean, jasprDoctor } from "./commands";
import { JasprDaemonProcess } from "./daemon";
import {
  findJasprProjectFolders,
  getFolderToRunCommandIn,
} from "./helpers/project_helper";

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
      const folderToRunCommandIn = await getFolderToRunCommandIn(
        `Select the folder to run "jaspr serve" in`
      );
      if (!folderToRunCommandIn) {
        return;
      }

      const process = new JasprDaemonProcess();
      context.subscriptions.push(process);

      process.start(context, undefined, {
        name: "Jaspr",
        request: "launch",
        type: "jaspr",
        cwd: folderToRunCommandIn,
      });
    })
  );
}
