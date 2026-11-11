import 'dart:io';

import '../markup_render_object.dart';
import 'client_component_adapter.dart';
import 'head_scope_adapter.dart';

/// Adds the script of the client entrypoint to the document's head.
///
/// A standalone fragment only gets the script if it renders a @client component,
/// as it is otherwise embedded in a page that the fragment knows nothing about.
final class ClientScriptAdapter extends HeadScopeAdapter {
  ClientScriptAdapter(this.clientId);

  final String clientId;

  @override
  bool applyHead(MarkupRenderObject head) {
    if (binding.isStandalone && !binding.hasRenderAdapter<ClientComponentAdapter>()) {
      return false;
    }

    var scriptSrc = clientId;

    // Use absolute path if no base tag is present, otherwise relative to the base.
    final base = head.children.findWhere<MarkupRenderElement>((c) => c.tag == 'base');
    if (base == null) {
      scriptSrc = '/$scriptSrc';
    }

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
