import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/core.dart';
import 'package:jaspr_ui/src/bootstrap/components/base.dart';
import 'package:jaspr_ui/src/utils.dart';

class Caption {
  final Header title;
  final Paragraph description;

  Caption({required this.title, required this.description});
}

enum CarouselTransition { fade, slide }

class Carousel extends BaseComponent {
  final List<CarouselItem> items;
  final bool dark;
  final bool enableControl;
  final bool enableIndicator;
  final int activeIndex;
  final CarouselTransition transition;

  Carousel({
    required this.items,
    this.dark = false,
    this.enableControl = false,
    this.enableIndicator = false,
    this.activeIndex = 0,
    this.transition = CarouselTransition.slide,
    super.id,
    super.key,
    super.child,
    super.children,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
    super.backgroundColor,
    super.textColor,
    super.padding,
    super.margin,
    super.border,
  });

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final componentId = id ?? Utils.getRandomString(12);
    yield DomComponent(
      tag: 'div',
      id: componentId,
      styles: styles,
      events: events,
      classes: [
        'carousel',
        'slide',
        if (dark) 'carousel-dark',
        if (transition == CarouselTransition.fade) 'carousel-fade',
        ...getClasses(classes),
      ],
      attributes: {
        'data-bs-ride': 'carousel',
        if (attributes != null) ...attributes!,
      },
      children: [
        if (enableIndicator)
          DomComponent(
            tag: 'div',
            classes: ['carousel-indicators'],
            children: [
              for (var i = 0; i < items.length; i++)
                DomComponent(
                  tag: 'button',
                  attributes: {
                    'type': 'button',
                    'data-bs-target': '#$componentId',
                    'data-bs-slide-to': '$i',
                    if (items[i].isActive) 'aria-current': 'true',
                    'aria-label': items[i].label,
                  },
                  classes: items[i].isActive ? ['active'] : null,
                ),
            ],
          ),
        DomComponent(
          tag: 'div',
          classes: ['carousel-inner'],
          children: items,
        ),
        if (enableControl)
          DomComponent(
            tag: 'button',
            classes: ['carousel-control-prev'],
            attributes: {
              'type': 'button',
              'data-bs-target': '#$componentId',
              'data-bs-slide': 'prev',
            },
            children: [
              DomComponent(tag: 'span', classes: ['carousel-control-prev-icon'], attributes: {'aria-hidden': 'true'}),
              DomComponent(tag: 'span', classes: ['visually-hidden'], child: Text("Previous")),
            ],
          ),
        if (enableControl)
          DomComponent(
            tag: 'button',
            classes: ['carousel-control-next'],
            attributes: {
              'type': 'button',
              'data-bs-target': '#$componentId',
              'data-bs-slide': 'next',
            },
            children: [
              DomComponent(tag: 'span', classes: ['carousel-control-next-icon'], attributes: {'aria-hidden': 'true'}),
              DomComponent(tag: 'span', classes: ['visually-hidden'], child: Text("Next")),
            ],
          ),
      ],
    );
  }
}

abstract class CarouselItem extends StatelessComponent {
  final String label;
  final bool isActive;
  final int? interval;

  CarouselItem({
    this.isActive = false,
    this.label = '',
    this.interval,
  });

  Iterable<Component> _getCarouselItemComponent({required List<Component> children}) sync* {
    yield DomComponent(
      tag: 'div',
      classes: ['carousel-item', if (isActive) 'active'],
      attributes: {if (interval != null) 'data-bs-interval': '$interval'},
      children: children,
    );
  }
}

class CarouselSlide extends CarouselItem {
  final DomComponent content;

  CarouselSlide({
    required this.content,
    super.label,
    super.isActive,
    super.interval,
  });

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield* _getCarouselItemComponent(children: [content]);
  }
}

class CarouselImage extends CarouselItem {
  final Image image;
  final Caption? caption;

  CarouselImage({
    required this.image,
    this.caption,
    super.label,
    super.isActive,
    super.interval,
  });

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield* _getCarouselItemComponent(
      children: [
        Image(
          classes: ['d-block', 'w-100'],
          source: image.source,
          alternate: image.alternate,
        ),
        if (caption != null)
          DomComponent(
            tag: 'div',
            classes: ['carousel-caption', 'd-none', 'd-md-block'],
            children: [caption!.title, caption!.description],
          ),
      ],
    );
  }
}
