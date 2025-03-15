import 'package:jaspr/jaspr.dart';

class CloseIcon extends StatelessComponent {
  CloseIcon({this.size});

  final int? size;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield _Icon(size: size, children: [
      path(d: "M18 6 6 18", []),
      path(d: "m6 6 12 12", []),
    ]);
  }
}

class MoonIcon extends StatelessComponent {
  MoonIcon({this.size});

  final int? size;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield _Icon(size: size, children: [
      path(d: 'M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z', []),
    ]);
  }
}

class SunIcon extends StatelessComponent {
  SunIcon({this.size});

  final int? size;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield _Icon(size: size, children: [
      circle(cx: '12', cy: '12', r: '4', []),
      path(d: 'M12 4h.01', []),
      path(d: 'M20 12h.01', []),
      path(d: 'M12 20h.01', []),
      path(d: 'M4 12h.01', []),
      path(d: 'M17.657 6.343h.01', []),
      path(d: 'M17.657 17.657h.01', []),
      path(d: 'M6.343 17.657h.01', []),
      path(d: 'M6.343 6.343h.01', []),
    ]);
  }
}

class _Icon extends StatelessComponent {
  _Icon({
    this.size,
    required this.children,
  });

  final int? size;
  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield svg(
        width: size?.px,
        height: size?.px,
        viewBox: "0 0 24 24",
        attributes: {
          'fill': 'none',
          'stroke': 'currentColor',
          'stroke-width': '2',
          'stroke-linecap': 'round',
          'stroke-linejoin': 'round',
        },
        children);
  }
}
