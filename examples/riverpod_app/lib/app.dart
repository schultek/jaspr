import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'components/counter.dart';

part 'app.g.dart';

@app
class App extends StatelessComponent with _$App {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ProviderScope(child: Counter());
  }
}
