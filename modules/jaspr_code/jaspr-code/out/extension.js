"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.activate = activate;
const vscode = __importStar(require("vscode"));
const debug_1 = require("./debug");
function activate(context) {
    const dartCode = vscode.extensions.getExtension("dart-code.dart-code");
    if (!dartCode) {
        // This should not happen since the Jaspr extension has a dependency on the Dart one
        // but just in case, we'd like to give a useful error message.
        throw new Error("The Dart extension is not installed, Jaspr extension is unable to activate.");
    }
    console.log(dartCode.exports._privateApi);
    const dartExtensionApi = dartCode.exports._privateApi;
    const provider = new debug_1.JasprDebugConfigurationProvider(dartExtensionApi);
    vscode.debug.registerDebugConfigurationProvider("jaspr", provider, vscode.DebugConfigurationProviderTriggerKind.Dynamic);
    context.subscriptions.push(provider);
}
//# sourceMappingURL=extension.js.map