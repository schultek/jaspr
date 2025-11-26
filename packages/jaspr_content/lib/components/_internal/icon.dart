/// A collection of icons used in the application.
///
/// The icon paths are sourced from lucide icons (https://lucide.dev/icons).
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A close icon.
class CloseIcon extends StatelessComponent {
  const CloseIcon({this.size});

  final int? size;

  @override
  Component build(BuildContext context) {
    return _Icon(
      size: size,
      children: [
        path(d: "M18 6 6 18", []),
        path(d: "m6 6 12 12", []),
      ],
    );
  }
}

/// A moon icon.
class MoonIcon extends StatelessComponent {
  MoonIcon({this.size});

  final int? size;

  @override
  Component build(BuildContext context) {
    return _Icon(
      size: size,
      children: [path(d: 'M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z', [])],
    );
  }
}

/// A sun icon.
class SunIcon extends StatelessComponent {
  SunIcon({this.size});

  final int? size;

  @override
  Component build(BuildContext context) {
    return _Icon(
      size: size,
      children: [
        circle(cx: '12', cy: '12', r: '4', []),
        path(d: 'M12 4h.01', []),
        path(d: 'M20 12h.01', []),
        path(d: 'M12 20h.01', []),
        path(d: 'M4 12h.01', []),
        path(d: 'M17.657 6.343h.01', []),
        path(d: 'M17.657 17.657h.01', []),
        path(d: 'M6.343 17.657h.01', []),
        path(d: 'M6.343 6.343h.01', []),
      ],
    );
  }
}

/// An info icon.
class InfoIcon extends StatelessComponent {
  InfoIcon({this.size});

  final int? size;

  @override
  Component build(BuildContext context) {
    return _Icon(
      size: size,
      children: [
        circle(cx: '12', cy: '12', r: '10', []),
        path(d: 'M12 16v-4', []),
        path(d: 'M12 8h.01', []),
      ],
    );
  }
}

/// An alert icon.
class AlertIcon extends StatelessComponent {
  AlertIcon({this.size});

  final int? size;

  @override
  Component build(BuildContext context) {
    return _Icon(
      size: size,
      children: [
        path(d: 'm21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3', []),
        path(d: 'M12 9v4', []),
        path(d: 'M12 17h.01', []),
      ],
    );
  }
}

class CircleXIcon extends StatelessComponent {
  CircleXIcon({this.size});

  final int? size;

  @override
  Component build(BuildContext context) {
    return _Icon(
      size: size,
      children: [
        circle(cx: '12', cy: '12', r: '10', []),
        path(d: 'm15 9-6 6', []),
        path(d: 'm9 9 6 6', []),
      ],
    );
  }
}

class CircleCheckIcon extends StatelessComponent {
  CircleCheckIcon({this.size});

  final int? size;

  @override
  Component build(BuildContext context) {
    return _Icon(
      size: size,
      children: [
        circle(cx: '12', cy: '12', r: '10', []),
        path(d: 'm9 12 2 2 4-4', []),
      ],
    );
  }
}

class CopyIcon extends StatelessComponent {
  CopyIcon({this.size});

  final int? size;

  @override
  Component build(BuildContext context) {
    return _Icon(
      size: size,
      children: [
        rect(width: "14", height: "14", x: "8", y: "8", attributes: {'rx': "2", 'ry': "2"}, []),
        path(d: "M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2", []),
      ],
    );
  }
}

class CheckIcon extends StatelessComponent {
  CheckIcon({this.size});

  final int? size;

  @override
  Component build(BuildContext context) {
    return _Icon(
      size: size,
      children: [path(d: 'M20 6 9 17l-5-5', [])],
    );
  }
}

class _Icon extends StatelessComponent {
  _Icon({this.size, required this.children});

  final int? size;
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return svg(
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
      children,
    );
  }
}
