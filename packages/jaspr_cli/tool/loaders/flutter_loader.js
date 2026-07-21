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
  let realSkwasmInstance = null;

  // #if !isServe
  const modulesNeedingSkwasm = "{{modulesNeedingSkwasmJson}}";
  // #endif

  const isBlink = (navigator.vendor === 'Google Inc.') || (navigator.userAgent.includes('Edg/'));
  const hasImageCodecs = typeof ImageDecoder !== "undefined" && isBlink;
  const hasChromiumBreakIterators = (typeof Intl.v8BreakIterator !== "undefined") && (typeof Intl.Segmenter !== "undefined");
  const needsHeavy = !hasImageCodecs || !hasChromiumBreakIterators;
  const fileStem = needsHeavy ? 'skwasm_heavy' : 'skwasm';

  const baseUrl = relativeURL('./canvaskit/');
  const skwasmUrl = baseUrl + fileStem + '.js';
  const wasmUrl = baseUrl + fileStem + '.wasm';

  let modulePromise = null;
  const wasmInstantiator = (imports, successCallback) => {
    (async () => {
      if (!modulePromise) {
        modulePromise = WebAssembly.compileStreaming(fetch(wasmUrl));
      }
      const module = await modulePromise;
      const instance = await WebAssembly.instantiate(module, imports);
      successCallback(instance, module);
    })();
    return {};
  };

  // #if isServe
  function getWasmImportsDetail(arrayBuffer) {
    const bytes = new Uint8Array(arrayBuffer);
    if (bytes.length < 8) return [];
    if (bytes[0] !== 0 || bytes[1] !== 0x61 || bytes[2] !== 0x73 || bytes[3] !== 0x6d) {
      return [];
    }

    let offset = 8;

    function readVarUint32() {
      let result = 0;
      let shift = 0;
      while (true) {
        if (offset >= bytes.length) return 0;
        const b = bytes[offset++];
        result |= (b & 0x7f) << shift;
        if ((b & 0x80) === 0) break;
        shift += 7;
      }
      return result;
    }

    function readVarInt33() {
      let result = 0;
      let shift = 0;
      let b;
      while (true) {
        if (offset >= bytes.length) return 0;
        b = bytes[offset++];
        result |= (b & 0x7f) << shift;
        shift += 7;
        if ((b & 0x80) === 0) break;
      }
      if ((shift < 33) && (b & 0x40)) {
        result |= (~0 << shift);
      }
      return result;
    }

    function readString() {
      const len = readVarUint32();
      if (offset + len > bytes.length) return "";
      const strBytes = bytes.subarray(offset, offset + len);
      offset += len;
      return new TextDecoder().decode(strBytes);
    }

    function readValType() {
      const type = bytes[offset++];
      if (type === 0x64 || type === 0x63) {
        readVarInt33();
      }
    }

    while (offset < bytes.length) {
      const sectionId = bytes[offset++];
      const sectionSize = readVarUint32();
      const sectionEnd = offset + sectionSize;

      if (sectionId === 2) {
        const count = readVarUint32();
        const importsList = [];
        for (let i = 0; i < count; i++) {
          if (offset >= sectionEnd) break;
          const module = readString();
          const name = readString();
          if (offset >= sectionEnd) break;
          const kind = bytes[offset++];

          importsList.push({ module, name });

          if (kind === 0) {
            readVarUint32();
          } else if (kind === 1) {
            readValType();
            const flags = bytes[offset++];
            readVarUint32();
            if ((flags & 1) !== 0) readVarUint32();
          } else if (kind === 2) {
            const flags = bytes[offset++];
            readVarUint32();
            if ((flags & 1) !== 0) readVarUint32();
          } else if (kind === 3) {
            readValType();
            offset++;
          } else if (kind === 4) {
            offset++;
            readVarUint32();
          } else {
            return importsList;
          }
        }
        return importsList;
      } else {
        offset = sectionEnd;
      }
    }
    return [];
  }
  // #endif

  let skwasmInstancePromise = null;
  function getSkwasmInstance() {
    if (skwasmInstancePromise) return skwasmInstancePromise;
    skwasmInstancePromise = (async () => {
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
      realSkwasmInstance = skwasmInstance;
      return skwasmInstance;
    })();
    return skwasmInstancePromise;
  }
  window.__loadSkwasmInstance = getSkwasmInstance;

  // #if isServe
  async function checkAndPrepareImportsForModule(response) {
    const bytes = await response.clone().arrayBuffer();
    const moduleImports = getWasmImportsDetail(bytes);
    const needsSkwasm = moduleImports.some(imp => imp.module === 'skwasm' || imp.module === 'skwasmWrapper' || imp.module === 'ffi');
    if (needsSkwasm) {
      const skwasmInstance = await getSkwasmInstance();
      Object.assign(imports, {
        skwasm: skwasmInstance.wasmExports,
        skwasmWrapper: skwasmInstance,
        ffi: {
          memory: skwasmInstance.wasmMemory,
        },
      });
    }
  }
  // #else
  async function checkAndPrepareImportsForModule(moduleName, response) {
    if (modulesNeedingSkwasm.includes(moduleName)) {
      const skwasmInstance = await getSkwasmInstance();
      Object.assign(imports, {
        skwasm: skwasmInstance.wasmExports,
        skwasmWrapper: skwasmInstance,
        ffi: {
          memory: skwasmInstance.wasmMemory,
        },
      });
    }
  }
  // #endif


  const moduleLoadingCache = new Map();
  function getModuleBytes(m, callback) {
    const cached = moduleLoadingCache.get(m);
    if (!!cached) return cached;
    const loadPromise = (async () => {
      const response = await fetch(relativeURL(`./${m}`));
      // #if isServe
      await checkAndPrepareImportsForModule(response);
      // #else
      await checkAndPrepareImportsForModule(m.split('/').pop(), response);
      // #endif
      return callback(m, response);
    })();
    moduleLoadingCache.set(m, loadPromise);
    return loadPromise;
  }
  function loadDeferredModules(modules, handleWasmBytes) {
    return Promise.all(modules.map((m) => getModuleBytes(m, handleWasmBytes)));
  }

  let { compileStreaming } = await import(relativeURL("./{{cleanBasename}}.mjs"));

  const baseResponse = await fetch(relativeURL("{{cleanBasename}}.wasm"));

  // #if isServe
  const baseBytes = await baseResponse.clone().arrayBuffer();
  const baseImports = getWasmImportsDetail(baseBytes);
  const hasSkwasm = baseImports.some(imp => imp.module === 'skwasm' || imp.module === 'ffi');
  const skwasmWrapperImports = baseImports.filter(imp => imp.module === 'skwasmWrapper');
  const hasOnlyAddFunction = skwasmWrapperImports.every(imp => imp.name === 'addFunction');
  const needsSkwasmImmediately = hasSkwasm || (skwasmWrapperImports.length > 0 && !hasOnlyAddFunction);
  // #endif

  // #if isServe
  if (needsSkwasmImmediately) {
    const skwasmInstance = await getSkwasmInstance();
    Object.assign(imports, {
      skwasm: skwasmInstance.wasmExports,
      skwasmWrapper: skwasmInstance,
      ffi: {
        memory: skwasmInstance.wasmMemory,
      },
    });
  } else {
    imports.skwasmWrapper = {
      addFunction: (...args) => {
        if (!realSkwasmInstance) {
          throw new Error("skwasmWrapper.addFunction called before skwasm was loaded!");
        }
        return realSkwasmInstance.addFunction(...args);
      }
    };
  }
  // #else
  // #if needsSkwasmImmediately
  const skwasmInstance = await getSkwasmInstance();
  Object.assign(imports, {
    skwasm: skwasmInstance.wasmExports,
    skwasmWrapper: skwasmInstance,
    ffi: {
      memory: skwasmInstance.wasmMemory,
    },
  });
  // #else
  imports.skwasmWrapper = {
    addFunction: (...args) => {
      if (!realSkwasmInstance) {
        throw new Error("skwasmWrapper.addFunction called before skwasm was loaded!");
      }
      return realSkwasmInstance.addFunction(...args);
    }
  };
  // #endif
  // #endif

  let app = await compileStreaming(baseResponse);
  let module = await app.instantiate(imports, {
    loadDeferredModules: loadDeferredModules,
    loadDynamicModule: async (wasmUri, mjsUri) => {
      const wasmBytesPromise = fetch(relativeURL(wasmUri));
      const mjsModulePromise = import(relativeURL(mjsUri));

      const response = await wasmBytesPromise;
      // #if isServe
      await checkAndPrepareImportsForModule(response);
      // #else
      await checkAndPrepareImportsForModule(wasmUri.split('/').pop(), response);
      // #endif
      return [response, await mjsModulePromise];
    }
  });

  module.invokeMain();
})();
