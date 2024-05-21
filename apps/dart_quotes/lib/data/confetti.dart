import 'package:jaspr/jaspr.dart';

@Import.onWeb('../interop/confetti.dart', show: [#JSConfetti])
import 'confetti.imports.dart';

class ConfettiService {
  static ConfettiService instance = ConfettiService();

  void show({List<String>? emojis}) {
    JSConfetti.instance.show(emojis: emojis);
  }
}
