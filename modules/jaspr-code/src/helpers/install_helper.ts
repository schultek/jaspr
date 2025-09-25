import { cwd } from "process";
import { dartExtensionApi } from "../api";
import { runCommand } from "./process_helper";
import * as vs from "vscode";
import { minimumJasprVersion } from "../constants";

export async function checkJasprVersion(): Promise<string | undefined> {
  let installedVersion = await getInstalledVersion();

  try {
    if (installedVersion === undefined) {
      const action = await vs.window.showWarningMessage(
        "jaspr_cli needs to be installed with 'pub global activate jaspr_cli' to use this extension.",
        "Install Now"
      );

      if (action === "Install Now") {
        await dartExtensionApi.sdk.runPub(cwd(), [
          "global",
          "activate",
          "jaspr_cli",
        ]);
      } else {
        return installedVersion;
      }
    } else if (installedVersion < minimumJasprVersion) {
      const action = await vs.window.showWarningMessage(
        `Your installed version of jaspr_cli (${installedVersion}) is too old. Please update to ${minimumJasprVersion} or later.`,
        "Update Now"
      );

      if (action === "Update Now") {
        await dartExtensionApi.sdk.runPub(cwd(), [
          "global",
          "activate",
          "jaspr_cli",
        ]);
      } else {
        return installedVersion;
      }
    }

    installedVersion = await getInstalledVersion();
    if (installedVersion === undefined || installedVersion < minimumJasprVersion) {
      throw new Error(
        `Failed to install or update Jaspr CLI. Installed version: ${installedVersion}`
      );
    }
  } catch (error) {
    console.error("Error checking Jaspr version:", error);
    vs.window.showErrorMessage(
      "Failed to install Jaspr CLI. Please try running 'pub global activate jaspr_cli' manually."
    );
  }

  return installedVersion;
}

async function getInstalledVersion(): Promise<string | undefined> {
  try {
    const result = await runCommand(["pub", "global", "list"]);
    const versionMatch = new RegExp(
      `^jaspr_cli (\\d+\\.\\d+\\.\\d+[\\w.\\-+]*)(?: |$)`,
      "m"
    );
    const match = versionMatch.exec(result);
    const installedVersion = match ? match[1] : undefined;

    return installedVersion;
  } catch (error) {
    return undefined;
  }
}

export async function checkJasprInstalled(): Promise<boolean> {
  const v = await checkJasprVersion();
  if (v === undefined) {
    return false;
  }
  if (v < minimumJasprVersion) {
    await vs.window.showErrorMessage(
      `Jaspr CLI version is too old. Please update to ${minimumJasprVersion} or later.`
    );
    return false;
  }
  return true;
}
