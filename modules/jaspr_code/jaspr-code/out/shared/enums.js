"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.VersionStatus = void 0;
var VersionStatus;
(function (VersionStatus) {
    VersionStatus[VersionStatus["NotInstalled"] = 0] = "NotInstalled";
    VersionStatus[VersionStatus["UpdateRequired"] = 1] = "UpdateRequired";
    VersionStatus[VersionStatus["UpdateAvailable"] = 2] = "UpdateAvailable";
    VersionStatus[VersionStatus["Valid"] = 3] = "Valid";
})(VersionStatus || (exports.VersionStatus = VersionStatus = {}));
//# sourceMappingURL=enums.js.map