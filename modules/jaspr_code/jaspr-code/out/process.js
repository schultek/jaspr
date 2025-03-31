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
exports.JasprServeProcess = void 0;
const vscode = __importStar(require("vscode"));
const path = __importStar(require("path"));
const constants_1 = require("./constants");
let chalk;
(async () => {
    chalk = new (await import("chalk")).Chalk({ level: 1 });
})();
class JasprServeProcess {
    dartExtensionApi;
    constructor(dartExtensionApi) {
        this.dartExtensionApi = dartExtensionApi;
    }
    _disposables = [];
    emitter = new vscode.EventEmitter();
    terminal;
    sessions = [];
    process;
    status = "running";
    folder;
    randomId = 0;
    runName = "";
    async start(context, folder, debugConfiguration) {
        const isInstalled = await this.install();
        if (!isInstalled) {
            return;
        }
        this.folder = folder;
        this.randomId = Math.floor(Math.random() * 1000000);
        this.runName = debugConfiguration.name ?? "Jaspr";
        const terminalReady = new Promise((resolve) => {
            const terminal = vscode.window.createTerminal({
                name: "Jaspr",
                iconPath: vscode.Uri.file(context.asAbsolutePath("media/icons/jaspr.svg")),
                pty: {
                    onDidWrite: this.emitter.event,
                    handleInput: (data) => {
                        if (this.status === "disposed") {
                            return;
                        }
                        if (this.status === "stopped") {
                            this.dispose();
                            return;
                        }
                        if (data.length === 1 && data.charCodeAt(0) === 3) {
                            // Ctrl+C
                            this.stop();
                        }
                    },
                    open: () => resolve(terminal),
                    close: () => this.dispose(),
                },
            });
        });
        this.terminal = await terminalReady;
        this.terminal.show();
        const pubExecution = {
            args: [
                "pub",
                "global",
                "run",
                "jaspr_cli:jaspr",
                "daemon",
                ...(debugConfiguration.args ?? []),
            ],
            executable: path.join(this.dartExtensionApi.workspaceContext.sdks.dart, constants_1.dartVMPath),
        };
        this.process = this.dartExtensionApi.safeToolSpawn(folder?.uri.fsPath, pubExecution.executable, pubExecution.args);
        this.process.stdout.setEncoding("utf8");
        this.process.stdout.on("data", (data) => {
            this.handleData(data, false);
        });
        this.process.stdout.setEncoding("utf8");
        this.process.stderr.on("data", (data) => {
            this.handleData(data, true);
        });
        this.process.on("close", (code) => {
            if (!code) {
                this.emitter.fire("Jaspr Serve exited successfully.\r\n");
                this.emitter.fire("Press any key to close the terminal.\r\n");
            }
            else {
                this.emitter.fire(`Jaspr Serve exited with code ${code}.\r\n`);
                this.emitter.fire("Press any key to close the terminal.\r\n");
            }
            this.stop();
        });
        this.process.on("exit", (code) => {
            console.log("exit", code);
        });
        this._disposables.push(vscode.debug.onDidStartDebugSession((session) => {
            if (session.configuration._processId !== this.randomId) {
                return;
            }
            this.sessions.push(session);
        }));
    }
    async install() {
        const v = await this.dartExtensionApi.pubGlobal.installIfRequired({
            packageName: "jaspr",
            packageID: "jaspr_cli",
        });
        return v !== undefined;
    }
    async stop() {
        this.process?.stdin.write('[{"method":"daemon.shutdown", "id": "0"}]\n');
        const sess = this.sessions;
        this.sessions = [];
        this.status = "stopped";
        for (const session of sess) {
            vscode.debug.stopDebugging(session);
        }
    }
    async dispose() {
        this.stop();
        this.process?.kill();
        this.process = undefined;
        this.terminal?.dispose();
        this.terminal = undefined;
        this.emitter.dispose();
        this._disposables.forEach((d) => d.dispose());
        this._disposables = [];
        this.status = "disposed";
    }
    handleData(data, isError) {
        let str = data.toString();
        let lines = str.trim().split("\n");
        for (let line of lines) {
            line = line.trim();
            if (line.length === 0) {
                continue;
            }
            if (line.startsWith("[{") && line.endsWith("}]")) {
                let event;
                try {
                    const json = JSON.parse(line);
                    event = json[0];
                }
                catch (_) { }
                if (event) {
                    this.handleEvent(event);
                    continue;
                }
            }
            this.handleEvent({ event: "daemon.log", params: { message: chalk.gray(line) } });
        }
    }
    handleEvent(event) {
        var eventName = event.event;
        var params = event.params;
        if (eventName === "daemon.log") {
            let log = params.message || "";
            log = log.replaceAll("\\033", "\x1b");
            this.emitter.fire(log + "\r\n");
            return;
        }
        if (eventName === "client.debugPort") {
            this.attachDebugger("Client", params.wsUri);
            return;
        }
        if (eventName === "client.stop") {
            const session = this.sessions.find((s) => s.configuration._processId === this.randomId &&
                s.configuration._appId === params.appId);
            if (session !== undefined) {
                vscode.debug.stopDebugging(session);
            }
            return;
        }
        if (eventName === "server.started") {
            this.attachDebugger("Server", params.vmServiceUri);
            return;
        }
        //this.emitter.fire(JSON.stringify(event) + "\r\n");
    }
    attachDebugger(name, vmServiceUri) {
        if (this.sessions.find((s) => s.configuration.vmServiceUri === vmServiceUri)) {
            return;
        }
        const debugConfig = {
            name: name + " | " + this.runName,
            request: "attach",
            type: "dart",
            vmServiceUri: vmServiceUri,
            _processId: this.randomId,
        };
        vscode.debug.startDebugging(this.folder, debugConfig);
    }
}
exports.JasprServeProcess = JasprServeProcess;
//# sourceMappingURL=process.js.map