import 'dart:async';

import 'package:jaspr/dom.dart';
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
  Component build(BuildContext context) {
    return div(
      classes: 'blur-backdrop',
      events: events(
        onClick: () {
          showRandomImage();
        },
      ),
      [
        img(src: 'images/jasper_resized/$currentImage.webp', alt: 'Jasper'),
        span([
          .text('Click anywhere to see another image.'),
          br(),
          .text('Press ESC or click '),
          a(
            href: '',
            events: {
              'click': (e) {
                e.preventDefault();
                component.onClose();
              },
            },
            [.text('here')],
          ),
          .text(' to close.'),
        ]),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.blur-backdrop', [
      css('&').styles(
        display: .flex,
        position: .fixed(top: .zero, left: .zero, right: .zero, bottom: .zero),
        zIndex: .new(1),
        userSelect: .none,
        flexDirection: .column,
        justifyContent: .center,
        alignItems: .center,
        backgroundColor: backgroundFaded,
        raw: {'backdrop-filter': 'blur(5px)', '-webkit-backdrop-filter': 'blur(5px)'},
      ),
      css('img', [
        css('&').styles(
          maxWidth: 80.percent,
          maxHeight: 80.percent,
          radius: .circular(20.px),
          pointerEvents: .none,
          raw: {'object-fit': 'cover'},
        ),
      ]),
      css('span')
          .styles(
            display: .inlineBlock,
            margin: .only(top: 1.rem),
          )
          .combine(bodySmall),
    ]),
  ];
}
