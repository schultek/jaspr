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
exports.getPubExecutionInfo = getPubExecutionInfo;
exports.safeToolSpawn = safeToolSpawn;
exports.safeSpawn = safeSpawn;
const child_process = __importStar(require("child_process"));
const path = __importStar(require("path"));
const constants_1 = require("./constants");
function getPubExecutionInfo(dartSdkPath, args) {
    return {
        args: ["pub", ...args],
        executable: path.join(dartSdkPath, constants_1.dartVMPath),
    };
}
function safeToolSpawn(workingDirectory, binPath, args, envOverrides) {
    const env = Object.assign({}, toolEnv, envOverrides);
    return safeSpawn(workingDirectory, binPath, args, env);
}
const simpleCommandRegex = new RegExp("^[\\w\\-.]+$");
function safeSpawn(workingDirectory, binPath, args, env) {
    const customEnv = Object.assign({}, process.env, env);
    // On Windows we need to use shell-execute for running `.bat` files.
    // Try to limit when we use this, because terminating a shell might not terminate
    // the spawned process, so not using shell-execute may improve reliability of
    // terminating processes.
    if (constants_1.isWin && binPath.endsWith(".bat")) {
        const quotedArgs = args.map(quoteAndEscapeArg);
        // Putting quotes around something like "git" will cause it to fail, so don't do it if binPath is just a single identifier.
        binPath = simpleCommandRegex.test(binPath) ? binPath : `"${binPath}"`;
        return child_process.spawn(binPath, quotedArgs, { cwd: workingDirectory, env: customEnv, shell: true });
    }
    return child_process.spawn(binPath, args, { cwd: workingDirectory, env: customEnv });
}
function quoteAndEscapeArg(arg) {
    // Spawning processes on Windows with funny symbols in the path requires quoting. However if you quote an
    // executable with a space in its path and an argument also has a space, you have to then quote _all_ of the
    // arguments!
    // https://github.com/nodejs/node/issues/7367
    let escaped = arg.replace(/"/g, `\\"`).replace(/`/g, "\\`");
    // Additionally, on Windows escape redirection symbols with ^ if they come
    // directly after quotes (?).
    // https://ss64.com/nt/syntax-esc.html
    if (constants_1.isWin)
        escaped = escaped.replace(/"([<>])/g, "\"^$1");
    return `"${escaped}"`;
}
//# sourceMappingURL=processes.js.map