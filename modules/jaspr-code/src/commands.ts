import { checkJasprInstalled } from "./helpers/install_helper";
import { runJaspr, runJasprInFolder } from "./helpers/process_helper";

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

export type JasprTemplate = "docs";

export async function jasprCreate(
  projectPath: string,
  options: JasprCreateOptions | JasprTemplate | undefined
): Promise<boolean> {
  const isInstalled = await checkJasprInstalled();
  if (!isInstalled) {
    return false;
  }

  const args = ["create"];

  if (typeof options === "string") {
    args.push("--template");
    args.push(options);
  } else {
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
  }

  args.push(".");

  const exitCode = await runJasprInFolder(projectPath, args, undefined);

  return exitCode === 0;
}

export async function jasprClean(): Promise<number | undefined> {
  return runJaspr(["clean"]);
}

export function jasprDoctor() : Promise<number | undefined> {
  return runJaspr(["doctor"], true);
}
