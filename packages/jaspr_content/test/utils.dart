import 'package:jaspr_content/jaspr_content.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:watcher/watcher.dart';

class MockPage extends Mock implements Page {}

class MockRouteLoader extends Mock implements RouteLoader {}

class MockDirectoryWatcher extends Mock implements DirectoryWatcher {}

Matcher pageSource(String path, String url, {bool private = false, String? content}) {
  return isA<PageSource>()
      .having((s) => s.path, 'path', path)
      .having((s) => s.url, 'url', url)
      .having((s) => s.private, 'private', private)
      .having((s) => s.page?.content, 'content', content);
}