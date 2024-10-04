import 'package:jaspr/server.dart';

import 'app.dart';
import 'jaspr_options.dart';

void main() {
  Jaspr.initializeApp(
    options: defaultJasprOptions,
  );

  runApp(Document(
    title: 'flutter_multi_view',
    head: [
      link(rel: 'manifest', href: 'manifest.json'),
      script(src: "flutter_bootstrap.js", async: true, []),
      DomComponent(tag: 'style', child: raw('''
        @layer view-transitions {

          /* Don’t capture the root, allowing pointer interaction while cards are animating */
          @layer no-root {
            :root {
              view-transition-name: none;
            }
            ::view-transition {
              pointer-events: none;
            }
          }
        
          @layer reorder-cards {
            @supports (view-transition-class: counter) {
              .counter-group {
                view-transition-class: counter;
              }
        
              ::view-transition-group(*.counter) {
                animation-timing-function: ease-in-out;
                animation-duration: 0.5s;
              }
            }
          }
        
          /* Newly added cards should animate-in */
          @layer add-card {
            @keyframes animate-in {
              0% {
                opacity: 0;
                translate: 0 -100px;
              }
              100% {
                opacity: 1;
                translate: 0 0;
              }
            }
        
            ::view-transition-new(targeted-counter):only-child {
              animation: animate-in ease-in 0.25s;
            }
          }
        
          /* Cards that get removed should animate-out */
          @layer remove-card {
            @keyframes animate-out {
              0% {
                opacity: 1;
                translate: 0 0;
              }
              100% {
                opacity: 0;
                translate: 0 -100px;
              }
            }
        
            ::view-transition-old(targeted-counter):only-child {
              animation: animate-out ease-out 0.5s;
            }
          }
        
        }
        '''))
    ],
    styles: [
      css.import('https://fonts.googleapis.com/css?family=Roboto'),
      css('html, body')
          .text(fontFamily: const FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]))
          .box(width: 100.percent, minHeight: 100.vh)
          .box(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
      css('h1').text(fontSize: 4.rem).box(margin: EdgeInsets.unset),
    ],
    body: App(),
  ));
}
