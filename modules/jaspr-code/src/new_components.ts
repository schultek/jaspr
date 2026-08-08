import * as vs from "vscode";
import * as fs from "fs";
import * as path from "path";
import { checkJasprVersion } from "./helpers/install_helper";
import { fsPath, getFolderToRunCommandIn } from "./helpers/project_helper";
import { jasprNew } from "./commands";


export type JasprComponentType = "stateless" | "stateful" | "async" | "flutter" | "inherited";
export type JasprComponentOptions = "client" | "with-styles" | "with-test";
export type JasprFlutterEmbedOptions = "with-sample-widget";

export interface JasprNewComponentOptions {
  readonly type?: JasprComponentType;
  readonly componentOptions?: Array<JasprComponentOptions>;
  readonly flutterEmbedOptions?: Array<JasprFlutterEmbedOptions>;
}

type JapsrComponentVariant = vs.QuickPickItem & {
  data?: JasprNewComponentOptions | "more";
};


export async function createJasprComponent()
  : Promise<vs.Uri | undefined> {
  const v = await checkJasprVersion();
  if (!v) {
    return;
  }
  const jasprComponentVariants = getJasprComponentVariants();

  let selectedModeItem = await vs.window.showQuickPick(jasprComponentVariants, {
    ignoreFocusOut: true,
    matchOnDescription: true,
    placeHolder: "Select a component type",
  });


  if (selectedModeItem?.data === "more") {
    const jasprComponentVariantsAll = getJasprComponentVariantsAll();

    selectedModeItem = await vs.window.showQuickPick(jasprComponentVariantsAll, {
      ignoreFocusOut: true,
      matchOnDescription: true,
      placeHolder: "Select a configuration",
    });
  }

  if (!selectedModeItem?.data) {
    return;
  }

  return createJasprComponentWithType(selectedModeItem.data as JasprNewComponentOptions);
}

async function createJasprComponentWithType(data: JasprNewComponentOptions): Promise<vs.Uri | undefined> {
  // get the root of the jaspr project
  const projectDir = await getFolderToRunCommandIn("Select a Jaspr project");
  if (!projectDir) {
    return;
  }

  // ask the user where they would like the component to be created
  // it suggest lib/components and lib but also allows the user to pick a directory of their choosing
  const folderPath = await promptForComponentLocation(data, projectDir);
  if (!folderPath) {
    return;
  }

  let flutterAppName = "";
  // when creating a FlutterEmbedView, prompt for the Flutter App name
  if (data.type !== undefined && data.type === "flutter") {
    flutterAppName = await promptForFlutterName("MyFlutterApp");
  }

  // prompt for the component name
  const name = await promptForComponentName();
  if (!name) {
    return;
  }

  const success = await jasprNew(projectDir, folderPath, data, name, flutterAppName);
  if (success) {
    // open the newly created component file
    const componentFile = path.join(folderPath, toSnakeCase(name) + ".dart");
    if (fs.existsSync(componentFile)) {
      await vs.commands.executeCommand("vscode.open", vs.Uri.file(componentFile));
      return vs.Uri.file(componentFile);
    }
    return vs.Uri.file(folderPath);
  }

  return undefined;
}

// prompts the user for the component directory. This will default to lib/components 
// for components and lib/ for inherited components
async function promptForComponentLocation(
  data: JasprNewComponentOptions,
  projectDir: string
): Promise<string | undefined> {

  const defaultSubDir = data.type === "inherited" ? "lib" : "lib/components";
  const defaultPath = path.join(projectDir, defaultSubDir);

  const items: Array<vs.QuickPickItem & { value?: string }> = [
    {
      label: `$(folder) ${defaultSubDir}`,
      description: "Default location",
      value: defaultPath,
    },
    {
      label: "$(folder) lib",
      description: "Package root",
      value: path.join(projectDir, "lib"),
    },
    {
      label: "$(folder-opened) Choose other directory...",
      description: "Browse for a custom location",
      value: "browse",
    },
  ];

  const selected = await vs.window.showQuickPick(items, {
    ignoreFocusOut: true,
    placeHolder: "Select the component location",
  });
  if (!selected) {
    return undefined;
  }
  if (selected.value !== "browse") {
    return selected.value;
  }

  const folders = await vs.window.showOpenDialog({
    canSelectFolders: true,
    title: "Select the component location",
    defaultUri: vs.Uri.file(defaultPath),
  });
  if (!folders || folders.length !== 1) {
    return undefined;
  }
  return fsPath(folders[0]);
}

// prompts the user for the flutter app/widget name
async function promptForFlutterName(defaultName: string): Promise<string> {
  let flutterAppName;
  const response = await vs.window.showInputBox({
    title: "Flutter App/Widget name",
    prompt: "Specifiy the Flutter App/Widget name",
    value: defaultName,
  });
  if (response !== undefined && response.length > 0) {
    if (!isValidDartIdentifier(response)) {
      flutterAppName = defaultName;
      vs.window.showWarningMessage("'" + response + "' is  not a valid Dart identifier, will use '" + flutterAppName + "' instead.");
    } else {
      flutterAppName = response;
    }
  } else {
    flutterAppName = defaultName;
    vs.window.showWarningMessage("Setting Flutter App/Widget name to '" + flutterAppName + "'");
  }
  return flutterAppName;
}

// prompts the user for the component name, checks that the name is not empty and is
// a valid dart identifier
async function promptForComponentName(): Promise<string | undefined> {
  const name = await vs.window.showInputBox({
    ignoreFocusOut: true,
    title: "Component Name",
    prompt: "Enter a name for your new component",
    placeHolder: "MyComponent",
    validateInput: (s) => {
      if (!s.trim()) {
        return "Please enter a component name";
      }
      // check that the name is a valid dart identifier
      // The same check is performed by the CLI but we do it here to avoid errors
      if (!isValidDartIdentifier(s)) {
        return "Must be a valid Dart identifier (letters, digits, _ or $).";
      }
      return undefined;
    },
  });
  return name?.trim() || undefined;
}

function isValidDartIdentifier(name: string): boolean {
  return /^[a-zA-Z_$][a-zA-Z0-9_$]*$/.test(name.trim());
}

function toSnakeCase(name: string): string {
  return name
    .replace(/([a-z0-9])([A-Z])/g, "$1_$2")
    .replace(/[^a-zA-Z0-9_$]+/g, "_")
    .toLowerCase();
}


function getJasprComponentVariants(): Array<JapsrComponentVariant> {
  let items: Array<JapsrComponentVariant> = [
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Components",
    },
    {
      detail:
        "Stateless components are non interactive, great for static information.",
      label: "$(symbol-structure) Stateless Component",
      description: "Static component",
      data: {
        type: "stateless",
      },
    },
    {
      detail:
        "Stateful components hold state and re-render when it changes, great for interactive UIs.",
      label: "$(sync) Stateful Component",
      description: "Interactive component",
      data: {
        type: "stateful",
      },
    },
    {
      detail:
        "Async components load data asynchronously, great for fetching from an API or database.",
      label: "$(cloud) Async Component",
      description: "Async data loading",
      data: {
        type: "async",
      },
    },
    {
      detail:
        "Inherited components provide data down the widget tree, great for shared state like themes or configuration.",
      label: "$(arrow-down) Inherited Component",
      description: "Shared state",
      data: {
        type: "inherited",
      },
    },
    {
      detail:
        "Flutter embed views run a Flutter app inside a Jaspr page, great for complex client-side UIs.",
      label: "$(device-mobile) Flutter Embed View",
      description: "Embed a Flutter app",
      data: {
        type: "flutter",
        flutterEmbedOptions: ["with-sample-widget"],
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
  ];

  return items;
}

function getJasprComponentVariantsAll(): Array<vs.QuickPickItem & { data?: JasprNewComponentOptions }> {
  const items: Array<vs.QuickPickItem & { data?: JasprNewComponentOptions }> = [
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Stateless",
    },
    {
      label: "Stateless Component",
      data: {
        type: "stateless",
      },
    },
    {
      label: "Stateless Client Component",
      data: {
        type: "stateless",
        componentOptions: ["client"],
      },
    },
    {
      label: "Stateless Component with Styles",
      data: {
        type: "stateless",
        componentOptions: ["with-styles"],
      },
    },
    {
      label: "Stateless Component with Test",
      data: {
        type: "stateless",
        componentOptions: ["with-test"],
      },
    },
    {
      label: "Stateless Client Component with Test",
      data: {
        type: "stateless",
        componentOptions: ["client", "with-test"],
      },
    },
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Stateful",
    },
    {
      label: "Stateful Component",
      data: {
        type: "stateful",
      },
    },
    {
      label: "Stateful Client Component",
      data: {
        type: "stateful",
        componentOptions: ["client"],
      },
    },
    {
      label: "Stateful Component with Styles",
      data: {
        type: "stateful",
        componentOptions: ["with-styles"],
      },
    },
    {
      label: "Stateful Component with Test",
      data: {
        type: "stateful",
        componentOptions: ["with-test"],
      },
    },
    {
      label: "Stateful Client Component with Test",
      data: {
        type: "stateful",
        componentOptions: ["client", "with-test"],
      },
    },
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Async",
    },
    {
      label: "Async Component",
      data: {
        type: "async",
      },
    },
    {
      label: "Async Component with Styles",
      data: {
        type: "async",
        componentOptions: ["with-styles"],
      },
    },
    {
      label: "Async Component with Test",
      data: {
        type: "async",
        componentOptions: ["with-test"],
      },
    },
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Inherited",
    },
    {
      label: "Inherited Component",
      data: {
        type: "inherited",
      },
    },
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "Flutter Embed",
    },
    {
      label: "Flutter Embed View",
      data: {
        type: "flutter",
      },
    },
    {
      label: "Flutter Embed View with Sample Widget",
      data: {
        type: "flutter",
        flutterEmbedOptions: ["with-sample-widget"],
      },
    },
  ];

  return items;
}
