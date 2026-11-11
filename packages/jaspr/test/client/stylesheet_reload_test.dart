@TestOn('browser')
library;

import 'package:jaspr/client.dart';
import 'package:jaspr/src/client/utils.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart' as web;

void main() {
  group('stylesheet reload', () {
    // The test runner serves this test from a nested path, like a nested page of an app.
    // The stylesheet next to this test stands in for a generated one,
    // which the CLI identifies by its path relative to the root.
    final pagePath = web.window.location.pathname;
    final directory = pagePath.substring(0, pagePath.lastIndexOf('/') + 1);
    const stylesheetName = 'stylesheet_reload_test.css';
    final stylesheetUrl = '${directory.substring(1)}$stylesheetName';

    /// Links the stylesheet at [href], and waits for it to load if it [exists].
    Future<web.Element> linkStylesheet(String href, {bool exists = true}) async {
      final link = web.document.createElement('link') as web.HTMLLinkElement
        ..rel = 'stylesheet'
        ..href = href;
      addTearDown(() {
        for (final link in web.document.querySelectorAll('link[rel="stylesheet"]').toIterable()) {
          (link as web.Element).remove();
        }
      });

      final loaded = web.EventStreamProvider<web.Event>('load').forElement(link).first;
      web.document.head!.append(link);
      if (exists) await loaded;
      return link;
    }

    void addBase({String? href}) {
      final base = web.document.createElement('base') as web.HTMLBaseElement;
      if (href != null) {
        base.href = href;
      } else {
        base.target = '_self';
      }
      web.document.head!.prepend(base);
      addTearDown(() => base.remove());
    }

    Future<void> reloadStylesheet(String url) => ClientAppBinding.ensureInitialized().reloadStylesheets([url]);

    /// The `href` attributes of the linked stylesheets, in document order.
    List<String?> linkedHrefs() => [
      for (final link in web.document.querySelectorAll('link[rel="stylesheet"]').toIterable())
        (link as web.Element).getAttribute('href'),
    ];

    /// Matches the `href` of a stylesheet linked with [href] after it was reloaded.
    Matcher reloaded(String href) => matches('^${RegExp.escape(href)}\\?v=\\d+\$');

    test('reloads a stylesheet linked from the root', () async {
      await linkStylesheet('/$stylesheetUrl');

      await reloadStylesheet(stylesheetUrl);
      expect(linkedHrefs(), [reloaded('/$stylesheetUrl')]);

      // A reloaded stylesheet is found again and replaced.
      final reloadedLink = web.document.querySelector('link[rel="stylesheet"]')!;
      await reloadStylesheet(stylesheetUrl);
      expect(linkedHrefs(), [reloaded('/$stylesheetUrl')]);
      expect(reloadedLink.isConnected, isFalse);
    });

    test('reloads a stylesheet linked from the root when no base sets a URL', () async {
      addBase();
      await linkStylesheet('/$stylesheetUrl');

      await reloadStylesheet(stylesheetUrl);
      expect(linkedHrefs(), [reloaded('/$stylesheetUrl')]);
    });

    test('reloads a stylesheet linked relative to the base URL', () async {
      addBase(href: '/');
      await linkStylesheet(stylesheetUrl);

      await reloadStylesheet(stylesheetUrl);
      expect(linkedHrefs(), [reloaded(stylesheetUrl)]);
    });

    test('keeps the other query parameters of a reloaded stylesheet', () async {
      await linkStylesheet('/$stylesheetUrl?theme=dark');
      final withVersion = matches('^${RegExp.escape('/$stylesheetUrl?theme=dark')}&v=\\d+\$');

      await reloadStylesheet(stylesheetUrl);
      expect(linkedHrefs(), [withVersion]);

      // Reloading again replaces the version instead of adding another one.
      await reloadStylesheet(stylesheetUrl);
      expect(linkedHrefs(), [withVersion]);
    });

    test('keeps the fragment of a reloaded stylesheet after its version', () async {
      await linkStylesheet('/$stylesheetUrl#theme');

      await reloadStylesheet(stylesheetUrl);
      expect(linkedHrefs(), [matches('^${RegExp.escape('/$stylesheetUrl')}\\?v=\\d+#theme\$')]);
    });

    test('reloads only the stylesheet with the same path', () async {
      // Linked first, with a path that starts with the path of the reloaded stylesheet.
      await linkStylesheet('/$stylesheetUrl.dark.css', exists: false);
      await linkStylesheet('/$stylesheetUrl');

      await reloadStylesheet(stylesheetUrl);
      expect(linkedHrefs(), ['/$stylesheetUrl.dark.css', reloaded('/$stylesheetUrl')]);
    });

    test('reloads the stylesheet at the base URL instead of one from the root', () async {
      addBase(href: directory);
      // Linked first, with the same path from the root as the reloaded stylesheet has from the base URL.
      await linkStylesheet('/$stylesheetName', exists: false);
      await linkStylesheet(stylesheetName);

      await reloadStylesheet(stylesheetName);
      expect(linkedHrefs(), ['/$stylesheetName', reloaded(stylesheetName)]);
    });

    test('ignores stylesheets that are not linked', () async {
      await linkStylesheet('/$stylesheetUrl');

      await reloadStylesheet('other.css');
      expect(linkedHrefs(), ['/$stylesheetUrl']);
    });
  });
}
