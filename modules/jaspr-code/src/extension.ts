import * as vscode from "vscode";
import {
  DynamicDebugConfigProvider,
  InitialLaunchJsonDebugConfigProvider,
  JasprDebugConfigurationProvider,
} from "./debug";

import { createJasprProject, handleNewProjects } from "./create";
import { jasprClean, jasprDoctor } from "./commands";
import { JasprServeDaemon } from "./jaspr/serve_daemon";
import {
  findJasprProjectFolders,
  getFolderToRunCommandIn,
} from "./helpers/project_helper";
import { JasprToolingDaemon } from "./jaspr/tooling_daemon";
import { ScopesDomain } from "./jaspr/scopes_domain";
import { HtmlDomain } from "./jaspr/html_domain";
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
    vscode.commands.registerCommand("jaspr.serve", async (input: string | undefined, folder: string | undefined) => {
      if (!folder) {
        folder = await getFolderToRunCommandIn(
          `Select the folder to run "jaspr serve" in`
        );
      }
      if (!folder) {
        return;
      }

      const process = new JasprServeDaemon();
      context.subscriptions.push(process);

      process.start(context, undefined, {
        name: "Jaspr",
        request: "launch",
        type: "jaspr",
        cwd: folder,
        args: !!input ? ['--input=' + input] : []
      });
    })
  );

  const toolingDaemon = new JasprToolingDaemon();
  context.subscriptions.push(toolingDaemon);
  await toolingDaemon.start(context);

  const scopesDomain = new ScopesDomain(toolingDaemon);
  context.subscriptions.push(scopesDomain);

  context.subscriptions.push(
    vscode.languages.registerCodeLensProvider(
      { language: "dart", scheme: "file" },
      new ComponentCodeLensProvider(scopesDomain)
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

  const htmlDomain = new HtmlDomain(toolingDaemon);
  context.subscriptions.push(htmlDomain);
}
