import 'dart:convert';
import 'dart:typed_data';
import 'wasm_loader_script.dart';

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
  bool isServe = false,
}) {
  var cleanBasename = basename;
  if (cleanBasename.endsWith('.dart')) {
    cleanBasename = cleanBasename.substring(0, cleanBasename.length - 5);
  }

  if (isFlutter) {
    return getFlutterWasmLoaderScript(
      cleanBasename: cleanBasename,
      modulesNeedingSkwasmJson: jsonEncode(modulesNeedingSkwasm ?? const []),
      needsSkwasmImmediately: needsSkwasmImmediately ?? false,
      isServe: isServe,
    );
  } else {
    return getStandardWasmLoaderScript(cleanBasename);
  }
}
