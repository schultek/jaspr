import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' hide Document;

import '../../theme.dart';

@client
class ZoomableImage extends StatefulComponent {
  ZoomableImage({
    required this.src,
    this.alt,
    this.caption,
    super.key,
  });

  final String src;
  final String? alt;
  final String? caption;

  @override
  State<StatefulComponent> createState() => _ZoomableImageState();

  @css
  static List<StyleRule> get styles => [
        css('figure.image', [
          css('&.zoomable img').styles(
            cursor: Cursor.zoomIn,
          ),
        ]),
        css('dialog.zoom-modal', [
          css('&').styles(
            width: 100.vw,
            height: 100.vh,
            maxWidth: Unit.initial,
            maxHeight: Unit.initial,
            margin: Margin.zero,
            padding: Padding.zero,
            border: Border.none,
            backgroundColor: Colors.transparent,
            overflow: Overflow.hidden,
            outline: Outline(style: OutlineStyle.none),
          ),
          css('.image-wrapper').styles(
            position: Position.relative(),
            width: 100.percent,
            height: 100.percent,
            backgroundColor: ContentColors.background,
          ),
          css('img').styles(
            position: Position.absolute(),
            cursor: Cursor.zoomOut,
            transition: Transition('transform', duration: 300),
            raw: {
              'transform-origin': 'top left',
            },
          ),
        ]),
      ];
}

class _ZoomableImageState extends State<ZoomableImage> with ViewTransitionMixin {
  static int _dialogCount = 0;

  late final HTMLDialogElement dialog;
  final GlobalNodeKey<HTMLImageElement> imageKey = GlobalNodeKey();

  StreamSubscription<Event>? _cancelSub;
  StreamSubscription<Event>? _resizeSub;
  void Function(void Function())? dialogSetState;

  bool zoomed = false;
  bool isResize = false;

  var sourceOffset = (x: 0.0, y: 0.0, scale: 1.0);
  var targetOffset = (x: 0.0, y: 0.0, width: 0.0, height: 0.0);

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      context.binding.addPostFrameCallback(() {
        dialog = HTMLDialogElement()
          ..id = 'dzm${_dialogCount++}'
          ..className = 'zoom-modal';
        window.document.body!.appendChild(dialog);

        _cancelSub = EventStreamProviders.cancelEvent.forTarget(dialog).listen((e) {
          e.preventDefault();
          zoomOut();
        });

        updateImageOffset(false);

        (runApp as dynamic)(StatefulBuilder(builder: (context, setState) {
          dialogSetState = setState;
          return _buildDialog(context);
        }), attachTo: '#${dialog.id}');
      });

      _resizeSub = EventStreamProviders.resizeEvent.forTarget(window).listen((_) {
        updateImageOffset(true);
      });
    }
  }

  void updateImageOffset(bool isResize) {
    var sourceRect = imageKey.currentNode?.getBoundingClientRect();
    if (sourceRect == null) return;

    var sourceAspect = sourceRect.width / sourceRect.height;
    var windowAspect = window.innerWidth / window.innerHeight;

    final sourceScale = windowAspect > sourceAspect //
        ? sourceRect.height / window.innerHeight
        : sourceRect.width / window.innerWidth;

    final targetOffsetX = windowAspect > sourceAspect ? (window.innerWidth - sourceRect.width / sourceScale) / 2 : 0.0;
    final targetOffsetY =
        windowAspect > sourceAspect ? 0.0 : (window.innerHeight - sourceRect.height / sourceScale) / 2;

    setState(() {
      sourceOffset = (x: sourceRect.left, y: sourceRect.top, scale: sourceScale);
      targetOffset = (
        x: targetOffsetX,
        y: targetOffsetY,
        width: sourceRect.width / sourceScale,
        height: sourceRect.height / sourceScale
      );
      this.isResize = isResize;
    });
    dialogSetState?.call(() {});
  }

  void zoomIn() {
    updateImageOffset(false);

    setState(() {
      zoomed = true;
    });
    dialogSetState?.call(() {});
    document.body!.style.overflow = 'hidden';
    dialog.showModal();
  }

  void zoomOut() async {
    setState(() {
      zoomed = false;
    });
    dialogSetState?.call(() {});
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (zoomed) return;
    dialog.close();
    document.body!.style.overflow = 'auto';
  }

  @override
  void dispose() {
    _cancelSub?.cancel();
    _resizeSub?.cancel();
    dialog.remove();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return figure(classes: 'image zoomable', [
      img(
        key: imageKey,
        src: component.src,
        alt: component.alt ?? component.caption,
        styles: zoomed ? Styles(visibility: Visibility.hidden) : null,
        events: events<void, void>(onClick: () {
          zoomIn();
        }),
      ),
      if (component.caption != null) figcaption([text(component.caption!)]),
    ]);
  }

  Component _buildDialog(BuildContext context) {
    return div(classes: 'image-wrapper', events: {
      'click': (_) {
        zoomOut();
      },
      'wheel': (_) {
        zoomOut();
      },
    }, [
      img(
        src: component.src,
        alt: component.alt ?? component.caption,
        styles: Styles(
          position: Position.absolute(top: sourceOffset.y.px, left: sourceOffset.x.px),
          width: targetOffset.width.px,
          height: targetOffset.height.px,
          transform: Transform.combine(zoomed
              ? [
                  Transform.translate(
                    x: (-sourceOffset.x + targetOffset.x).px,
                    y: (-sourceOffset.y + targetOffset.y).px,
                  ),
                  Transform.scale(1),
                ]
              : [
                  Transform.translate(x: 0.px, y: 0.px),
                  Transform.scale(sourceOffset.scale),
                ]),
          raw: {if (isResize) 'transition': 'none'},
        ),
      ),
    ]);
  }
}
