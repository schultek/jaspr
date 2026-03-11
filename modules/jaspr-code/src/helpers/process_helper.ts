import { cwd } from "process";
import { dartExtensionApi } from "../api";
import { checkJasprInstalled } from "./install_helper";
import { getFolderToRunCommandIn } from "./project_helper";
import { SpawnedProcess } from "dart-code/src/shared/interfaces";

export async function runJaspr(
  args: string[],
  alwaysShowOutput = false
): Promise<number | undefined> {
  const isInstalled = await checkJasprInstalled();
  if (!isInstalled) {
    return;
  }

  const folderToRunCommandIn = await getFolderToRunCommandIn(
    `Select the folder to run "jaspr ${args.join(" ")}" in`
  );
  if (!folderToRunCommandIn) {
    return;
  }

  return runJasprInFolder(folderToRunCommandIn, args, alwaysShowOutput);
}

export async function runJasprInFolder(
  folder: string,
  args: string[],
  alwaysShowOutput = false
): Promise<number | undefined> {
  const allArgs = ["global", "run", "jaspr_cli:jaspr", ...args];

  const result = await dartExtensionApi.sdk.runPub(folder, allArgs, {
    alwaysShowOutput: alwaysShowOutput,
  });
  return result?.exitCode;
}

export async function runCommand(args: string[]): Promise<string> {
  const proc = await dartExtensionApi.sdk.startDart(cwd(), args);
  if (!proc) {
    throw "Failed to start Dart process.";
  }

  const result = await runProcess(proc);
  if (!result.exitCode) {
    return result.stdout;
  } else {
    throw `Dart exited with code ${result.exitCode}.\n\n${result.stdout}\n\n${result.stderr}`;
  }
}

export function runProcess(proc: SpawnedProcess): Thenable<{stdout: string, stderr: string, exitCode: number}> {
  return new Promise(async (resolve) => {
    const stdout: string[] = [];
    const stderr: string[] = [];
    proc.stdout.on("data", (data: Buffer | string) =>
      stdout.push(data.toString())
    );
    proc.stderr.on("data", (data: Buffer | string) =>
      stderr.push(data.toString())
    );
    proc.on("close", (code) => {
      resolve({stdout: stdout.join(""), stderr: stderr.join(""), exitCode: code || 0});
    });
  });
}
