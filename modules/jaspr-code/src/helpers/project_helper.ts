import * as fs from "fs";
import * as path from "path";
import * as YAML from "yaml";
import * as vscode from "vscode";
import { Uri } from "vscode";

import { URI } from "vscode-uri";
import { isWin } from "../constants";
import { dartExtensionApi } from "../api";

export async function findJasprProjectFolders(
): Promise<string[]> {
  let projects = await dartExtensionApi.workspace.findProjectFolders();
  projects = projects.filter(projectReferencesJaspr);
  return projects;
}

export function hasPubspec(folder: string): boolean {
  return fs.existsSync(path.join(folder, "pubspec.yaml"));
}

export function projectReferencesJaspr(folder?: string): boolean {
  if (folder && hasPubspec(folder)) {
    const pubspecPath = path.join(folder, "pubspec.yaml");
    try {
      const pubspecContent = fs.readFileSync(pubspecPath);
      return pubspecContentReferencesJaspr(pubspecContent.toString());
    } catch (e: any) {
      if (e?.code !== "ENOENT") {
        // Don't warn for missing files.
        console.warn(`Failed to read ${pubspecPath}: ${e}`);
      }
    }
  }
  return false;
}

export function pubspecContentReferencesJaspr(content: string) {
  try {
    const yaml = YAML.parse(content.toString());
    return !!(yaml?.dependencies?.jaspr || yaml?.jaspr);
  } catch {
    return false;
  }
}

export function fsPath(
  uri: URI,
  { useRealCasing = false }: { useRealCasing?: boolean } = {}
): string {
  // tslint:disable-next-line:disallow-fspath
  let newPath = typeof uri === "string" ? uri : uri.fsPath;

  if (useRealCasing) {
    const realPath = fs.existsSync(newPath) && fs.realpathSync.native(newPath);
    // Since realpathSync.native will resolve symlinks, only do anything if the paths differ
    // _only_ by case.
    // when there was no symlink (eg. the lowercase version of both paths match).
    if (
      realPath &&
      realPath.toLowerCase() === newPath.toLowerCase() &&
      realPath !== newPath
    ) {
      console.warn(
        `Rewriting path:\n  ${newPath}\nto:\n  ${realPath} because the casing appears incorrect`
      );
      newPath = realPath;
    }
  }

  newPath = forceWindowsDriveLetterToUppercase(newPath);

  return newPath;
}

export function forceWindowsDriveLetterToUppercase<
  T extends string | undefined
>(p: T): string | (undefined extends T ? undefined : never) {
  if (typeof p !== "string") {
    return undefined as undefined extends T ? undefined : never;
  }

  if (
    p &&
    isWin &&
    path.isAbsolute(p) &&
    p.startsWith(p.charAt(0).toLowerCase())
  ) {
    return p.substr(0, 1).toUpperCase() + p.substr(1);
  }

  return p;
}

export async function getFolderToRunCommandIn(
  placeHolder: string
): Promise<string | undefined> {
  // Otherwise look for what projects we have.
  const selectableFolders =
    await dartExtensionApi.workspace.findProjectFolders();
  if (!selectableFolders?.length) {
    void vscode.window.showWarningMessage(
      `No Dart project roots were found. Do you have a pubspec.yaml file?`
    );
    return undefined;
  }

  return showFolderPicker(selectableFolders, placeHolder);
}

async function showFolderPicker(
  folders: string[],
  placeHolder: string
): Promise<string | undefined> {
  // No point asking the user if there's only one.
  if (folders.length === 1) {
    return folders[0];
  }

  const items = folders
    .map((f) => {
      const workspaceFolder = vscode.workspace.getWorkspaceFolder(Uri.file(f));
      if (!workspaceFolder) {
        return undefined;
      }

      const workspacePathParent = path.dirname(fsPath(workspaceFolder.uri));
      return {
        description: workspacePathParent,
        label: path.relative(workspacePathParent, f),
        path: f,
      } as vscode.QuickPickItem & { path: string };
    })
    .filter((f) => f !== undefined);

  const selectedFolder = await vscode.window.showQuickPick(items, {
    placeHolder,
  });
  return selectedFolder && selectedFolder.path;
}
