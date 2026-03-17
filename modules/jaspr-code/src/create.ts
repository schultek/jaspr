import * as vs from "vscode";
import * as fs from "fs";
import * as path from "path";
import { JASPR_CREATE_PROJECT_TRIGGER_FILE } from "./constants";
import { jasprCreate, JasprCreateOptions, JasprTemplate } from "./commands";
import { checkJasprVersion } from "./helpers/install_helper";
import { fsPath } from "./helpers/project_helper";

type JasprVariant = vs.QuickPickItem & {
  data?: JasprCreateOptions | JasprTemplate | "more";
};

function getJasprVariants(version: string): Array<JasprVariant> {
  let items: Array<JasprVariant> = [];

  if (version >= "0.19.0") {
    items.push(
      {
        kind: vs.QuickPickItemKind.Separator,
        label: "New",
      },
      {
        detail:
          "A beautiful documentation site rendered from Markdown files with prebuilt layout, theming and more.",
        label: "$(book) Documentation Site",
        description: "using jaspr_content",
        data: "docs",
      }
    );
  }

  items.push(
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Templates",
    },
    {
      detail:
        "A static site that is pre-rendered at build time, includes routing and client-side interactivity. Recommended for most sites, landing pages, marketing, portfolios, blogs etc.",
      label: "$(globe) Static Site",
      description: "General Purpose (Recommended)",
      data: {
        mode: "static:auto",
        routing: "multi-page",
        flutter: "plugins-only",
      },
    },
    {
      detail:
        "A dynamic site that is pre-rendered on the server for each request, includes routing and client-side interactivity. Recommended for sites with dynamic or changing content, e-commerce, online services etc.",
      label: "$(server) Server Rendered Site",
      description: "General Purpose",
      data: {
        mode: "server:auto",
        routing: "multi-page",
        flutter: "plugins-only",
      },
    },
    {
      detail:
        "A single page site with client-side routing and interactivity. Good starting point for single page applications, dashboards, admin panels etc.",
      label: "$(browser) Single Page Application",
      description: "Dashboards, Admin Panels & More",
      data: {
        mode: "client",
        routing: "single-page",
        flutter: "plugins-only",
      },
    },
    {
      detail:
        "A static site with an embedded Flutter app. Good starting point for showcasing Flutter apps, demoing widgets etc.",
      label: "$(device-mobile) Embedded Flutter Site",
      description: "Flutter App Showcase, Widget Demos & More",
      data: {
        mode: "static:auto",
        routing: "multi-page",
        flutter: "embedded",
      },
    },
    {
      detail:
        "A server rendered site with a custom backend setup using shelf. Good starting point for projects that include an API or custom backend functionalities.",
      label: "$(server-process) Custom Backend Site",
      description: "Shelf Backend, API & More",
      data: {
        mode: "server:auto",
        routing: "multi-page",
        backend: "shelf",
      },
    },
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "More",
    },
    {
      label: "More ...",
      data: "more",
    }
  );

  return items;
}

function getJasprVariantsAll(): Array<
  vs.QuickPickItem & { data?: JasprCreateOptions }
> {
  const items: Array<vs.QuickPickItem & { data?: JasprCreateOptions }> = [
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Static Mode",
    },
    {
      label: "Static Mode, Multi Page",
      data: {
        mode: "static:auto",
        routing: "multi-page",
        flutter: "plugins-only",
      },
    },
    {
      label: "Static Mode, Single Page",
      data: {
        mode: "static:auto",
        routing: "single-page",
        flutter: "plugins-only",
      },
    },
    {
      label: "Static Mode, Embedded Flutter",
      data: {
        mode: "static:auto",
        routing: "multi-page",
        flutter: "embedded",
      },
    },
    {
      label: "Static Mode, No Routing",
      data: {
        mode: "static:auto",
        routing: "none",
        flutter: "plugins-only",
      },
    },
    {
      label: "Static Mode, Manual Hydration",
      data: {
        mode: "static",
        routing: "single-page",
        flutter: "plugins-only",
      },
    },
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Server Mode",
    },
    {
      label: "Server Mode, Multi Page",
      data: {
        mode: "server:auto",
        routing: "multi-page",
        flutter: "plugins-only",
      },
    },
    {
      label: "Server Mode, Single Page",
      data: {
        mode: "server:auto",
        routing: "single-page",
        flutter: "plugins-only",
      },
    },
    {
      label: "Server Mode, Embedded Flutter",
      data: {
        mode: "server:auto",
        routing: "multi-page",
        flutter: "embedded",
      },
    },
    {
      label: "Server Mode, No Routing",
      data: {
        mode: "server:auto",
        routing: "none",
        flutter: "plugins-only",
      },
    },
    {
      label: "Server Mode, Manual Hydration",
      data: {
        mode: "server",
        routing: "single-page",
        flutter: "plugins-only",
      },
    },
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Client Mode",
    },
    {
      label: "Client Mode, Single Page",
      data: {
        mode: "client",
        routing: "single-page",
        flutter: "plugins-only",
      },
    },
    {
      label: "Client Mode, Embedded Flutter",
      data: {
        mode: "client",
        routing: "single-page",
        flutter: "embedded",
      },
    },
    {
      label: "Client Mode, No Routing",
      data: {
        mode: "client",
        routing: "none",
      },
    },
  ];

  return items;
}

export async function createJasprProject(): Promise<vs.Uri | undefined> {
  const v = await checkJasprVersion();
  if (!v) {
    return;
  }
  const jasprVariants = getJasprVariants(v);

  let selectedModeItem = await vs.window.showQuickPick(jasprVariants, {
    ignoreFocusOut: true,
    matchOnDescription: true,
    placeHolder: "Select a starter template",
  });

  if (selectedModeItem?.data === "more") {
    const jasprVariantsAll = getJasprVariantsAll();

    selectedModeItem = await vs.window.showQuickPick(jasprVariantsAll, {
      ignoreFocusOut: true,
      matchOnDescription: true,
      placeHolder: "Select a configuration",
    });
  }

  if (!selectedModeItem?.data) {
    return;
  }

  return createJasprProjectForMode(selectedModeItem.data as JasprCreateOptions);
}

async function createJasprProjectForMode(
  data: JasprCreateOptions
): Promise<vs.Uri | undefined> {
  // If already in a workspace, set the default folder to something nearby.
  const folders = await vs.window.showOpenDialog({
    canSelectFolders: true,
    title: "Select a folder to create the project in",
  });
  if (!folders || folders.length !== 1) {
    return;
  }
  const folderPath = fsPath(folders[0]);

  const name = await promptForName("my_jaspr_site", folderPath);
  if (!name) {
    return;
  }

  const projectFolderUri = vs.Uri.file(path.join(folderPath, name));
  const projectFolderPath = fsPath(projectFolderUri);

  if (fs.existsSync(projectFolderPath)) {
    void vs.window.showErrorMessage(
      `A folder named "${name}" already exists in ${folderPath}`
    );
    return;
  }

  // Create the empty folder so we can open it.
  fs.mkdirSync(projectFolderPath);

  fs.writeFileSync(
    path.join(projectFolderPath, JASPR_CREATE_PROJECT_TRIGGER_FILE),
    JSON.stringify(data)
  );

  void vs.commands.executeCommand("vscode.openFolder", projectFolderUri);

  return projectFolderUri;
}

async function promptForName(
  defaultName: string,
  folderPath: string
): Promise<string | undefined> {
  while (true) {
    const response = await showInputBox({
      ignoreFocusOut: true,
      placeholder: defaultName,
      prompt: "Enter a name for your new project",
      title: "Project Name",
      validation: (s) => validateProjectName(s, folderPath),
      value: defaultName,
    });

    if (response) {
      return response.value;
    } else {
      return undefined;
    }
  }
}

async function showInputBox(options: {
  ignoreFocusOut: boolean;
  title: string;
  prompt: string;
  placeholder: string;
  value: string;
  validation: (s: string) => string | undefined;
}): Promise<{ value: string } | undefined> {
  const input = vs.window.createInputBox();

  input.ignoreFocusOut = options.ignoreFocusOut;
  input.title = options.title;
  input.prompt = options.prompt;
  input.placeholder = options.placeholder;
  input.value = options.value;
  if (options.validation) {
    input.onDidChangeValue((s) => {
      input.validationMessage = options.validation(s);
    });
  }

  const name = await new Promise<{ value: string } | undefined>((resolve) => {
    input.onDidAccept(() => {
      // Don't accept while there's a validation error.
      if (input.validationMessage) {
        return;
      }
      input.value ? resolve({ value: input.value }) : resolve(undefined);
    });
    input.onDidHide(() => {
      resolve(undefined);
    });
    input.show();
  });

  input.dispose();

  return name;
}

export const packageNameRegex = new RegExp("^[a-z][a-z0-9_]*$");

function validateProjectName(input: string, folderDir: string) {
  if (!packageNameRegex.test(input)) {
    return "Jaspr project names should be all lowercase, with underscores to separate words";
  }

  const bannedNames = ["jaspr", "jaspr_text", "this"];
  if (bannedNames.includes(input)) {
    return `You may not use "${input}" as the name for a Jaspr project`;
  }

  if (fs.existsSync(path.join(folderDir, input))) {
    return `A project with this name already exists within the selected directory`;
  }
}

export async function handleNewProjects(): Promise<void> {
  await Promise.all(
    vs.workspace.workspaceFolders?.map(async (wf) => {
      try {
        await handleJasprCreateTrigger(wf);
      } catch (e) {
        console.error("Failed to create project");
        console.error(e);
        void vs.window.showErrorMessage("Failed to create project");
      }
    }) ?? []
  );
}

async function handleJasprCreateTrigger(wf: vs.WorkspaceFolder): Promise<void> {
  const flutterTriggerFile = path.join(
    fsPath(wf.uri),
    JASPR_CREATE_PROJECT_TRIGGER_FILE
  );
  if (!fs.existsSync(flutterTriggerFile)) {
    return;
  }

  const jsonString = fs.readFileSync(flutterTriggerFile).toString().trim();
  const json = jsonString
    ? (JSON.parse(jsonString) as JasprCreateOptions)
    : undefined;

  fs.unlinkSync(flutterTriggerFile);

  const success = await jasprCreate(fsPath(wf.uri), json);
  if (success) {
    const entryFile = path.join(
      fsPath(wf.uri),
      json?.mode === "client" ? "lib/main.client.dart" : "lib/main.server.dart"
    );
    vs.commands.executeCommand("vscode.open", vs.Uri.file(entryFile));

    vs.window.showInformationMessage(
      "Your Jaspr project is ready! Press F5 and select 'Jaspr' to start running."
    );
  }
}
