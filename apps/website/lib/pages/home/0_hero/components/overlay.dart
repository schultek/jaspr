import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import '../../../../constants/theme.dart';

class Overlay extends StatefulComponent {
  const Overlay({required this.onClose, super.key});

  final void Function() onClose;

  @override
  State createState() => OverlayState();
}

class OverlayState extends State<Overlay> {
  var imageIndex = 0;
  var imageIndexes = List.generate(18, (index) => index + 1)..shuffle();

  late final StreamSubscription sub;

  @override
  void initState() {
    super.initState();

    web.document.body!.style.overflow = 'hidden';
    sub = web.window.onKeyDown.listen((event) {
      if (event.key == 'Escape') {
        component.onClose();
      }
    });
  }

  void showRandomImage() {
    setState(() {
      imageIndex = (imageIndex + 1) % imageIndexes.length;
    });
  }

  String get currentImage {
    return imageIndexes[imageIndex].toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    sub.cancel();
    web.document.body!.style.overflow = 'initial';

    super.dispose();
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'blur-backdrop', events: events(onClick: () {
      showRandomImage();
    }), [
      img(src: 'images/jasper_resized/$currentImage.webp', alt: 'Jasper'),
      span([
        text('Click anywhere to see another image.'),
        br(),
        text('Press ESC or click '),
        a(href: '', events: {
          'click': (e) {
            e.preventDefault();
            component.onClose();
          }
        }, [
          text('here')
        ]),
        text(' to close.'),
      ]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('.blur-backdrop', [
      css('&')
          .box(
            position: Position.fixed(
              top: Unit.zero,
              left: Unit.zero,
              right: Unit.zero,
              bottom: Unit.zero,
              zIndex: ZIndex(1),
            ),
          )
          .background(color: backgroundFaded)
          .flexbox(
            direction: FlexDirection.column,
            alignItems: AlignItems.center,
            justifyContent: JustifyContent.center,
          )
          .raw({'backdrop-filter': 'blur(5px)', 'user-select': 'none'}),
      css('img', [
        css('&')
            .box(maxWidth: 80.percent, maxHeight: 80.percent, radius: BorderRadius.circular(20.px))
            .raw({'object-fit': 'cover', 'pointer-events': 'none'}),
      ]),
      css('span').box(display: Display.inlineBlock, margin: EdgeInsets.only(top: 1.rem)).combine(bodySmall),
    ]),
  ];
}
