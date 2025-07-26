import { cwd } from "process";
import { dartExtensionApi } from "../api";
import { checkJasprInstalled } from "./install_helper";
import { getFolderToRunCommandIn } from "./project_helper";

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


export function runCommand(args: string[]): Thenable<string> {
  return new Promise(async (resolve, reject) => {
    const proc = await dartExtensionApi.sdk.startDart(cwd(), args);
    if (!proc) {
      reject("Failed to start Dart process.");
      return;
    }

    const stdout: string[] = [];
    const stderr: string[] = [];
    proc.stdout.on("data", (data: Buffer | string) =>
      stdout.push(data.toString())
    );
    proc.stderr.on("data", (data: Buffer | string) =>
      stderr.push(data.toString())
    );
    proc.on("close", (code) => {
      if (!code) {
        resolve(stdout.join(""));
      } else {
        reject(
          `Dart exited with code ${code}.\n\n${stdout.join(
            ""
          )}\n\n${stderr.join("")}`
        );
      }
    });
  });
}
