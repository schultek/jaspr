"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.JasprDebugConfigurationProvider = void 0;
const process_1 = require("./process");
class JasprDebugConfigurationProvider {
    context;
    dartExtensionApi;
    constructor(context, dartExtensionApi) {
        this.context = context;
        this.dartExtensionApi = dartExtensionApi;
    }
    _disposables = [];
    dispose() {
        this._disposables.forEach((d) => d.dispose());
    }
    provideDebugConfigurations(folder, token) {
        if (folder) {
            return [];
        }
        return [
            {
                name: "Jaspr",
                request: "launch",
                type: "jaspr",
                args: [],
            },
        ];
    }
    async resolveDebugConfiguration(folder, debugConfiguration, token) {
        const process = new process_1.JasprServeProcess(this.dartExtensionApi);
        this._disposables.push(process);
        process.start(this.context, folder, debugConfiguration);
        return undefined;
    }
}
exports.JasprDebugConfigurationProvider = JasprDebugConfigurationProvider;
//# sourceMappingURL=debug.js.map