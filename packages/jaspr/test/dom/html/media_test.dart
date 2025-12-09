@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('html components', () {
    testComponents('renders media', (tester) async {
      tester.pumpComponent(
        div([
          audio(
            autoplay: false,
            controls: false,
            crossOrigin: CrossOrigin.anonymous,
            loop: false,
            muted: false,
            preload: Preload.auto,
            src: 'a.mp3',
            [],
          ),
          img(
            alt: 'a',
            crossOrigin: CrossOrigin.anonymous,
            width: 100,
            height: 100,
            loading: MediaLoading.lazy,
            src: 'a.png',
          ),
          video(
            autoplay: false,
            controls: false,
            crossOrigin: CrossOrigin.anonymous,
            loop: false,
            muted: false,
            preload: Preload.auto,
            src: 'a.mp4',
            width: 100,
            height: 100,
            [],
          ),
          embed(src: 'a', type: 'a', width: 100, height: 100),
          iframe(
            src: 'a.html',
            allow: '',
            csp: '',
            loading: MediaLoading.lazy,
            name: 'a',
            sandbox: '',
            width: 100,
            height: 100,
            [],
          ),
          object(data: 'a', name: 'a', type: '', width: 100, height: 100, []),
          source(type: '', src: 'a'),
        ]),
      );

      expect(find.tag('audio'), findsOneComponent);
      expect(find.tag('img'), findsOneComponent);
      expect(find.tag('video'), findsOneComponent);
      expect(find.tag('embed'), findsOneComponent);
      expect(find.tag('iframe'), findsOneComponent);
      expect(find.tag('object'), findsOneComponent);
      expect(find.tag('source'), findsOneComponent);
    });
  });
}
