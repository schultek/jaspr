import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' hide Document;

import '../../theme.dart';

@client
class ZoomableImage extends StatefulComponent {
  ZoomableImage({required this.src, this.alt, this.caption, super.key});

  final String src;
  final String? alt;
  final String? caption;

  @override
  State<StatefulComponent> createState() => _ZoomableImageState();

  @css
  static List<StyleRule> get styles => [
    css('figure.image', [css('&.zoomable img').styles(cursor: Cursor.zoomIn)]),
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
        transition: Transition('transform', duration: 300.ms),
        raw: {'transform-origin': 'top left'},
      ),
    ]),
  ];
}

class _ZoomableImageState extends State<ZoomableImage> with ViewTransitionMixin {
  final GlobalNodeKey<HTMLDialogElement> dialogKey = GlobalNodeKey();
  final GlobalNodeKey<HTMLImageElement> imageKey = GlobalNodeKey();

  StreamSubscription<Event>? _resizeSub;

  bool zoomed = false;
  bool isResize = false;

  ({double scale, double x, double y}) sourceOffset = (x: 0.0, y: 0.0, scale: 1.0);
  ({double height, double width, double x, double y}) targetOffset = (x: 0.0, y: 0.0, width: 0.0, height: 0.0);

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      context.binding.addPostFrameCallback(() {
        updateImageOffset(false);
      });

      _resizeSub = EventStreamProviders.resizeEvent.forTarget(window).listen((_) {
        updateImageOffset(true);
      });
    }
  }

  void updateImageOffset(bool isResize) {
    final sourceRect = imageKey.currentNode?.getBoundingClientRect();
    if (sourceRect == null) return;

    final sourceAspect = sourceRect.width / sourceRect.height;
    final windowAspect = window.innerWidth / window.innerHeight;

    final sourceScale =
        windowAspect >
            sourceAspect //
        ? sourceRect.height / window.innerHeight
        : sourceRect.width / window.innerWidth;

    final targetOffsetX = windowAspect > sourceAspect ? (window.innerWidth - sourceRect.width / sourceScale) / 2 : 0.0;
    final targetOffsetY = windowAspect > sourceAspect
        ? 0.0
        : (window.innerHeight - sourceRect.height / sourceScale) / 2;

    setState(() {
      sourceOffset = (x: sourceRect.left, y: sourceRect.top, scale: sourceScale);
      targetOffset = (
        x: targetOffsetX,
        y: targetOffsetY,
        width: sourceRect.width / sourceScale,
        height: sourceRect.height / sourceScale,
      );
      this.isResize = isResize;
    });
  }

  void zoomIn() {
    updateImageOffset(false);

    setState(() => zoomed = true);
    document.body!.style.overflow = 'hidden';
    dialogKey.currentNode?.showModal();
  }

  void zoomOut() async {
    setState(() => zoomed = false);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (zoomed) return;
    document.body!.style.overflow = 'auto';
    dialogKey.currentNode?.close();
  }

  @override
  void dispose() {
    _resizeSub?.cancel();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      figure(classes: 'image zoomable', [
        img(
          key: imageKey,
          src: component.src,
          alt: component.alt ?? component.caption,
          styles: zoomed ? Styles(visibility: Visibility.hidden) : null,
          events: events<void>(
            onClick: () {
              zoomIn();
            },
          ),
        ),
        if (component.caption != null) figcaption([Component.text(component.caption!)]),
      ]),
      _buildDialog(context),
    ]);
  }

  Component _buildDialog(BuildContext context) {
    return Component.element(
      key: dialogKey,
      tag: 'dialog',
      classes: 'zoom-modal not-content',
      attributes: {
        if (dialogKey.currentNode?.open ?? false) 'open': '',
      },
      events: {
        'cancel': (e) {
          e.preventDefault();
          zoomOut();
        },
      },
      children: [
        div(
          classes: 'image-wrapper',
          events: {
            'click': (_) => zoomOut(),
            'wheel': (_) => zoomOut(),
          },
          [
            img(
              src: component.src,
              alt: component.alt ?? component.caption,
              styles: Styles(
                position: Position.absolute(top: sourceOffset.y.px, left: sourceOffset.x.px),
                width: targetOffset.width.px,
                height: targetOffset.height.px,
                transform: Transform.combine([
                  Transform.translate(
                    x: zoomed ? (-sourceOffset.x + targetOffset.x).px : 0.px,
                    y: zoomed ? (-sourceOffset.y + targetOffset.y).px : 0.px,
                  ),
                  Transform.scale(zoomed ? 1 : sourceOffset.scale),
                ]),
                raw: {if (isResize) 'transition': 'none'},
              ),
            ),
          ],
        ),
      ],
    );
  }
}
