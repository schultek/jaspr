import 'dart:convert';
import 'dart:typed_data';

/// A lightweight, GC-compliant binary parser for WebAssembly modules.
///
/// This detector scans the raw bytes of a Wasm binary to locate its `Import` section
/// (Section ID 2) and extract all imported module names and symbol names.
///
/// It parses WebAssembly GC binaries successfully by correctly decoding variable-length integers
/// (LEB128) and skipping type definitions/signatures (including references and tags) without
/// compiling or instantiating the Wasm module.
class WasmImportsDetector {
  final Uint8List bytes;
  int offset = 0;

  WasmImportsDetector(this.bytes);

  bool get isEnd => offset >= bytes.length;

  void readHeader() {
    if (bytes.length < 8) throw Exception('Invalid WASM header');
    if (bytes[0] != 0 || bytes[1] != 0x61 || bytes[2] != 0x73 || bytes[3] != 0x6d) {
      throw Exception('Invalid magic number');
    }
    offset = 8;
  }

  int readByte() {
    return bytes[offset++];
  }

  int readVarUint32() {
    var result = 0;
    var shift = 0;
    while (true) {
      final b = readByte();
      result |= (b & 0x7f) << shift;
      if ((b & 0x80) == 0) break;
      shift += 7;
    }
    return result;
  }

  int readVarInt33() {
    var result = 0;
    var shift = 0;
    var b = 0;
    while (true) {
      b = readByte();
      result |= (b & 0x7f) << shift;
      shift += 7;
      if ((b & 0x80) == 0) break;
    }
    if ((shift < 33) && (b & 0x40) != 0) {
      result |= (~0 << shift);
    }
    return result;
  }

  String readString() {
    final len = readVarUint32();
    final strBytes = bytes.sublist(offset, offset + len);
    offset += len;
    return String.fromCharCodes(strBytes);
  }

  void readValType() {
    final type = bytes[offset++];
    if (type == 0x64 || type == 0x63) {
      // ref or ref null
      readVarInt33(); // heap type
    }
  }

  List<(String, String)> getImports() {
    try {
      readHeader();
      while (!isEnd) {
        final sectionId = readByte();
        final sectionSize = readVarUint32();
        final startOffset = offset;

        if (sectionId == 2) {
          // Import section
          final count = readVarUint32();
          final imports = <(String, String)>[];
          for (var i = 0; i < count; i++) {
            final module = readString();
            final name = readString();
            final kind = readByte();

            imports.add((module, name));

            if (kind == 0) {
              // Function
              readVarUint32();
            } else if (kind == 1) {
              // Table
              readValType();
              final flags = readByte();
              readVarUint32();
              if ((flags & 1) != 0) readVarUint32();
            } else if (kind == 2) {
              // Memory
              final flags = readByte();
              readVarUint32();
              if ((flags & 1) != 0) readVarUint32();
            } else if (kind == 3) {
              // Global
              readValType();
              offset++; // mutability
            } else if (kind == 4) {
              // Tag
              offset++; // attribute
              readVarUint32(); // type index
            } else {
              return imports;
            }
          }
          return imports;
        } else {
          offset = startOffset + sectionSize;
        }
      }
    } catch (_) {
      // Return empty if malformed or failed
    }
    return [];
  }
}

String getWasmLoaderScript({
  required String basename,
  required bool isFlutter,
  List<String>? modulesNeedingSkwasm,
  bool? needsSkwasmImmediately,
}) {
  var cleanBasename = basename;
  if (cleanBasename.endsWith('.dart')) {
    cleanBasename = cleanBasename.substring(0, cleanBasename.length - 5);
  }

  if (isFlutter) {
    return _getFlutterWasmLoaderScript(
      cleanBasename: cleanBasename,
      modulesNeedingSkwasm: modulesNeedingSkwasm ?? const [],
      needsSkwasmImmediately: needsSkwasmImmediately ?? false,
    );
  } else {
    return _getStandardWasmLoaderScript(cleanBasename);
  }
}

String _getStandardWasmLoaderScript(String cleanBasename) {
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

  const imports = {};

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

String _getFlutterWasmLoaderScript({
  required String cleanBasename,
  List<String> modulesNeedingSkwasm = const [],
  bool needsSkwasmImmediately = false,
}) {
  final modulesNeedingSkwasmJson = jsonEncode(modulesNeedingSkwasm);

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

  const imports = {};
  let realSkwasmInstance = null;
  
  const modulesNeedingSkwasm = $modulesNeedingSkwasmJson;

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

  ${!needsSkwasmImmediately ? '''async function checkAndPrepareImportsForModule(moduleName) {
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
  }''' : ''}

  const moduleLoadingCache = new Map();
  function getModuleBytes(m, callback) {
    const cached = moduleLoadingCache.get(m);
    if (!!cached) return cached;
    ${needsSkwasmImmediately ? '''
    const loadPromise = fetch(relativeURL(`./\${m}`)).then((b) => callback(m, b));
    ''' : '''
    const loadPromise = (async () => {
      const response = await fetch(relativeURL(`./\${m}`));
      await checkAndPrepareImportsForModule(m.split('/').pop());
      return callback(m, response);
    })();
    '''}
    moduleLoadingCache.set(m, loadPromise);
    return loadPromise;
  }
  function loadDeferredModules(modules, handleWasmBytes) {
    return Promise.all(modules.map((m) => getModuleBytes(m, handleWasmBytes)));
  }

  let { compileStreaming } = await import(relativeURL("./$cleanBasename.mjs"));

  const baseResponse = await fetch(relativeURL("$cleanBasename.wasm"));

  ${needsSkwasmImmediately ? '''
  const skwasmInstance = await getSkwasmInstance();
  Object.assign(imports, {
    skwasm: skwasmInstance.wasmExports,
    skwasmWrapper: skwasmInstance,
    ffi: {
      memory: skwasmInstance.wasmMemory,
    },
  });
  ''' : '''
  imports.skwasmWrapper = {
    addFunction: (...args) => {
      if (!realSkwasmInstance) {
        throw new Error("skwasmWrapper.addFunction called before skwasm was loaded!");
      }
      return realSkwasmInstance.addFunction(...args);
    }
  };
  '''}

  let app = await compileStreaming(baseResponse);
  let module = await app.instantiate(imports, {
    loadDeferredModules: loadDeferredModules,
    loadDynamicModule: async (wasmUri, mjsUri) => {
      const wasmBytesPromise = fetch(relativeURL(wasmUri));
      const mjsModulePromise = import(relativeURL(mjsUri));
      
      ${needsSkwasmImmediately ? '''
      return [await wasmBytesPromise, await mjsModulePromise];
      ''' : '''
      const response = await wasmBytesPromise;
      await checkAndPrepareImportsForModule(wasmUri.split('/').pop());
      return [response, await mjsModulePromise];
      '''}
    }
  });

  ${!needsSkwasmImmediately ? '''if (document.readyState === 'complete') {
    setTimeout(getSkwasmInstance, 100);
  } else {
    window.addEventListener('load', () => {
      setTimeout(getSkwasmInstance, 100);
    });
  }''' : ''}

  module.invokeMain();
})();
''';
}
