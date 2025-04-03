"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Jaspr = void 0;
const packageName = "jaspr";
const packageID = "jaspr_cli";
class Jaspr {
    pubGlobal;
    constructor(pubGlobal) {
        this.pubGlobal = pubGlobal;
    }
    installIfRequired() {
        return this.pubGlobal.installIfRequired({ packageName, packageID });
    }
}
exports.Jaspr = Jaspr;
//# sourceMappingURL=jaspr.js.map