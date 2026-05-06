import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:jaspr_riverpod/legacy.dart';

import '../adapters/html.dart';

/// Editor keymap setting. Valid values: 'default', 'vim', 'emacs', 'sublime'
final keyMapProvider = StateProvider<String>((ref) {
  if (kIsWeb) {
    return window.localStorage['editorKeyMap'] ?? 'default';
  }
  return 'default';
});

/// Updates keymap and persists to localStorage
void toggleVimMode(BuildContext context) {
  final current = context.read(keyMapProvider);
  final next = current == 'vim' ? 'default' : 'vim';
  context.read(keyMapProvider.notifier).state = next;
  if (kIsWeb) {
    window.localStorage['editorKeyMap'] = next;
  }
}
