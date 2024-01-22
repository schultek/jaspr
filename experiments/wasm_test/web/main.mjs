  let buildArgsList;

// `modulePromise` is a promise to the `WebAssembly.module` object to be
//   instantiated.
// `importObjectPromise` is a promise to an object that contains any additional
//   imports needed by the module that aren't provided by the standard runtime.
//   The fields on this object will be merged into the importObject with which
//   the module will be instantiated.
// This function returns a promise to the instantiated module.
export const instantiate = async (modulePromise, importObjectPromise) => {
    let dartInstance;

      function stringFromDartString(string) {
        const totalLength = dartInstance.exports.$stringLength(string);
        let result = '';
        let index = 0;
        while (index < totalLength) {
          let chunkLength = Math.min(totalLength - index, 0xFFFF);
          const array = new Array(chunkLength);
          for (let i = 0; i < chunkLength; i++) {
              array[i] = dartInstance.exports.$stringRead(string, index++);
          }
          result += String.fromCharCode(...array);
        }
        return result;
    }

    function stringToDartString(string) {
        const length = string.length;
        let range = 0;
        for (let i = 0; i < length; i++) {
            range |= string.codePointAt(i);
        }
        if (range < 256) {
            const dartString = dartInstance.exports.$stringAllocate1(length);
            for (let i = 0; i < length; i++) {
                dartInstance.exports.$stringWrite1(dartString, i, string.codePointAt(i));
            }
            return dartString;
        } else {
            const dartString = dartInstance.exports.$stringAllocate2(length);
            for (let i = 0; i < length; i++) {
                dartInstance.exports.$stringWrite2(dartString, i, string.charCodeAt(i));
            }
            return dartString;
        }
    }

      // Converts a Dart List to a JS array. Any Dart objects will be converted, but
    // this will be cheap for JSValues.
    function arrayFromDartList(constructor, list) {
        const length = dartInstance.exports.$listLength(list);
        const array = new constructor(length);
        for (let i = 0; i < length; i++) {
            array[i] = dartInstance.exports.$listRead(list, i);
        }
        return array;
    }

    buildArgsList = function(list) {
        const dartList = dartInstance.exports.$makeStringList();
        for (let i = 0; i < list.length; i++) {
            dartInstance.exports.$listAdd(dartList, stringToDartString(list[i]));
        }
        return dartList;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
        wrapped.dartFunction = dartFunction;
        wrapped[jsWrappedDartFunctionSymbol] = true;
        return wrapped;
    }

    if (WebAssembly.String === undefined) {
        console.log("WebAssembly.String is undefined, adding polyfill");
        WebAssembly.String = {
            "charCodeAt": (s, i) => s.charCodeAt(i),
            "compare": (s1, s2) => {
                if (s1 < s2) return -1;
                if (s1 > s2) return 1;
                return 0;
            },
            "concat": (s1, s2) => s1 + s2,
            "equals": (s1, s2) => s1 === s2,
            "fromCharCode": (i) => String.fromCharCode(i),
            "length": (s) => s.length,
            "substring": (s, a, b) => s.substring(a, b),
        };
    }

    // Imports
    const dart2wasm = {

  _18170: s => stringToDartString(JSON.stringify(stringFromDartString(s))),
_18171: s => console.log(stringFromDartString(s)),
_18274: o => o === undefined,
_18275: o => typeof o === 'boolean',
_18276: o => typeof o === 'number',
_18278: o => typeof o === 'string',
_18281: o => o instanceof Int8Array,
_18282: o => o instanceof Uint8Array,
_18283: o => o instanceof Uint8ClampedArray,
_18284: o => o instanceof Int16Array,
_18285: o => o instanceof Uint16Array,
_18286: o => o instanceof Int32Array,
_18287: o => o instanceof Uint32Array,
_18288: o => o instanceof Float32Array,
_18289: o => o instanceof Float64Array,
_18290: o => o instanceof ArrayBuffer,
_18291: o => o instanceof DataView,
_18292: o => o instanceof Array,
_18293: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
_18296: o => o instanceof RegExp,
_18297: (l, r) => l === r,
_18298: o => o,
_18299: o => o,
_18300: o => o,
_18301: b => !!b,
_18302: o => o.length,
_18305: (o, i) => o[i],
_18306: f => f.dartFunction,
_18307: l => arrayFromDartList(Int8Array, l),
_18308: l => arrayFromDartList(Uint8Array, l),
_18309: l => arrayFromDartList(Uint8ClampedArray, l),
_18310: l => arrayFromDartList(Int16Array, l),
_18311: l => arrayFromDartList(Uint16Array, l),
_18312: l => arrayFromDartList(Int32Array, l),
_18313: l => arrayFromDartList(Uint32Array, l),
_18314: l => arrayFromDartList(Float32Array, l),
_18315: l => arrayFromDartList(Float64Array, l),
_18316: (data, length) => {
          const view = new DataView(new ArrayBuffer(length));
          for (let i = 0; i < length; i++) {
              view.setUint8(i, dartInstance.exports.$byteDataGetUint8(data, i));
          }
          return view;
        },
_18317: l => arrayFromDartList(Array, l),
_18318: stringFromDartString,
_18319: stringToDartString,
_18326: (o, p) => o[p],
_18263: (s, m) => {
          try {
            return new RegExp(s, m);
          } catch (e) {
            return String(e);
          }
        },
_18264: (x0,x1) => x0.exec(x1),
_18322: l => new Array(l),
_18330: o => String(o),
_18337: x0 => x0.length,
_18339: (x0,x1) => x0[x1],
_18343: x0 => x0.flags,
_18223: Object.is,
_18225: WebAssembly.String.concat,
_18233: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
_18183: (a, i) => a.push(i),
_18194: a => a.length,
_18196: (a, i) => a[i],
_18197: (a, i, v) => a[i] = v,
_18199: a => a.join(''),
_18203: s => s.toLowerCase(),
_18205: s => s.trim(),
_18209: (s, p, i) => s.indexOf(p, i),
_18212: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
_18213: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
_18214: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
_18215: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
_18216: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
_18217: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
_18218: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
_18221: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
_18222: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
_18224: WebAssembly.String.charCodeAt,
_18226: WebAssembly.String.substring,
_18227: WebAssembly.String.length,
_18228: WebAssembly.String.equals,
_18229: WebAssembly.String.compare,
_18230: WebAssembly.String.fromCharCode,
_18237: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
_18238: (b, o) => new DataView(b, o),
_18240: Function.prototype.call.bind(DataView.prototype.getUint8),
_18242: Function.prototype.call.bind(DataView.prototype.getInt8),
_18244: Function.prototype.call.bind(DataView.prototype.getUint16),
_18246: Function.prototype.call.bind(DataView.prototype.getInt16),
_18248: Function.prototype.call.bind(DataView.prototype.getUint32),
_18250: Function.prototype.call.bind(DataView.prototype.getInt32),
_18256: Function.prototype.call.bind(DataView.prototype.getFloat32),
_18258: Function.prototype.call.bind(DataView.prototype.getFloat64),
_18181: (c) =>
              queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
_18261: s => stringToDartString(stringFromDartString(s).toLowerCase()),
_18146: v => stringToDartString(v.toString()),
_18160: s => {
      const jsSource = stringFromDartString(s);
      if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(jsSource)) {
        return NaN;
      }
      return parseFloat(jsSource);
    },
_18161: () => {
          let stackString = new Error().stack.toString();
          let frames = stackString.split('\n');
          let drop = 2;
          if (frames[0] === 'Error') {
              drop += 1;
          }
          return frames.slice(drop).join('\n');
        },
_101: (x0,x1) => x0.item(x1),
_90: (x0,x1) => x0.querySelector(x1),
_92: f => finalizeWrapper(f,x0 => dartInstance.exports._92(f,x0)),
_93: (x0,x1) => x0.requestAnimationFrame(x1),
_48: (x0,x1) => x0.createElement(x1),
_72: (x0,x1,x2) => x0.createElementNS(x1,x2),
_73: (x0,x1) => x0.item(x1),
_74: (x0,x1) => x0.replaceWith(x1),
_75: (x0,x1) => x0.replaceWith(x1),
_76: (x0,x1) => x0.append(x1),
_77: (x0,x1) => x0.item(x1),
_78: (x0,x1) => x0.removeAttribute(x1),
_80: x0 => new Text(x0),
_81: (x0,x1) => x0.replaceWith(x1),
_82: (x0,x1) => x0.item(x1),
_83: (x0,x1) => x0.item(x1),
_84: (x0,x1,x2) => x0.insertBefore(x1,x2),
_85: (x0,x1,x2) => x0.insertBefore(x1,x2),
_86: (x0,x1) => x0.getAttribute(x1),
_87: (x0,x1) => x0.removeAttribute(x1),
_88: (x0,x1,x2) => x0.setAttribute(x1,x2),
_89: (x0,x1) => x0.item(x1),
_94: () => globalThis.jaspr,
_95: x0 => globalThis.JSON.stringify(x0),
_96: x0 => x0.sync,
_3121: x0 => x0.target,
_3162: x0 => x0.length,
_3165: x0 => x0.length,
_3212: x0 => x0.parentNode,
_3214: x0 => x0.childNodes,
_3217: x0 => x0.previousSibling,
_3218: x0 => x0.nextSibling,
_3221: (x0,x1) => x0.textContent = x1,
_3222: x0 => x0.textContent,
_3225: () => globalThis.document,
_3705: x0 => x0.tagName,
_3713: x0 => x0.attributes,
_3842: x0 => x0.length,
_3846: x0 => x0.name,
_1344: x0 => x0.checked,
_1351: x0 => x0.files,
_1394: x0 => x0.type,
_1397: (x0,x1) => x0.value = x1,
_1398: x0 => x0.value,
_1400: x0 => x0.valueAsDate,
_1402: x0 => x0.valueAsNumber,
_1478: x0 => x0.selectedOptions,
_1502: x0 => x0.value,
_1542: x0 => x0.value,
_2115: () => globalThis.window,
_51: f => finalizeWrapper(f,x0 => dartInstance.exports._51(f,x0)),
_53: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
_68: (x0,x1) => x0.appendChild(x1)
      };

    const baseImports = {
        dart2wasm: dart2wasm,

  
          Math: Math,
        Date: Date,
        Object: Object,
        Array: Array,
        Reflect: Reflect,
    };
    dartInstance = await WebAssembly.instantiate(await modulePromise, {
        ...baseImports,
        ...(await importObjectPromise),
    });

    return dartInstance;
}

// Call the main function for the instantiated module
// `moduleInstance` is the instantiated dart2wasm module
// `args` are any arguments that should be passed into the main function.
export const invoke = (moduleInstance, ...args) => {
    const dartMain = moduleInstance.exports.$getMain();
    const dartArgs = buildArgsList(args);
    moduleInstance.exports.$invokeMain(dartMain, dartArgs);
}

