"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.dartVMPath = exports.getExecutableName = exports.executableNames = exports.androidStudioExecutableNames = exports.platformEol = exports.dartPlatformName = exports.isLinux = exports.isMac = exports.isWin = void 0;
exports.isWin = process.platform.startsWith("win");
exports.isMac = process.platform === "darwin";
exports.isLinux = !exports.isWin && !exports.isMac;
// Used for code checks and in Dart SDK urls so Chrome OS is considered Linux.
exports.dartPlatformName = exports.isWin ? "win" : exports.isMac ? "mac" : "linux";
exports.platformEol = exports.isWin ? "\r\n" : "\n";
exports.androidStudioExecutableNames = exports.isWin ? ["studio64.exe"] : ["studio", "studio.sh"];
exports.executableNames = {
    dart: exports.isWin ? "dart.exe" : "dart",
    dartdoc: exports.isWin ? "dartdoc.bat" : "dartdoc",
    devToolsToolBinary: exports.isWin ? "dt.bat" : "dt",
    devToolsToolLegacyBinary: exports.isWin ? "devtools_tool.bat" : "devtools_tool",
    flutter: exports.isWin ? "flutter.bat" : "flutter",
    pub: exports.isWin ? "pub.bat" : "pub",
};
const getExecutableName = (cmd) => exports.executableNames[cmd] ?? cmd;
exports.getExecutableName = getExecutableName;
exports.dartVMPath = "bin/" + exports.executableNames.dart;
//# sourceMappingURL=constants.js.map