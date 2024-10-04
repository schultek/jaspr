import 'package:jaspr/jaspr.dart';

@css
final viewTransitionStyles = [
  css.layer(name: 'view-transitions', [
    /* Don’t capture the root, allowing pointer interaction while cards are animating. */
    css.layer(name: 'no-root', [
      css(':root').raw({'view-transition-name': 'none'}),
      css('::view-transition').raw({'pointer-events': 'none'}),
    ]),

    /* Existing cards should be animated. */
    css.layer(name: 'reorder-cards', [
      css.supports('(view-transition-class: counter)', [
        css('.counter-group').raw({'view-transition-class': 'counter'}),
        css('::view-transition-group(*.counter)').raw({
          'animation-timing-function': 'ease-in-out',
          'animation-duration': '0.5s',
        }),
      ]),
    ]),

    /* Newly added cards should animate-in. */
    css.layer(name: 'add-card', [
      css.keyframes('animate-in', {
        '0%': Styles.box(opacity: 0, transform: Transform.translate(y: (-100).px)),
        '100%': Styles.box(opacity: 1, transform: Transform.translate(y: Unit.zero)),
      }),
      css('::view-transition-new(targeted-counter):only-child').raw({
        'animation': 'animate-in ease-in 0.25s',
      }),
    ]),

    /* Cards that get removed should animate-out. */
    css.layer(name: 'remove-card', [
      css.keyframes('animate-out', {
        '0%': Styles.box(opacity: 1, transform: Transform.translate(y: Unit.zero)),
        '100%': Styles.box(opacity: 0, transform: Transform.translate(y: (-100).px)),
      }),
      css('::view-transition-old(targeted-counter):only-child').raw({
        'animation': 'animate-out ease-out 0.5s',
      }),
    ]),
  ]),
];
