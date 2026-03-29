import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import '../styles/theme.dart';

class SplitView extends StatefulComponent {
  const SplitView({
    required this.first,
    required this.second,
    this.initialWidth = 300,
    super.key,
  });

  final Component first;
  final Component second;
  final double initialWidth;

  @override
  State<SplitView> createState() => SplitViewState();
}

class SplitViewState extends State<SplitView> {
  late double width = component.initialWidth;
  bool isResizing = false;

  void startResizing(web.MouseEvent event) {
    setState(() => isResizing = true);
    late StreamSubscription<web.MouseEvent> moveSub;
    late StreamSubscription<web.Event> upSub;

    moveSub = web.EventStreamProviders.mouseMoveEvent.forTarget(web.window).listen((e) {
      if (!isResizing) return;
      setState(() {
        width = (web.window.innerWidth - e.clientX).toDouble();
        if (width < 200) width = 200;
        if (width > web.window.innerWidth - 300) width = web.window.innerWidth - 300;
      });
    });

    upSub = web.EventStreamProviders.mouseUpEvent.forTarget(web.window).listen((e) {
      setState(() => isResizing = false);
      moveSub.cancel();
      upSub.cancel();
    });
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'split-view', [
      div(classes: 'first', [component.first]),
      div(
        classes: 'divider ${isResizing ? 'resizing' : ''}',
        events: {'mousedown': (e) => startResizing(e as web.MouseEvent)},
        [],
      ),
      div(
        classes: 'second',
        styles: Styles(width: width.px),
        [component.second],
      ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.split-view', [
      css('&').styles(
        display: .flex,
        flex: Flex(grow: 1, shrink: 1, basis: .auto),
        overflow: .hidden,
      ),
      css('.first').styles(
        flex: Flex(grow: 1, shrink: 1, basis: .auto),
        overflow: .hidden,
        display: .flex,
        flexDirection: .column,
      ),
      css('.second').styles(
        flex: Flex(shrink: 0),
        overflow: .auto,
        backgroundColor: ThemeColors.surfaceContainerLowest,
        display: .flex,
        flexDirection: .column,
      ),
      css('.divider', [
        css('&').styles(
          width: 4.px,
          backgroundColor: ThemeColors.surfaceContainerLow,
          cursor: .colResize,
          transition: .new('all', duration: 200.ms),
          flex: Flex(shrink: 0),
          zIndex: ZIndex(10),
        ),
        css('&:hover, &.resizing').styles(
          backgroundColor: ThemeColors.primary,
          width: 4.px,
        ),
      ]),
    ]),
  ];
}
