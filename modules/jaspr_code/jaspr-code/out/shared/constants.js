"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.noRepeatPromptThreshold = exports.fortyHoursInMs = exports.twentyHoursInMs = exports.twoHoursInMs = exports.moreInfoAction = exports.pubGlobalDocsUrl = exports.dartVMPath = exports.executableNames = exports.isWin = void 0;
exports.isWin = process.platform.startsWith("win");
exports.executableNames = {
    dart: exports.isWin ? "dart.exe" : "dart",
    dartdoc: exports.isWin ? "dartdoc.bat" : "dartdoc",
    devToolsToolBinary: exports.isWin ? "dt.bat" : "dt",
    devToolsToolLegacyBinary: exports.isWin ? "devtools_tool.bat" : "devtools_tool",
    flutter: exports.isWin ? "flutter.bat" : "flutter",
    pub: exports.isWin ? "pub.bat" : "pub",
};
exports.dartVMPath = "bin/" + exports.executableNames.dart;
exports.pubGlobalDocsUrl = "https://www.dartlang.org/tools/pub/cmd/pub-global";
exports.moreInfoAction = "More Info";
// Hours.
exports.twoHoursInMs = 1000 * 60 * 60 * 2;
exports.twentyHoursInMs = 1000 * 60 * 60 * 20;
exports.fortyHoursInMs = 1000 * 60 * 60 * 40;
// Duration for not showing a prompt that has been shown before.
exports.noRepeatPromptThreshold = exports.twentyHoursInMs;
//# sourceMappingURL=constants.js.map