import '../../dom.dart';
import '../../jaspr.dart';

class InspectIcon extends StatelessComponent {
  const InspectIcon({super.key});

  @override
  Component build(BuildContext context) {
    return svg(
      width: 20.px,
      height: 20.px,
      viewBox: '0 0 24 24',
      attributes: {
        'fill': 'none',
        'stroke': 'currentColor',
        'stroke-width': '2',
        'stroke-linecap': 'round',
        'stroke-linejoin': 'round',
      },
      [
        path(
          d: 'M4.037 4.688a.495.495 0 0 1 .651-.651l16 6.5a.5.5 0 0 1-.063.947l-6.124 1.58a2 2 0 0 0-1.438 1.435l-1.579 6.126a.5.5 0 0 1-.947.063z',
          [],
        ),
      ],
    );
  }
}

class ScanClientComponentsIcon extends StatelessComponent {
  const ScanClientComponentsIcon({super.key});

  @override
  Component build(BuildContext context) {
    return svg(
      width: 20.px,
      height: 20.px,
      viewBox: '0 0 24 24',
      attributes: {
        'fill': 'none',
        'stroke': 'currentColor',
        'stroke-width': '2',
        'stroke-linecap': 'round',
        'stroke-linejoin': 'round',
      },
      [
        path(d: 'M4 8v-2a2 2 0 0 1 2 -2h2', []),
        path(d: 'M4 16v2a2 2 0 0 0 2 2h2', []),
        path(d: 'M16 4h2a2 2 0 0 1 2 2v2', []),
        path(d: 'M16 20h2a2 2 0 0 0 2 -2v-2', []),
        path(d: 'M11 12h6', []),
        path(d: 'M8 8h5', []),
        path(d: 'M9 16h5', []),
      ],
    );
  }
}

class OpenDevToolsIcon extends StatelessComponent {
  const OpenDevToolsIcon({super.key});

  @override
  Component build(BuildContext context) {
    return svg(
      width: 20.px,
      height: 20.px,
      viewBox: '0 0 24 24',
      attributes: {
        'fill': 'none',
        'stroke': 'currentColor',
        'stroke-width': '2',
        'stroke-linecap': 'round',
        'stroke-linejoin': 'round',
      },
      [
        path(
          d: 'M4 8h8',
          [],
        ),
        path(
          d: 'M20 11.5v6.5a2 2 0 0 1 -2 2h-12a2 2 0 0 1 -2 -2v-12a2 2 0 0 1 2 -2h6.5',
          [],
        ),
        path(
          d: 'M8 4v4',
          [],
        ),
        path(
          d: 'M16 8l5 -5',
          [],
        ),
        path(
          d: 'M21 7.5v-4.5h-4.5',
          [],
        ),
      ],
    );
  }
}

class SettingsIcon extends StatelessComponent {
  const SettingsIcon({super.key});

  @override
  Component build(BuildContext context) {
    return svg(
      width: 20.px,
      height: 20.px,
      viewBox: '0 0 24 24',
      attributes: {
        'fill': 'none',
        'stroke': 'currentColor',
        'stroke-width': '2',
        'stroke-linecap': 'round',
        'stroke-linejoin': 'round',
      },
      [
        path(
          d: 'M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z',
          [],
        ),
        circle(cx: '12', cy: '12', r: '3', []),
      ],
    );
  }
}

class DragHandleIcon extends StatelessComponent {
  const DragHandleIcon({super.key});

  @override
  Component build(BuildContext context) {
    return svg(
      width: 20.px,
      height: 20.px,
      viewBox: '0 0 24 24',
      attributes: {
        'fill': 'none',
        'stroke': 'currentColor',
        'stroke-width': '2',
        'stroke-linecap': 'round',
        'stroke-linejoin': 'round',
      },
      [
        circle(cx: '9', cy: '12', r: '1', []),
        circle(cx: '9', cy: '5', r: '1', []),
        circle(cx: '9', cy: '19', r: '1', []),
        circle(cx: '15', cy: '12', r: '1', []),
        circle(cx: '15', cy: '5', r: '1', []),
        circle(cx: '15', cy: '19', r: '1', []),
      ],
    );
  }
}

class PowerIcon extends StatelessComponent {
  const PowerIcon({super.key});

  @override
  Component build(BuildContext context) {
    return svg(
      width: 16.px,
      height: 16.px,
      viewBox: '0 0 24 24',
      attributes: {
        'fill': 'none',
        'stroke': '#ff6b6b', // Light red
        'stroke-width': '2.5',
        'stroke-linecap': 'round',
        'stroke-linejoin': 'round',
      },
      [
        path(d: 'M12 2v10', []),
        path(d: 'M18.4 6.6a9 9 0 1 1-12.77.04', []),
      ],
    );
  }
}
