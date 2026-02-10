export const isWin = process.platform.startsWith("win");
export const isMac = process.platform === "darwin";
export const isLinux = !isWin && !isMac;

export const JASPR_CREATE_PROJECT_TRIGGER_FILE = 'jaspr.create';
export const minimumJasprVersion = "0.21.0";