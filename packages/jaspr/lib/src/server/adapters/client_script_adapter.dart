import 'dart:io';

import '../markup_render_object.dart';
import 'client_component_adapter.dart';
import 'head_scope_adapter.dart';

/// Adds the script of the client entrypoint to the document's head.
///
/// A standalone fragment only gets the script if it renders a @client component,
/// as it is otherwise embedded in a page that the fragment knows nothing about.
final class ClientScriptAdapter extends HeadScopeAdapter {
  ClientScriptAdapter(this.clientId, this.documentUri);

  final String clientId;
  final Uri documentUri;

  @override
  bool applyHead(MarkupRenderObject head) {
    if (binding.isStandalone && !binding.hasRenderAdapter<ClientComponentAdapter>()) {
      return false;
    }

    // Emit a relative src for documents with a base. Only the first base with an href sets the URL.
    var hasBase = false;
    final base = head.children.findWhere<MarkupRenderElement>((element) {
      if (element.tag != 'base') return false;
      hasBase = true;
      return element.attributes?['href'] != null;
    });
    final scriptSrc = hasBase ? clientId : '/$clientId';
    final baseHref = Uri.tryParse(base?.attributes?['href']?.trim() ?? '');
    final baseUri = baseHref == null ? documentUri : documentUri.resolveUri(baseHref);
    final entrypoint = baseUri.resolve(scriptSrc);
    final existingScript = head.children.findWhere<MarkupRenderElement>((element) {
      if (element.tag != 'script') return false;
      final src = element.attributes?['src']?.trim();
      if (src == null || src.isEmpty) return false;
      final uri = Uri.tryParse(src);
      if (uri == null) return false;
      final target = baseUri.resolveUri(uri);
      // Keep the author's attributes and any cache-busting query on the entrypoint.
      return target.scheme == entrypoint.scheme &&
          target.authority == entrypoint.authority &&
          target.path == entrypoint.path;
    });
    if (existingScript != null) return false;

    head.children.insertBefore(
      head.createChildRenderElement('script')..update(null, null, null, {'src': scriptSrc, 'defer': ''}, null),
    );

    return true;
  }
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
