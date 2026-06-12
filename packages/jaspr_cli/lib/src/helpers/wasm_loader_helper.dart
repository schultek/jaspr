String getWasmLoaderScript({required String basename, required bool isFlutter}) {
  var cleanBasename = basename;
  if (cleanBasename.endsWith('.dart')) {
    cleanBasename = cleanBasename.substring(0, cleanBasename.length - 5);
  }
  return '''
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

  let imports = {};

  ${isFlutter ? '''
  const isBlink = (navigator.vendor === 'Google Inc.') || (navigator.userAgent.includes('Edg/'));
  const hasImageCodecs = typeof ImageDecoder !== "undefined" && isBlink;
  const hasChromiumBreakIterators = (typeof Intl.v8BreakIterator !== "undefined") && (typeof Intl.Segmenter !== "undefined");
  const needsHeavy = !hasImageCodecs || !hasChromiumBreakIterators;
  const fileStem = needsHeavy ? 'skwasm_heavy' : 'skwasm';

  const baseUrl = relativeURL('./canvaskit/');
  const skwasmUrl = baseUrl + fileStem + '.js';
  const wasmUrl = baseUrl + fileStem + '.wasm';

  const modulePromise = WebAssembly.compileStreaming(fetch(wasmUrl));
  const wasmInstantiator = (imports, successCallback) => {
    (async () => {
      const module = await modulePromise;
      const instance = await WebAssembly.instantiate(module, imports);
      successCallback(instance, module);
    })();
    return {};
  };

  const skwasm = await import(skwasmUrl);
  const skwasmInstance = await skwasm.default({
    skwasmSingleThreaded: !window.crossOriginIsolated,
    instantiateWasm: wasmInstantiator,
    locateFile: (filename) => {
      if (filename.endsWith('.ww.js')) {
        return URL.createObjectURL(new Blob(
          [`
"use strict";

let eventListener;
eventListener = (message) => {
    const pendingMessages = [];
    const data = message.data;
    data["instantiateWasm"] = (info,receiveInstance) => {
        const instance = new WebAssembly.Instance(data["wasm"], info);
        return receiveInstance(instance, data["wasm"])
    };
    import(data.js).then(async (skwasm) => {
        await skwasm.default(data);

        removeEventListener("message", eventListener);
        for (const message of pendingMessages) {
            dispatchEvent(message);
        }
    });
    removeEventListener("message", eventListener);
    eventListener = (message) => {

        pendingMessages.push(message);
    };

    addEventListener("message", eventListener);
};
addEventListener("message", eventListener);
`
          ],
          { 'type': 'application/javascript' }));
      }
      return baseUrl + filename;
    },
    mainScriptUrlOrBlob: skwasmUrl,
  });

  window._flutter_skwasmInstance = skwasmInstance;
  imports = {
    skwasm: skwasmInstance.wasmExports,
    skwasmWrapper: skwasmInstance,
    ffi: {
      memory: skwasmInstance.wasmMemory,
    },
  };
  ''' : ''}

  const moduleLoadingCache = new Map();
  function getModuleBytes(m, callback) {
    const cached = moduleLoadingCache.get(m);
    if (!!cached) return cached;
    const loadPromise = fetch(relativeURL(`./\${m}`)).then((b) => callback(m, b));
    moduleLoadingCache.set(m, loadPromise);
    return loadPromise;
  }
  function loadDeferredModules(modules, handleWasmBytes) {
    return Promise.all(modules.map((m) => getModuleBytes(m, handleWasmBytes)));
  }

  let { compileStreaming } = await import(relativeURL("./$cleanBasename.mjs"));

  let app = await compileStreaming(fetch(relativeURL("$cleanBasename.wasm")));
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
''';
}
