import 'package:jaspr/jaspr.dart';
import 'package:jaspr/ui.dart';
import 'package:jaspr_bootstrap/src/core/utils.dart';

import 'base.dart';

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

  const Carousel({
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
    super.style,
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
    yield DivElement(
      id: componentId,
      style: style,
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
        if (enableIndicator) _CarouselIndicator(componentId: componentId, items: items),
        DivElement(
          classes: ['carousel-inner'],
          children: items,
        ),
        if (enableControl)
          _CarouselButton(
            componentId: componentId,
            type: _CarouselButtonType.prev,
          ),
        if (enableControl)
          _CarouselButton(
            componentId: componentId,
            type: _CarouselButtonType.next,
          ),
      ],
    );
  }
}

enum _CarouselButtonType { next, prev }

class _CarouselButton extends StatelessComponent {
  final String componentId;
  final _CarouselButtonType type;

  _CarouselButton({required this.componentId, required this.type});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield ButtonElement(
      classes: ['carousel-control-${type.name}'],
      attributes: {
        'type': 'button',
        'data-bs-target': '#$componentId',
        'data-bs-slide': type.name,
      },
      children: [
        SpanElement(classes: ['carousel-control-${type.name}-icon'], attributes: {'aria-hidden': 'true'}),
        SpanElement(classes: ['visually-hidden'], child: Text(type.name)),
      ],
    );
  }
}

class _CarouselIndicator extends StatelessComponent {
  final String componentId;
  final List<CarouselItem> items;

  const _CarouselIndicator({required this.componentId, required this.items});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DivElement(
      classes: ['carousel-indicators'],
      children: [
        for (var i = 0; i < items.length; i++)
          ButtonElement(
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
    yield DivElement(
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
          DivElement(
            classes: ['carousel-caption', 'd-none', 'd-md-block'],
            children: [caption!.title, caption!.description],
          ),
      ],
    );
  }
}
