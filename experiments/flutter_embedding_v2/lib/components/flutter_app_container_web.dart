import 'package:jaspr/html.dart';

import '../widgets/app.dart';
import 'flutter_target.dart';
import 'ripple_loader.dart';

class FlutterAppContainer extends StatelessComponent {
  const FlutterAppContainer({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield FlutterTarget(
      loader: RippleLoader(),
      app: MyApp(),
    );
  }
}
