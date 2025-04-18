

// eslint-disable-next-line @typescript-eslint/naming-convention
import * as child_process from "child_process";
import * as stream from "stream";
import * as vscode from "vscode";

export const dartExtensionApi: DartExtensionApi = getDartExtensionApi();

export interface DartExtensionApi {
  pubGlobal: any;
  safeToolSpawn: (
    workingDirectory: string | undefined,
    binPath: string,
    args: string[]
  ) => SpawnedProcess;
  packagesTreeProvider: {
    projectFinder: {
      findAllProjectFolders: (
        folder: undefined,
        options: any
      ) => Promise<string[]>;
    };
  };
  addDependencyCommand: {
    runCommandInFolder: (
      shortPath: string | undefined,
      folder: string,
      binPath: string,
      args: string[],
      alwaysShowOutput: boolean
    ) => Thenable<number | undefined>;
    runCommandForWorkspace: (
      handler: (folder: string, args: string[], shortPath: string, alwaysShowOutput: boolean) => Thenable<number | undefined>,
      placeHolder: string,
      args: string[],
      selection: vscode.Uri | undefined,
      alwaysShowOutput: boolean | undefined,
    ) => Promise<number | undefined>;
  };
  workspaceContext: {
    sdks: {
      dart: string;
      flutter?: string | undefined;
    };
  };
}

export type SpawnedProcess = child_process.ChildProcess & {
  stdin: stream.Writable;
  stdout: stream.Readable;
  stderr: stream.Readable;
};

function getDartExtensionApi(): DartExtensionApi {
  const dartCode = vscode.extensions.getExtension("dart-code.dart-code");
  
    if (!dartCode) {
      // This should not happen since the Jaspr extension has a dependency on the Dart one
      // but just in case, we'd like to give a useful error message.
      throw new Error(
        "The Dart extension is not installed, Jaspr extension cannot be used."
      );
    }
  
    const dartExtensionApi = dartCode.exports._privateApi as DartExtensionApi;
    console.log(dartExtensionApi);

    return dartExtensionApi;
  }