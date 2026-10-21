import * as vscode from "vscode";
import {
  DynamicDebugConfigProvider,
  InitialLaunchJsonDebugConfigProvider,
  JasprDebugAdapterTrackerFactory,
  JasprDebugConfigurationProvider,
} from "./debug";
import { JasprServeDaemon } from "./jaspr/serve_daemon";

import { createJasprProject, handleNewProjects } from "./create";
import { jasprClean, jasprDoctor, jasprServe } from "./commands";
import {
  findJasprProjectFolders,
} from "./helpers/project_helper";
import { HtmlPasteProvider } from "./jaspr/html_paste_provider";
import { dartExtensionApi } from "./api";
import { ComponentCodeLensProvider } from "./code_lenses/component_code_lens";
import { ServeCodeLensProvider } from "./code_lenses/serve_code_lens";

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
    vscode.debug.registerDebugAdapterTrackerFactory(
      "dart",
      new JasprDebugAdapterTrackerFactory()
    )
  );

  context.subscriptions.push(
    vscode.commands.registerCommand("jaspr.hotReload", async () => {
      const daemon = JasprServeDaemon.getActiveDaemon();
      if (daemon) {
        daemon.reload();
      } else {
        await vscode.commands.executeCommand("dart.hotReload");
      }
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand("jaspr.hotRestart", async () => {
      const daemon = JasprServeDaemon.getActiveDaemon();
      if (daemon) {
        daemon.restart();
      } else {
        await vscode.commands.executeCommand("workbench.action.debug.restart");
      }
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand("jaspr.serve", jasprServe(context))
  );

  context.subscriptions.push(
    vscode.languages.registerCodeLensProvider(
      { language: "dart", scheme: "file" },
      new ComponentCodeLensProvider()
    )
  );

  if (dartExtensionApi.version >= 3) {
    context.subscriptions.push(
      vscode.languages.registerCodeLensProvider(
        { language: "dart", scheme: "file" },
        new ServeCodeLensProvider()
      )
    );
  }

  const htmlPasteProvider = new HtmlPasteProvider();
  context.subscriptions.push(htmlPasteProvider);
}
