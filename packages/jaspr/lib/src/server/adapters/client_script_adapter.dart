import 'dart:io';

import '../markup_render_object.dart';
import 'client_component_adapter.dart';
import 'document_structure_helper.dart';
import 'head_scope_adapter.dart';

/// Adds the script of the client entrypoint to the document's head.
///
/// A standalone fragment only gets the script if it renders a @client component,
/// as it is otherwise embedded in a page that the fragment knows nothing about.
final class ClientScriptAdapter extends HeadScopeAdapter {
  ClientScriptAdapter(this.clientId, this.documentUri);

  final String clientId;
  final Uri documentUri;

  late MarkupRenderObject _root;

  @override
  void apply(MarkupRenderObject root) {
    _root = root;
    super.apply(root);
  }

  @override
  bool applyHead(MarkupRenderObject head) {
    if (binding.isStandalone && !binding.hasRenderAdapter<ClientComponentAdapter>()) {
      return false;
    }

    final base = findBaseWithHref(head);
    // Emit a src relative to the base URL if one is set, otherwise from the root.
    final scriptSrc = base != null ? clientId : '/$clientId';
    final baseHref = base == null ? null : Uri.tryParse(base.attributes!['href']!.trim());
    final baseUri = baseHref == null ? documentUri : documentUri.resolveUri(baseHref);
    final entrypoint = baseUri.resolve(scriptSrc);
    // Keep a script for the entrypoint that is already anywhere in the document,
    // with the author's attributes and any cache-busting query.
    if (_loadsScript(_root, entrypoint, baseUri)) return false;

    head.children.insertBefore(
      head.createChildRenderElement('script')..update(null, null, null, {'src': scriptSrc, 'defer': ''}, null),
    );

    return true;
  }
}

/// Whether [object] or one of its descendants is a script that loads [url].
///
/// A relative `src` is resolved against [baseUri], and its query is ignored.
/// Scripts that the browser never runs are not counted, which are those in a `<noscript>`
/// or in a `<template>` that doesn't declare a shadow root.
bool _loadsScript(MarkupRenderObject object, Uri url, Uri baseUri) {
  if (object is MarkupRenderText) return false;
  if (object case MarkupRenderElement(:final tag, :final attributes)) {
    if (tag == 'script') {
      final src = attributes?['src']?.trim();
      final uri = src == null || src.isEmpty ? null : Uri.tryParse(src);
      if (uri == null) return false;
      final target = baseUri.resolveUri(uri);
      return target.scheme == url.scheme && target.authority == url.authority && target.path == url.path;
    }
    if (tag == 'noscript' || (tag == 'template' && attributes?['shadowrootmode'] == null)) return false;
  }
  return object.children.any((child) => _loadsScript(child, url, baseUri));
}

final class NoClientScriptAdapter extends HeadScopeAdapter {
  static bool _didOutputWarning = false;

  @override
  bool applyHead(MarkupRenderObject head) {
    final script = head.children.findWhere<MarkupRenderElement>(
      (c) => c.tag == 'script' && c.attributes?['src']?.endsWith('.client.dart.js') == true,
    );

    if (script != null) {
      _didOutputWarning = false;
      return false;
    }

    if (_didOutputWarning) {
      return false;
    }

    stdout.writeln(
      '[WARNING] Could not find a respective \'.client.dart\' file for the current server entrypoint, and no client '
      'script was specified\nin the document\'s <head>. This may lead to missing client-side functionality. To fix '
      'this, either:\n'
      '  - ensure that a \'.client.dart\' file with the same name as the \'.server.dart\' entrypoint exists, or\n'
      '  - add a `script(src: \'<filename>.client.dart.js\', defer: true)` to `Document(head: [...])` manually.',
    );
    _didOutputWarning = true;

    return false;
  }
}
