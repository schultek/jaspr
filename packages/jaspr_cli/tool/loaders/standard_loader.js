(async () => {
  const isWorker = typeof document === 'undefined';
  const thisScript = isWorker ? undefined : document.currentScript;

  function relativeURL(ref) {
    if (isWorker) {
      return new URL(ref, self.location.href).toString();
    }
    const base = thisScript?.src ?? document.baseURI;
    return new URL(ref, base).toString();
  }

  const imports = {};

  const moduleLoadingCache = new Map();
  function getModuleBytes(m, callback) {
    const cached = moduleLoadingCache.get(m);
    if (!!cached) return cached;
    const loadPromise = fetch(relativeURL(`./${m}`)).then((b) => callback(m, b));
    moduleLoadingCache.set(m, loadPromise);
    return loadPromise;
  }
  function loadDeferredModules(modules, handleWasmBytes) {
    return Promise.all(modules.map((m) => getModuleBytes(m, handleWasmBytes)));
  }

  let { compileStreaming } = await import(relativeURL("./{{cleanBasename}}.mjs"));

  let app = await compileStreaming(fetch(relativeURL("{{cleanBasename}}.wasm")));
  let module = await app.instantiate(imports, {
    loadDeferredModules: loadDeferredModules,
    loadDynamicModule: async (wasmUri, mjsUri) => {
      const wasmBytes = fetch(relativeURL(wasmUri));
      const mjsModule = import(relativeURL(mjsUri));
      return [await wasmBytes, await mjsModule];
    }
  });
  module.invokeMain();
})();
