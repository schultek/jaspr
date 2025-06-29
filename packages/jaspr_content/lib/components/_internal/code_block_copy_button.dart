import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import 'icon.dart';

@client
class CodeBlockCopyButton extends StatefulComponent {
  const CodeBlockCopyButton({
    super.key,
  });

  @override
  State<CodeBlockCopyButton> createState() => _CodeBlockCopyButtonState();
}

class _CodeBlockCopyButtonState extends State<CodeBlockCopyButton> {
  bool _copied = false;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield button(events: {
      'click': (event) {
        final target = event.currentTarget as web.Element;
        final content = target.parentElement?.querySelector('pre code')?.textContent;
        if (content == null) {
          return;
        }
        web.window.navigator.clipboard.writeText(content);
        setState(() {
          _copied = true;
        });
        Timer(const Duration(seconds: 2), () {
          setState(() {
            _copied = false;
          });
        });
      }
    }, [
      _copied ? CheckIcon(size: 18) : CopyIcon(size: 18),
    ]);
  }
}
