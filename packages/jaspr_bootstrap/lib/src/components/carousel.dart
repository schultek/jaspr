import 'package:jaspr/jaspr.dart';
import 'package:jaspr_bootstrap/src/elements/image.dart';

class Carousel extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'div', id: 'carouselExampleControls', classes: [
      'carousel',
      'carousel-dark',
      'slide'
    ], attributes: {
      'data-bs-ride': 'carousel',
    }, children: [
      DomComponent(tag: 'div', styles: {
        '--bs-carousel-indicator-width': '90px'
      }, classes: [
        'carousel-indicators'
      ], children: [
        DomComponent(
          tag: 'button',
          attributes: {
            'type': 'button',
            'data-bs-target': '#carouselExampleCaptions',
            'data-bs-slide-to': '0',
            'aria-current': 'true',
            'aria-label': 'Slide 1',
          },
          classes: ['active'],
        ),
        DomComponent(
          tag: 'button',
          attributes: {
            'type': 'button',
            'data-bs-target': '#carouselExampleCaptions',
            'data-bs-slide-to': '1',
            'aria-label': 'Slide 2',
          },
        ),
        DomComponent(
          tag: 'button',
          attributes: {
            'type': 'button',
            'data-bs-target': '#carouselExampleCaptions',
            'data-bs-slide-to': '2',
            'aria-label': 'Slide 3',
          },
        ),
      ]),
      DomComponent(
        tag: 'div',
        classes: ['carousel-inner'],
        children: [
          DomComponent(
            tag: 'div',
            classes: ['carousel-item', 'active'],
            child: Image(
              classes: ['d-block', 'w-100'],
              source:
                  "https://image.shutterstock.com/image-vector/colorful-illustration-test-word-260nw-1438324490.jpg",
            ),
          ),
          DomComponent(
            tag: 'div',
            classes: ['carousel-item'],
            child: Image(
              classes: ['d-block', 'w-100'],
              source:
                  "https://image.shutterstock.com/image-vector/colorful-illustration-test-word-260nw-1438324490.jpg",
            ),
          ),
          DomComponent(
            tag: 'div',
            classes: ['carousel-item'],
            child: Image(
              classes: ['d-block', 'w-100'],
              source:
                  "https://image.shutterstock.com/image-vector/colorful-illustration-test-word-260nw-1438324490.jpg",
            ),
          ),
        ],
      ),
      DomComponent(
        tag: 'button',
        classes: ['carousel-control-prev'],
        attributes: {
          'type': 'button',
          'data-bs-target': '#carouselExampleControls',
          'data-bs-slide': 'prev',
        },
        children: [
          DomComponent(tag: 'span', classes: ['carousel-control-prev-icon'], attributes: {'aria-hidden': 'true'}),
          DomComponent(tag: 'span', classes: ['visually-hidden'], child: Text("Previous")),
        ],
      ),
      DomComponent(
        tag: 'button',
        classes: ['carousel-control-next'],
        attributes: {
          'type': 'button',
          'data-bs-target': '#carouselExampleControls',
          'data-bs-slide': 'next',
        },
        children: [
          DomComponent(tag: 'span', classes: ['carousel-control-next-icon'], attributes: {'aria-hidden': 'true'}),
          DomComponent(tag: 'span', classes: ['visually-hidden'], child: Text("Next")),
        ],
      ),
    ]);
  }
}
