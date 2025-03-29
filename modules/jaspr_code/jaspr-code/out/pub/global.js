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
exports.PubGlobal = void 0;
const vs = __importStar(require("vscode"));
const processes_1 = require("../shared/processes");
const processes_2 = require("../shared/processes");
class PubGlobal {
    sdks;
    constructor(sdks) {
        this.sdks = sdks;
    }
    async installIfRequired(options) {
        const packageID = options.packageID;
        const packageName = options.packageName ?? packageID;
        let installedVersion = await this.getInstalledVersion(packageName, packageID);
        if (installedVersion !== undefined) {
            return installedVersion;
        }
        const activateForMe = `Activate ${packageName}`;
        const message = `${packageName} needs to be installed with 'pub global activate ${packageID}' to use this feature.`;
        let action = 
        // If we need an update and we're allowed to auto-update, to the same as if the user
        // clicked the activate button, otherwise prompt them.
        await vs.window.showWarningMessage(message, activateForMe);
        if (action === activateForMe) {
            const actionName = `Activating ${packageName}`;
            const args = ["global", "activate", packageID];
            try {
                await this.runCommandWithProgress(packageName, `${actionName}...`, args);
                installedVersion = await this.getInstalledVersion(packageName, packageID);
                return installedVersion;
            }
            catch (e) {
                action = await vs.window.showErrorMessage(`${actionName} failed. Please try running 'pub global activate ${packageID}' manually.`);
                return undefined;
            }
        }
        return undefined;
    }
    async uninstall(packageID) {
        const args = ["global", "deactivate", packageID];
        await this.runCommand(packageID, args);
    }
    async getInstalledVersion(packageName, packageID) {
        const output = await this.runCommand(packageName, ["global", "list"]);
        const versionMatch = new RegExp(`^${packageID} (\\d+\\.\\d+\\.\\d+[\\w.\\-+]*)(?: |$)`, "m");
        const match = versionMatch.exec(output);
        const installedVersion = match ? match[1] : undefined;
        return installedVersion;
    }
    runCommandWithProgress(packageName, title, args) {
        return vs.window.withProgress({
            location: vs.ProgressLocation.Notification,
            title,
        }, () => this.runCommand(packageName, args));
    }
    runCommand(packageName, args) {
        const pubExecution = (0, processes_1.getPubExecutionInfo)(this.sdks.dart, args);
        return new Promise((resolve, reject) => {
            this.logger.info(`Spawning ${pubExecution.executable} with args ${JSON.stringify(pubExecution.args)}`);
            const proc = (0, processes_2.safeToolSpawn)(undefined, pubExecution.executable, pubExecution.args);
            const stdout = [];
            const stderr = [];
            proc.stdout.on("data", (data) => stdout.push(data.toString()));
            proc.stderr.on("data", (data) => stderr.push(data.toString()));
            proc.on("close", (code) => {
                if (!code) {
                    resolve(stdout.join(""));
                }
                else {
                    reject(`${packageName} exited with code ${code}.\n\n${stdout.join("")}\n\n${stderr.join("")}`);
                }
            });
        });
    }
}
exports.PubGlobal = PubGlobal;
//# sourceMappingURL=global.js.map