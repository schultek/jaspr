import * as path from "path";
import { dartVMPath } from "./constants";
import * as vs from "vscode";
import { dartExtensionApi } from "./api";

export type JasprMode = "static" | "server" | "client";
export type JasprModeOption = JasprMode | "static:auto" | "server:auto";
export type JasprRoutingOption = "none" | "single-page" | "multi-page";
export type JasprFlutterOption = "none" | "embedded" | "plugins-only";
export type JasprBackendOption = "none" | "shelf";

export interface JasprCreateOptions {
  readonly mode?: JasprModeOption;
  readonly routing?: JasprRoutingOption;
  readonly flutter?: JasprFlutterOption;
  readonly backend?: JasprBackendOption;
}

export async function jasprCreate(
  projectPath: string,
  options: JasprCreateOptions | undefined
): Promise<boolean> {
  const args = ["create"];

  args.push("--mode");
  args.push(options?.mode ?? "static:auto");

  args.push("--routing");
  args.push(options?.routing ?? "none");

  args.push("--flutter");
  args.push(options?.flutter ?? "none");

  if (options?.mode === "server" || options?.mode === "server:auto") {
    args.push("--backend");
    args.push(options?.backend ?? "none");
  }

  args.push(".");

  const exitCode = await runJasprInFolder(
    projectPath,
    args,
    undefined,
    undefined
  );

  return exitCode === 0;
}

export async function jasprClean(selection: vs.Uri | undefined): Promise<number | undefined> {
  return runJaspr(["clean"], selection);
}

export function jasprDoctor() {
  return runJaspr(["doctor"], undefined, true);
}

export function runJaspr(
  args: string[],
  selection: vs.Uri | undefined,
  alwaysShowOutput = false
): Thenable<number | undefined> {
  return dartExtensionApi.addDependencyCommand.runCommandForWorkspace(
    runJasprInFolder,
    `Select the folder to run "jaspr ${args.join(" ")}" in`,
    args,
    selection,
    alwaysShowOutput
  );
}

export function runJasprInFolder(
  folder: string,
  args: string[],
  shortPath: string | undefined,
  alwaysShowOutput = false
): Thenable<number | undefined> {
  const executable = path.join(
    dartExtensionApi.workspaceContext.sdks.dart,
    dartVMPath
  );

  const allArgs = ["pub", "global", "run", "jaspr_cli:jaspr", ...args];

  return dartExtensionApi.addDependencyCommand.runCommandInFolder(
    shortPath,
    folder,
    executable,
    allArgs,
    alwaysShowOutput
  );
}
