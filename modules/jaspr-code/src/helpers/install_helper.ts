import { cwd } from "process";
import { dartExtensionApi } from "../api";
import { runJaspr } from "./process_helper";
import * as vs from "vscode";
import { minimumJasprVersion } from "../constants";

export async function checkJasprVersion(): Promise<string | undefined> {
  let installedVersion = await getInstalledVersion();

  try {

    if (installedVersion === undefined) {
      const action = await vs.window.showWarningMessage(
        "jaspr_cli needs to be installed and available in your PATH to use this extension.",
        "Install Now"
      );

      if (action === "Install Now") {
        await dartExtensionApi.sdk.runDart(cwd(), [
          "install",
          "jaspr_cli",
        ]);
      } else {
        return undefined;
      }
    } else if (installedVersion < minimumJasprVersion) {
      const action = await vs.window.showWarningMessage(
        `Your installed version of jaspr_cli (${installedVersion}) is too old. Please update to ${minimumJasprVersion} or later.`,
        "Update Now"
      );

      if (action === "Update Now") {
        await dartExtensionApi.sdk.runDart(cwd(), [
          "install",
          "jaspr_cli",
        ]);
      } else {
        return undefined;
      }
    } else {
      return installedVersion;
    }

    installedVersion = await getInstalledVersion();
    if (installedVersion === undefined || installedVersion < minimumJasprVersion) {
      vs.window.showErrorMessage(
        `Failed to install or update Jaspr CLI. Installed version: ${installedVersion}`
      );
      return undefined;
    }
  } catch (error) {
    console.error("Error checking Jaspr version:", error);
    vs.window.showErrorMessage(
      "Failed to install Jaspr CLI. Please try running 'dart install jaspr_cli' manually."
    );
  }

  return installedVersion;
}

async function getInstalledVersion(): Promise<string | undefined> {
  try {
    const result = await runJaspr(["--version"], cwd());
    return !!result ? result : undefined;
  } catch (error) {
    return undefined;
  }
}

export async function checkJasprInstalled(): Promise<boolean> {
  const v = await checkJasprVersion();
  if (v === undefined) {
    return false;
  }
  return true;
}


