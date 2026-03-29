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

class InspectLayoutIcon extends StatelessComponent {
  const InspectLayoutIcon({super.key});

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
          d:
              'M 10 17 H 5 a 2 2 0 0 1 -2 -2 V 5 a 2 2 0 0 1 2 -2 h 10 a 2 2 0 0 1 2 2 v 5 '
              'M 3 8 h 14 M 8 8 v 9 '
              'M 12 12 a .32 .32 0 0 1 .42 -.42 l 10.4 4.22 a .32 .32 0 0 1 -.04 .62 l -3.98 1.03 a 1.3 1.3 0 0 0 -.93 .93 l -1.03 3.98 a .32 .32 0 0 1 -.62 .04 z',
          [],
        ),
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
        // Wrench (background layer)
        path(
          d: 'M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z',
          [],
        ),

        // Screwdriver Eraser Outline (creates the gap in the Wrench)
        path(
          d: 'm11 12.586-2.293-2.293-1.414 1.414L3 7.414V3h4.414l4.293 4.293 1.414-1.414L15.414 8.17l-3.414 3.414Z',
          attributes: {'stroke': '#050505', 'stroke-width': '6'},
          [],
        ),
        path(
          d: 'm14.6 15 5.5 5.5a2.12 2.12 0 0 1-3 3l-5.5-5.5Z',
          attributes: {'stroke': '#050505', 'stroke-width': '6'},
          [],
        ),

        // Screwdriver Main (foreground layer)
        path(
          d: 'm11 12.586-2.293-2.293-1.414 1.414L3 7.414V3h4.414l4.293 4.293 1.414-1.414L15.414 8.17l-3.414 3.414Z',
          [],
        ),
        path(d: 'm14.6 15 5.5 5.5a2.12 2.12 0 0 1-3 3l-5.5-5.5Z', []),
        path(
          d: 'M21.2 16.2c.4-.4.8-1 .8-1.7s-.4-1.3-.8-1.7a2.38 2.38 0 0 0-1.7-.8c-.7 0-1.3.4-1.7.8L16.4 14l3.6 3.6 1.2-1.4Z',
          [],
        ),
        path(d: 'm3 3 4.4 4.4', []),
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
