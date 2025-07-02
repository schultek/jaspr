import 'package:jaspr/jaspr.dart';

import '../../utils/test_component.dart';

final buildCalledFor = <Key>{};

class MyDto {
  const MyDto({
    required this.a,
    required this.b,
  });

  final int? a;
  final double? b;
}

enum ABAspect { a, b }

class App extends TestComponent<MyDto> {
  App()
      : super(
          initialValue: MyDto(a: 0, b: 0),
        );

  final child = div([ExampleComponent()]);

  static final componentKey = Key('App');

  @override
  Iterable<Component> build(BuildContext context, MyDto dto) sync* {
    buildCalledFor.add(componentKey);
    yield ABModel(
      a: dto.a,
      b: dto.b,
      child: child,
    );
  }
}

class ABModel extends InheritedModel<ABAspect> {
  const ABModel({
    super.key,
    this.a,
    this.b,
    required super.child,
  });

  final int? a;
  final double? b;

  @override
  bool updateShouldNotify(ABModel oldWidget) {
    return a != oldWidget.a || b != oldWidget.b;
  }

  @override
  bool updateShouldNotifyDependent(
    ABModel oldWidget,
    Set<ABAspect> dependencies,
  ) {
    return (a != oldWidget.a && dependencies.contains(ABAspect.a)) ||
        (b != oldWidget.b && dependencies.contains(ABAspect.b));
  }

  static int? aOf(BuildContext context) {
    return InheritedModel.inheritFrom<ABModel>(context, aspect: ABAspect.a)?.a;
  }

  static double? bOf(BuildContext context) {
    return InheritedModel.inheritFrom<ABModel>(context, aspect: ABAspect.b)?.b;
  }
}

class ExampleComponent extends StatelessComponent {
  const ExampleComponent({super.key});
  static final componentKey = Key('ExampleComponent');
  @override
  Iterable<Component> build(BuildContext context) sync* {
    buildCalledFor.add(componentKey);
    yield AComponent();
    yield BComponent();
  }
}

class AComponent extends StatelessComponent {
  const AComponent();
  static final componentKey = Key('AComponent');

  @override
  Iterable<Component> build(BuildContext context) sync* {
    buildCalledFor.add(componentKey);
    final value = ABModel.aOf(context);
    yield Text('A: $value');
  }
}

class BComponent extends StatelessComponent {
  const BComponent();
  static final componentKey = Key('BComponent');

  @override
  Iterable<Component> build(BuildContext context) sync* {
    buildCalledFor.add(componentKey);

    final value = ABModel.bOf(context);
    yield Text('B: $value');
  }
}
