import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Counter extends StatefulComponent {
  const Counter({super.key});

  @override
  State<Counter> createState() => CounterState();
}

class CounterState extends State<Counter> {
  int count = 0;

  @override
  Component build(BuildContext context) {
    return div([
      div(classes: 'counter', [
        button(
          onClick: () {
            setState(() => count--);
          },
          [.text('-')],
        ),
        span([.text('$count')]),
        button(
          onClick: () async {
            setState(() => count++);

            PackageInfo packageInfo = await PackageInfo.fromPlatform();

            String appName = packageInfo.appName;
            String packageName = packageInfo.packageName;
            String version = packageInfo.version;
            String buildNumber = packageInfo.buildNumber;
          },
          [.text('+')],
        ),
      ]),
    ]);
  }
}
