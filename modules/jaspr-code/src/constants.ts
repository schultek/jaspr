export const isWin = process.platform.startsWith("win");
export const isMac = process.platform === "darwin";
export const isLinux = !isWin && !isMac;

// Used for code checks and in Dart SDK urls so Chrome OS is considered Linux.
export const dartPlatformName = isWin ? "win" : isMac ? "mac" : "linux";


export const platformEol = isWin ? "\r\n" : "\n";

export const androidStudioExecutableNames = isWin ? ["studio64.exe"] : ["studio", "studio.sh"];
export const executableNames = {
	dart: isWin ? "dart.exe" : "dart",
	dartdoc: isWin ? "dartdoc.bat" : "dartdoc",
	devToolsToolBinary: isWin ? "dt.bat" : "dt",
	devToolsToolLegacyBinary: isWin ? "devtools_tool.bat" : "devtools_tool",
	flutter: isWin ? "flutter.bat" : "flutter",
	pub: isWin ? "pub.bat" : "pub",
};
export const getExecutableName = (cmd: string) => (executableNames as { [key: string]: string | undefined })[cmd] ?? cmd;
export const dartVMPath = "bin/" + executableNames.dart;
export const JASPR_CREATE_PROJECT_TRIGGER_FILE = 'jaspr.create';

export const minimumJasprVersion = "0.21.0";