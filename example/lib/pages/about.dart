import 'package:dart_web/dart_web.dart';
import 'package:dart_web_example/components/button.dart';

class About extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'span',
      child: Text('ABOUT'),
    );

    yield Button(
      label: 'Home',
      onPressed: () {
        Router.of(context).push('/');
      },
    );
  }
}
