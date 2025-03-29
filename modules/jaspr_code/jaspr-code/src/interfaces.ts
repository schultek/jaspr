import * as child_process from "child_process";
import * as stream from "stream";

export interface DartExtensionApi {
  pubGlobal: any;
  workspaceContext: any;
  safeToolSpawn: (workingDirectory: string | undefined, binPath: string, args: string[]) => SpawnedProcess;
}

export type SpawnedProcess = child_process.ChildProcess & {
	stdin: stream.Writable,
	stdout: stream.Readable,
	stderr: stream.Readable,
};