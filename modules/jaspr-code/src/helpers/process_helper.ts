import * as child_process from "child_process";
import * as vs from "vscode";
import { checkJasprInstalled } from "./install_helper";
import { getFolderToRunCommandIn } from "./project_helper";
import path from "path";
import { isWin } from "../constants";

export type SpawnedProcess = child_process.ChildProcessWithoutNullStreams;

export async function runJasprCommand(
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

  return runJasprCommandInFolder(folderToRunCommandIn, args, alwaysShowOutput);
}

export async function runJasprCommandInFolder(
  folder: string,
  args: string[],
  alwaysShowOutput = false
): Promise<number | undefined> {
  await runJasprToOutput(folder, args, alwaysShowOutput);
  return 0;
}

export function startJaspr(args: string[], cwd: string): SpawnedProcess {
  return child_process.spawn('jaspr', args, { cwd, shell: isWin });
}

export function runJaspr(args: string[], cwd: string): Thenable<string> {
  const proc = startJaspr(args, cwd);
  return collectProcessOutput(proc);
}

async function collectProcessOutput(proc: SpawnedProcess): Promise<string> {
  return new Promise(async (resolve, reject) => {
    const stdout: string[] = [];
    const stderr: string[] = [];
    proc.stdout.on("data", (data: Buffer | string) =>
      stdout.push(data.toString())
    );
    proc.stderr.on("data", (data: Buffer | string) =>
      stderr.push(data.toString())
    );
    proc.on("error", (err) => {
      reject(`Failed to run Jaspr: ${err}`);
    });
    proc.on("close", (code) => {
      if (!code) {
        resolve(stdout.join(""));
      } else {
        reject(
          `Jaspr exited with code ${code}.\n\n${stdout.join("")}\n\n${stderr.join("")}`
        );
      }
    });
  });
}

export async function runJasprToOutput(folder: string, args: string[], alwaysShowOutput: boolean): Promise<string | undefined> {
  const packageOrFolderDisplayName = path.basename(folder);
  const commandName = "jaspr " + args[0];

  const channelName =
    commandName === packageOrFolderDisplayName
      ? commandName
      : `${commandName} (${packageOrFolderDisplayName})`;
  const channel = getOutputChannel(channelName, true);
  if (alwaysShowOutput)
    channel.show();

  return await vs.window.withProgress({
    cancellable: true,
    location: vs.ProgressLocation.Notification,
    title: `jaspr ${args.join(" ")}`,
  }, (progress, token) => {
    channel.appendLine(`[${packageOrFolderDisplayName}] jaspr ${args.join(" ")}`);

    progress.report({ message: `${packageOrFolderDisplayName}...` });

    const proc = startJaspr(args, folder);
    runProcessInOutputChannel(proc, channel);

    // If we complete with a non-zero code, or don't complete within 10s, we should show
    // the output pane.
    const completedWithErrorPromise = new Promise((resolve) => proc.on("close", resolve));
    const timedOutPromise = new Promise((resolve) => setTimeout(() => resolve(true), 10000));
    void Promise.race([completedWithErrorPromise, timedOutPromise]).then((showOutput) => {
      if (showOutput)
        channel.show(true);
    });

    return collectProcessOutput(proc);
  });
}

const channels: Record<string, vs.OutputChannel> = {};

export function getOutputChannel(name: string, insertDivider = false): vs.OutputChannel {
  if (!channels[name]) {
    channels[name] = vs.window.createOutputChannel(name);
  } else if (insertDivider) {
    const ch = channels[name];
    ch.appendLine("");
    ch.appendLine("--");
    ch.appendLine("");
  }

  return channels[name];
}
function runProcessInOutputChannel(process: SpawnedProcess, channel: vs.OutputChannel) {
  process.stdout.on("data", (data: Buffer | string) => channel.append(data.toString()));
  process.stderr.on("data", (data: Buffer | string) => channel.append(data.toString()));
  process.on("close", (code) => channel.appendLine(`exit code ${code}`));
}

