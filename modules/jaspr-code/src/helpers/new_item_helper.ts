import * as vs from "vscode";
import * as path from "path";
import * as fs from "fs";
import { fsPath } from "./project_helper";

export async function promptForGenType(): Promise<string | undefined> {
  const items: Array<vs.QuickPickItem & { data?: string }> = [
    {
      kind: vs.QuickPickItemKind.Separator,
      label: "What would you like to generate?",
    },
    {
      label: "$(symbol-structure) Component",
      detail: "A reusable UI component or embedded Flutter App/Widget",
      data: "component"
    },
    {
      label: "$(browser) Page",
      detail: "A jaspr_content page, great for blogs, docs,...",
      data: "page"
    },
  ];

  let selectedModeItem = await vs.window.showQuickPick(items, {
    ignoreFocusOut: true,
    matchOnDescription: true,
    placeHolder: "Select what to generate",
  });

  return selectedModeItem?.data;
}

// prompts the user for the component directory. This will default to lib/components 
// for components and lib/ for inherited components
export async function promptForComponentLocation(
  defaultSubDir: string,
  projectDir: string
): Promise<string | undefined> {

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

// prompts the user for the component name, checks that the name is not empty and is
// a valid dart identifier
export async function promptForComponentName(title: string, prompt: string, placeHolder: string, checkDartIdentifier: boolean, optional: boolean): Promise<string | undefined> {
  const name = await vs.window.showInputBox({
    ignoreFocusOut: true,
    title: title,
    prompt: prompt,
    placeHolder: placeHolder,
    validateInput: (s) => {
      if (!s.trim() && !optional) {
        return "Please enter a name";
      }
      // check that the name is a valid dart identifier
      // The same check is performed by the CLI but we do it here to avoid errors
      if (checkDartIdentifier && !isValidDartIdentifier(s)) {
        return "Must be a valid Dart identifier (letters, digits, _ or $).";
      }
      return undefined;
    },
  });
  return name?.trim() || undefined;
}

export function isValidDartIdentifier(name: string): boolean {
  return /^[a-zA-Z_$][a-zA-Z0-9_$]*$/.test(name.trim());
}

export function toSnakeCase(name: string): string {
  return name
    .replace(/([a-z0-9])([A-Z])/g, "$1_$2")
    .replace(/[^a-zA-Z0-9_$]+/g, "_")
    .toLowerCase();
}
