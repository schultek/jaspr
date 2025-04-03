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
const constants_1 = require("../../shared/constants");
const enums_1 = require("../../shared/enums");
const logging_1 = require("../../shared/logging");
const processes_1 = require("../../shared/processes");
const utils_1 = require("../../shared/utils");
const utils_2 = require("../../shared/vscode/utils");
const processes_2 = require("../utils/processes");
class PubGlobal {
    logger;
    dartCapabilities;
    context;
    sdks;
    pubApi;
    constructor(logger, dartCapabilities, context, sdks, pubApi) {
        this.logger = logger;
        this.dartCapabilities = dartCapabilities;
        this.context = context;
        this.sdks = sdks;
        this.pubApi = pubApi;
    }
    async installIfRequired(options) {
        const packageID = options.packageID;
        const packageName = options.packageName ?? packageID;
        const moreInfoLink = options.moreInfoLink ?? constants_1.pubGlobalDocsUrl;
        const requiredVersion = options.requiredVersion;
        const silent = !!options.silent;
        const skipOptionalUpdates = !!options.skipOptionalUpdates;
        let updateSilently = !!options.updateSilently;
        let installedVersion = await this.getInstalledVersion(packageName, packageID);
        const versionStatus = await this.checkVersionStatus(packageID, installedVersion, requiredVersion);
        // If we have the latest version, or the update is not mandatory (UpdateRequired) and we were told to skip optional updates
        // just bail and use the current version.
        if (versionStatus === enums_1.VersionStatus.Valid || (skipOptionalUpdates && versionStatus === enums_1.VersionStatus.UpdateAvailable))
            return installedVersion;
        if (silent)
            updateSilently = true;
        const activateForMe = versionStatus === enums_1.VersionStatus.NotInstalled ? `Activate ${packageName}` : `Update ${packageName}`;
        const message = versionStatus === enums_1.VersionStatus.NotInstalled
            ? `${packageName} needs to be installed with 'pub global activate ${packageID}' to use this feature.`
            : (versionStatus === enums_1.VersionStatus.UpdateRequired
                ? `${packageName} needs to be updated with 'pub global activate ${packageID}' to use this feature.`
                : `A new version of ${packageName} is available and can be installed with 'pub global activate ${packageID}'.`);
        let action = 
        // If we need an update and we're allowed to auto-update, to the same as if the user
        // clicked the activate button, otherwise prompt them.
        updateSilently && ((versionStatus === enums_1.VersionStatus.UpdateRequired || versionStatus === enums_1.VersionStatus.UpdateAvailable) || silent)
            ? activateForMe
            : await vs.window.showWarningMessage(message, activateForMe, constants_1.moreInfoAction);
        if (action === constants_1.moreInfoAction) {
            await utils_2.envUtils.openInBrowser(moreInfoLink);
            return undefined;
        }
        else if (action === activateForMe) {
            const actionName = versionStatus === enums_1.VersionStatus.NotInstalled ? `Activating ${packageName}` : `Updating ${packageName}`;
            const args = ["global", "activate", packageID];
            try {
                if (silent)
                    await this.runCommand(packageName, args);
                else
                    await this.runCommandWithProgress(packageName, `${actionName}...`, args);
                installedVersion = await this.getInstalledVersion(packageName, packageID);
                const newVersionStatus = await this.checkVersionStatus(packageID, installedVersion);
                if (newVersionStatus !== enums_1.VersionStatus.Valid) {
                    this.logger.warn(`After installing ${packageID}, version status was ${enums_1.VersionStatus[newVersionStatus]} and not Valid!`);
                }
                return installedVersion;
            }
            catch (e) {
                this.logger.error(e);
                if (!silent) {
                    action = await vs.window.showErrorMessage(`${actionName} failed. Please try running 'pub global activate ${packageID}' manually.`, constants_1.moreInfoAction);
                    if (action === constants_1.moreInfoAction) {
                        await utils_2.envUtils.openInBrowser(moreInfoLink);
                    }
                }
                return undefined;
            }
        }
        return undefined;
    }
    async uninstall(packageID) {
        const args = ["global", "deactivate", packageID];
        await this.runCommand(packageID, args);
    }
    async checkVersionStatus(packageID, installedVersion, requiredVersion) {
        if (!installedVersion) {
            this.logger.info(`${packageID} has no installed version, returning NotInstalled`);
            return enums_1.VersionStatus.NotInstalled;
        }
        // If we need a specific version, check it here.
        if (requiredVersion && !(0, utils_1.pubVersionIsAtLeast)(installedVersion, requiredVersion)) {
            this.logger.info(`${packageID} version ${installedVersion} is not at least ${requiredVersion} so returning UpdateRequired`);
            return enums_1.VersionStatus.UpdateRequired;
        }
        // If we haven't checked in the last 24 hours, check if there's an update available.
        const lastChecked = this.context.getPackageLastCheckedForUpdates(packageID);
        if (!lastChecked || lastChecked <= Date.now() - constants_1.noRepeatPromptThreshold) {
            this.context.setPackageLastCheckedForUpdates(packageID, Date.now());
            try {
                const pubPackage = await this.pubApi.getPackage(packageID);
                if (!(0, utils_1.pubVersionIsAtLeast)(installedVersion, pubPackage.latest.version)) {
                    if (pubPackage.latest.retracted) {
                        this.logger.info(`${packageID} version ${installedVersion} is is retracted, so even though it's newer than ${pubPackage.latest.version}, returning Valid to avoid potentially installing repeatedly`);
                        return enums_1.VersionStatus.Valid;
                    }
                    else {
                        this.logger.info(`${packageID} version ${installedVersion} is not at least ${pubPackage.latest.version} so returning UpdateAvailable`);
                        return enums_1.VersionStatus.UpdateAvailable;
                    }
                }
            }
            catch (e) {
                // If we fail to call the API to check for a new version, then we can run
                // with what we have.
                this.logger.warn(`Failed to check for new version of ${packageID}: ${e}`, enums_1.LogCategory.CommandProcesses);
                return enums_1.VersionStatus.Valid;
            }
        }
        // Otherwise, we're installed and have a new enough version.
        this.logger.info(`${packageID} version ${installedVersion} appears to be latest so returning Valid`);
        return enums_1.VersionStatus.Valid;
    }
    async getInstalledVersion(packageName, packageID) {
        const output = await this.runCommand(packageName, ["global", "list"]);
        const versionMatch = new RegExp(`^${packageID} (\\d+\\.\\d+\\.\\d+[\\w.\\-+]*)(?: |$)`, "m");
        const match = versionMatch.exec(output);
        const installedVersion = match ? match[1] : undefined;
        return installedVersion;
    }
    runCommandWithProgress(packageName, title, args, customScript) {
        return vs.window.withProgress({
            location: vs.ProgressLocation.Notification,
            title,
        }, () => this.runCommand(packageName, args));
    }
    runCommand(packageName, args) {
        const pubExecution = (0, processes_1.getPubExecutionInfo)(this.dartCapabilities, this.sdks.dart, args);
        return new Promise((resolve, reject) => {
            this.logger.info(`Spawning ${pubExecution.executable} with args ${JSON.stringify(pubExecution.args)}`);
            const proc = (0, processes_2.safeToolSpawn)(undefined, pubExecution.executable, pubExecution.args);
            (0, logging_1.logProcess)(this.logger, enums_1.LogCategory.CommandProcesses, proc);
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
//# sourceMappingURL=pub_global.js.map