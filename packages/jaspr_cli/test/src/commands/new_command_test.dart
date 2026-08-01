import 'package:jaspr_cli/src/command_runner.dart';
import 'package:jaspr_cli/src/version.dart';
import 'package:test/test.dart';

import '../fakes/fake_io.dart';
import '../fakes/fake_project.dart';

// exit code returned by the runner when a UsageException is thrown
const usageExitCode = 64;

const projectRoot = '/root/myapp';

// pubspec.yaml file for a sample jaspr_content project. jaspr_content is included so that the command
// doesn't prompt the user to add it
String contentPubspec({String mode = 'static'}) =>
    '''
name: myapp

dependencies:
  jaspr: ^$jasprCoreVersion
  jaspr_content: ^0.5.3+1

dev_dependencies:
  jaspr_builder: ^$jasprBuilderVersion

jaspr:
  mode: $mode
''';

// sample server entrypoint that contains a ContentApp, with modifiable content directory, layouts, and parsers
String contentAppEntrypoint({
  String? directory,
  String parsers = 'MarkdownParser(), HtmlParser()',
  String layouts = 'DocsLayout()',
}) =>
    '''
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';

void main() {
  Jaspr.initializeApp();

  runApp(
    ContentApp(
      ${directory != null ? "directory: '$directory'," : ''}
      parsers: [$parsers],
      layouts: [$layouts],
    ),
  );
}
''';

void main() {
  late JasprCommandRunner runner;
  late FakeIO io;

  setUp(() {
    io = FakeIO();
    runner = JasprCommandRunner();
  });

  tearDown(() async {
    await io.tearDown();
  });

  /// sets up a project with a given pubspec file and server entrypoint
  void setupProject({String mode = 'static', String? pubspec, String? serverEntrypoint}) {
    io.setupFakeProject('myapp', mode: mode);
    io.stubDartSDK();

    // create the fake pubspec.yaml file and the fake server entrypoint
    if (pubspec != null) {
      io.fs.file('$projectRoot/pubspec.yaml').writeAsStringSync(pubspec);
    }
    if (serverEntrypoint != null) {
      io.fs.file('$projectRoot/lib/main.server.dart')
        ..createSync(recursive: true)
        ..writeAsStringSync(serverEntrypoint);
    }
  }

  /// Add a package to the dev dependencies. This is done because the command prompts the user if they
  /// want to do so when the package is missing, so we add it ourselves to avoid the prompt
  void addDep(String package, {bool devDependency = true}) {
    final file = io.fs.file('$projectRoot/pubspec.yaml');
    final String depKey = devDependency ? 'dev_dependencies' : 'dependencies';
    file.writeAsStringSync(
      file.readAsStringSync().replaceFirst(
        '$depKey:',
        '$depKey:\n  $package: ^0.1.0',
      ), // we don't care about the version
    );
  }

  /// reads a given file
  String read(String path) => io.fs.file('$projectRoot/$path').readAsStringSync();

  /// checks that a given file exists
  bool exists(String path) => io.fs.file('$projectRoot/$path').existsSync();

  group('new component command', () {
    test('creates a stateless component by default', () async {
      await io.runZoned(() async {
        setupProject();

        expect(await runner.run(['new', 'component', 'ContactInfo']), equals(0));

        // the file must have been created
        expect(exists('lib/components/contact_info.dart'), isTrue);

        // and upon reading the file, we check that it is a stateless component, it must not be a client comp, and must not have styles
        final component = read('lib/components/contact_info.dart');
        expect(component, contains('class ContactInfo extends StatelessComponent'));
        expect(component, isNot(contains('@client')));
        expect(component, isNot(contains('List<StyleRule> get styles')));
      });
    });

    test('creates a stateful component with --stateful', () async {
      await io.runZoned(() async {
        setupProject();

        expect(await runner.run(['new', 'component', 'TodoList', '--stateful']), equals(0));

        expect(exists('lib/components/todo_list.dart'), isTrue);

        final component = read('lib/components/todo_list.dart');
        expect(component, contains('class TodoList extends StatefulComponent'));
        expect(component, contains('class _TodoListState extends State<TodoList>'));
      });
    });

    test('creates an async component with --async', () async {
      await io.runZoned(() async {
        setupProject();

        expect(await runner.run(['new', 'component', 'AsyncCompTest', '--async']), equals(0));

        final component = read('lib/components/async_comp_test.dart');
        expect(component, contains('class AsyncCompTest extends AsyncStatelessComponent'));
        expect(component, contains('Future<Component> build(BuildContext context) async'));
      });
    });

    test('creates an inherited component under lib/ with --inherited', () async {
      await io.runZoned(() async {
        setupProject();

        expect(await runner.run(['new', 'component', 'AppTheme', '--inherited']), equals(0));

        // inherited components are not created in lib/components
        expect(exists('lib/components/app_theme.dart'), isFalse);
        // they are placed in the lib directory (unless a specific path is given)
        expect(exists('lib/app_theme.dart'), isTrue);

        final component = read('lib/app_theme.dart');
        expect(component, contains('class AppTheme extends InheritedComponent'));
        expect(component, contains('static AppTheme? maybeOf(BuildContext context)'));
        expect(component, contains('static AppTheme of(BuildContext context)'));
        expect(component, contains('bool updateShouldNotify(AppTheme oldComponent)'));
      });
    });

    test('adds @client with --client', () async {
      await io.runZoned(() async {
        setupProject();

        expect(await runner.run(['new', 'component', 'Counter', '--client']), equals(0));

        expect(read('lib/components/counter.dart'), contains('@client'));
      });
    });

    test('adds a styles getter with --with-styles', () async {
      await io.runZoned(() async {
        setupProject();

        expect(await runner.run(['new', 'component', 'Header', '--with-styles']), equals(0));

        // check if the component has a styles getter
        final component = read('lib/components/header.dart');
        expect(component, contains('@css'));
        expect(component, contains('List<StyleRule> get styles'));
      });
    });

    test('creates the component under the given --path', () async {
      await io.runZoned(() async {
        setupProject();

        expect(await runner.run(['new', 'component', 'ContactSheet', '--path', 'lib/components/blog']), equals(0));

        expect(exists('lib/components/blog/contact_sheet.dart'), isTrue);
        expect(exists('lib/components/contact_sheet.dart'), isFalse);
      });
    });

    test('generates a test mirroring the component location with --with-test', () async {
      await io.runZoned(() async {
        setupProject();
        // avoids the prompt that asks to add jaspr_test
        addDep('jaspr_test', devDependency: true);

        // this will create the component, but also a test in test/components/about_us_test.dart
        expect(await runner.run(['new', 'component', 'AboutUs', '--with-test']), equals(0));

        expect(exists('lib/components/about_us.dart'), isTrue);
        expect(exists('test/components/about_us_test.dart'), isTrue);

        final testFile = read('test/components/about_us_test.dart');
        expect(testFile, contains("import 'package:myapp/components/about_us.dart'"));
        expect(testFile, contains("group('AboutUs'"));
        expect(testFile, contains('testComponents('));
      });
    });

    test('accepts a name in snake_case', () async {
      await io.runZoned(() async {
        setupProject();

        // the name should be converted to pascal case for the component name
        expect(await runner.run(['new', 'component', 'contact_info']), equals(0));
        expect(exists('lib/components/contact_info.dart'), isTrue);
        expect(read('lib/components/contact_info.dart'), contains('class ContactInfo extends StatelessComponent'));
      });
    });

    test('accepts a name in camelCase', () async {
      await io.runZoned(() async {
        setupProject();

        expect(await runner.run(['new', 'component', 'todoList']), equals(0));
        expect(exists('lib/components/todo_list.dart'), isTrue);
        expect(read('lib/components/todo_list.dart'), contains('class TodoList extends StatelessComponent'));
      });
    });

    test('writes nothing with --dry-run (components)', () async {
      await io.runZoned(() async {
        setupProject();

        // dry-run will only print out what the command will do, it should not change anything on the filesystem
        expect(await runner.run(['new', 'component', 'DryRunContactInfo', '--dry-run']), equals(0));

        expect(exists('lib/components/dry_run_contact_info.dart'), isFalse);
      });
    });

    test('fails when multiple component types are used together', () async {
      await io.runZoned(() async {
        setupProject();

        expect(await runner.run(['new', 'component', 'ContactInfo', '--stateless', '--stateful']), equals(1));

        expect(exists('lib/components/contact_info.dart'), isFalse);
      });
    });

    test('ignores --client for async components', () async {
      await io.runZoned(() async {
        setupProject();

        expect(await runner.run(['new', 'component', 'LoadedData', '--async', '--client']), equals(0));

        expect(read('lib/components/loaded_data.dart'), isNot(contains('@client')));
      });
    });

    test('ignores --client, --with-styles and --with-test for inherited components', () async {
      await io.runZoned(() async {
        setupProject();

        // the inherited components are not components in and of themselves, so --client, --with-styles, and --with-test doesn't make sense
        // and are ignored (the component is still created)
        expect(
          await runner.run(['new', 'component', 'AppTheme', '--inherited', '--client', '--with-styles', '--with-test']),
          equals(0),
        );

        final component = read('lib/app_theme.dart');
        expect(component, isNot(contains('@client')));
        expect(component, isNot(contains('List<StyleRule> get styles')));
        expect(exists('test/app_theme_test.dart'), isFalse);
      });
    });

    test('fails with a usage error when the name is not a valid dart identifier', () async {
      await io.runZoned(() async {
        setupProject();

        expect(await runner.run(['new', 'component', '123abc']), equals(usageExitCode));
      });
    });

    test('fails with a usage error when too many positional arguments are given', () async {
      await io.runZoned(() async {
        setupProject();

        expect(await runner.run(['new', 'component', 'ContactInfo', 'ExtraARgument']), equals(usageExitCode));
      });
    });
  });

  group('new flutter embed view component', () {
    test('creates a flutter embed view with a sample flutter widget', () async {
      await io.runZoned(() async {
        setupProject();
        // add required deps to avoid prompt
        addDep('flutter', devDependency: false);
        addDep('jaspr_flutter_embed', devDependency: false);

        // add required dev deps to avoid prompt
        addDep('flutter_lints', devDependency: true);
        addDep('flutter_test', devDependency: true);

        expect(
          await runner.run([
            'new',
            'component',
            'CounterView',
            '--flutter',
            '--app-name=CounterWidget',
            '--with-flutter-widget',
          ]),
          equals(0),
        );

        expect(exists('lib/components/counter_view.dart'), isTrue);
        expect(exists('lib/widgets/counter_widget.dart'), isTrue);

        final flutterEmbedViewComp = read('lib/components/counter_view.dart');

        expect(
          flutterEmbedViewComp,
          contains("@Import.onWeb('../widgets/counter_widget.dart', show: [#CounterWidget])"),
        );
        expect(flutterEmbedViewComp, contains('CounterView extends StatelessComponent'));
        expect(flutterEmbedViewComp, contains('FlutterEmbedView.deferred('));

        final sampleFlutterWidget = read('lib/widgets/counter_widget.dart');
        expect(sampleFlutterWidget, contains('class CounterWidget extends StatefulWidget'));
      });
    });

    test('configures flutter mode to embedded', () async {
      await io.runZoned(() async {
        setupProject();

        // add required deps to avoid prompt
        addDep('flutter', devDependency: false);
        addDep('jaspr_flutter_embed', devDependency: false);

        // add required dev deps to avoid prompt
        addDep('flutter_lints', devDependency: true);
        addDep('flutter_test', devDependency: true);

        expect(
          await runner.run([
            'new',
            'component',
            'CounterView',
            '--flutter',
            '--app-name=CounterWidget',
            '--with-flutter-widget',
          ]),
          equals(0),
        );

        final pubspecContents = read('pubspec.yaml');
        expect(pubspecContents, contains('flutter: embedded'));
      });
    });

    test('configures flutter.uses-material-design to true', () async {
      await io.runZoned(() async {
        setupProject();

        // add required deps to avoid prompt
        addDep('flutter', devDependency: false);
        addDep('jaspr_flutter_embed', devDependency: false);

        // add required dev deps to avoid prompt
        addDep('flutter_lints', devDependency: true);
        addDep('flutter_test', devDependency: true);

        expect(
          await runner.run([
            'new',
            'component',
            'CounterView',
            '--flutter',
            '--app-name=CounterWidget',
            '--with-flutter-widget',
          ]),
          equals(0),
        );

        final pubspecContents = read('pubspec.yaml');
        expect(pubspecContents, contains('uses-material-design: true'));
      });
    });

    test('creates flutter bootstrap script', () async {
      await io.runZoned(() async {
        setupProject();

        // add required deps to avoid prompt
        addDep('flutter', devDependency: false);
        addDep('jaspr_flutter_embed', devDependency: false);

        // add required dev deps to avoid prompt
        addDep('flutter_lints', devDependency: true);
        addDep('flutter_test', devDependency: true);

        expect(
          await runner.run([
            'new',
            'component',
            'CounterView',
            '--flutter',
            '--app-name=CounterWidget',
            '--with-flutter-widget',
          ]),
          equals(0),
        );

        expect(exists('web/flutter_bootstrap.js'), isTrue);

        final bootstrapContents = read('web/flutter_bootstrap.js');
        expect(bootstrapContents, contains('{{flutter_js}}\n{{flutter_build_config}}\n'));
      });
    });

    test('inserts references to bootstrap script in server entrypoint (for server-side/static applications)', () async {
      await io.runZoned(() async {
        setupProject();

        // add required deps to avoid prompt
        addDep('flutter', devDependency: false);
        addDep('jaspr_flutter_embed', devDependency: false);

        // add required dev deps to avoid prompt
        addDep('flutter_lints', devDependency: true);
        addDep('flutter_test', devDependency: true);

        expect(
          await runner.run([
            'new',
            'component',
            'CounterView',
            '--flutter',
            '--app-name=CounterWidget',
            '--with-flutter-widget',
          ]),
          equals(0),
        );

        expect(exists('web/flutter_bootstrap.js'), isTrue);
        expect(exists('lib/main.server.dart'), isTrue);

        final entrypointContents = read('lib/main.server.dart');
        expect(entrypointContents, contains("import 'package:jaspr/dom.dart';"));
        expect(entrypointContents, contains('script(src: "flutter_bootstrap.js", async: true),'));
      });
    });

    test('inserts references to bootstrap script in index.html (for client-side applications)', () async {
      await io.runZoned(() async {
        setupProject(mode: 'client');

        // add required deps to avoid prompt
        addDep('flutter', devDependency: false);
        addDep('jaspr_flutter_embed', devDependency: false);

        // add required dev deps to avoid prompt
        addDep('flutter_lints', devDependency: true);
        addDep('flutter_test', devDependency: true);

        expect(
          await runner.run([
            'new',
            'component',
            'CounterView',
            '--flutter',
            '--app-name=CounterWidget',
            '--with-flutter-widget',
          ]),
          equals(0),
        );

        expect(exists('web/flutter_bootstrap.js'), isTrue);
        expect(exists('web/index.html'), isTrue);

        final indexContents = read('web/index.html');
        expect(indexContents, contains('<script src="flutter_bootstrap.js" async></script>'));
      });
    });

    test('ignores --with-tests', () async {
      await io.runZoned(() async {
        setupProject();

        // add required deps to avoid prompt
        addDep('flutter', devDependency: false);
        addDep('jaspr_flutter_embed', devDependency: false);

        // add required dev deps to avoid prompt
        addDep('flutter_lints', devDependency: true);
        addDep('flutter_test', devDependency: true);

        expect(
          await runner.run([
            'new',
            'component',
            'CounterView',
            '--flutter',
            '--app-name=CounterWidget',
            '--with-flutter-widget',
            '--with-test',
          ]),
          equals(0),
        );

        final component = read('lib/components/counter_view.dart');
        expect(component, isNot(contains('List<StyleRule> get styles')));
      });
    });
  });

  group('new page command', () {
    test('creates a markdown page with frontmatter', () async {
      await io.runZoned(() async {
        setupProject(pubspec: contentPubspec(), serverEntrypoint: contentAppEntrypoint());

        expect(await runner.run(['new', 'page', 'getting_started']), equals(0));

        expect(exists('content/getting_started.md'), isTrue);

        final page = read('content/getting_started.md');
        expect(page, startsWith('---'));
        // the title defaults to the page name in Title Case
        expect(page, contains('title: Getting Started'));
        expect(page, contains('# Getting Started'));
        expect(page, isNot(contains('<h1>')));
      });
    });

    test('creates an html page when using --format html', () async {
      await io.runZoned(() async {
        setupProject(pubspec: contentPubspec(), serverEntrypoint: contentAppEntrypoint());

        expect(await runner.run(['new', 'page', 'changelog', '--format', 'html']), equals(0));

        expect(exists('content/changelog.html'), isTrue);
        expect(exists('content/changelog.md'), isFalse);

        final page = read('content/changelog.html');
        expect(page, startsWith('---'));
        expect(page, contains('title: Changelog'));
        expect(page, contains('<h1>Changelog</h1>'));
        expect(page, isNot(contains('# Changelog')));
      });
    });

    test('creates the page in the directories found in the name', () async {
      await io.runZoned(() async {
        setupProject(pubspec: contentPubspec(), serverEntrypoint: contentAppEntrypoint());

        expect(await runner.run(['new', 'page', 'guides/deploying']), equals(0));

        expect(exists('content/guides/deploying.md'), isTrue);
        expect(read('content/guides/deploying.md'), contains('title: Deploying'));
      });
    });

    test('creates an index page with --index', () async {
      await io.runZoned(() async {
        setupProject(pubspec: contentPubspec(), serverEntrypoint: contentAppEntrypoint());

        // creates content/guides/index.md and not content/guides.md
        expect(await runner.run(['new', 'page', 'guides', '--index']), equals(0));

        expect(exists('content/guides/index.md'), isTrue);
        expect(exists('content/guides.md'), isFalse);
        // the title is still based on the page name and not on "index"
        expect(read('content/guides/index.md'), contains('title: Guides'));
      });
    });

    test('sets the correct title, description and layout in frontmatter', () async {
      await io.runZoned(() async {
        setupProject(pubspec: contentPubspec(), serverEntrypoint: contentAppEntrypoint());

        expect(
          await runner.run([
            'new',
            'page',
            'faq',
            '--title',
            'FAQ',
            '--description',
            'Answers to questions',
            '--layout',
            'docs',
          ]),
          equals(0),
        );

        final page = read('content/faq.md');
        expect(page, contains('title: FAQ'));
        expect(page, contains('description: Answers to questions'));
        expect(page, contains('layout: docs'));
        expect(page, contains('# FAQ'));
      });
    });

    test('adds sitemap and sample meta keys with --sitemap and --meta', () async {
      await io.runZoned(() async {
        setupProject(pubspec: contentPubspec(), serverEntrypoint: contentAppEntrypoint());

        expect(await runner.run(['new', 'page', 'blog_post', '--sitemap', '--meta']), equals(0));

        final page = read('content/blog_post.md');
        expect(page, contains('sitemap:'));
        expect(page, contains('changefreq: monthly'));
        expect(page, contains('lastmod:'));
        expect(page, contains('meta:'));
        expect(page, contains('og:site_name'));
      });
    });

    test('excludes the new page from the sitemap with --sitemap-exclude', () async {
      await io.runZoned(() async {
        setupProject(pubspec: contentPubspec(), serverEntrypoint: contentAppEntrypoint());

        expect(await runner.run(['new', 'page', 'drafts', '--sitemap-exclude']), equals(0));

        expect(read('content/drafts.md'), contains('sitemap: false'));
      });
    });

    test('ignores the sitemap keys when the page is also excluded from the sitemap', () async {
      await io.runZoned(() async {
        setupProject(pubspec: contentPubspec(), serverEntrypoint: contentAppEntrypoint());

        // will warn the user that --sitemap-exclude takes priority over --sitemap
        expect(await runner.run(['new', 'page', 'drafts', '--sitemap', '--sitemap-exclude']), equals(0));

        final page = read('content/drafts.md');
        expect(page, contains('sitemap: false'));
        expect(page, isNot(contains('changefreq')));
      });
    });

    test('does not create the frontmatter with --no-frontmatter', () async {
      await io.runZoned(() async {
        setupProject(pubspec: contentPubspec(), serverEntrypoint: contentAppEntrypoint());

        expect(await runner.run(['new', 'page', 'about', '--no-frontmatter']), equals(0));

        final page = read('content/about.md');
        expect(page, isNot(contains('---')));
      });
    });

    test('ignores the frontmatter flags with --no-frontmatter', () async {
      await io.runZoned(() async {
        setupProject(pubspec: contentPubspec(), serverEntrypoint: contentAppEntrypoint());

        expect(
          await runner.run(['new', 'page', 'about', '--no-frontmatter', '--meta', '--sitemap', '--sitemap-exclude']),
          equals(0),
        );

        final page = read('content/about.md');
        expect(page, isNot(contains('---')));
        expect(page, isNot(contains('meta:')));
        expect(page, isNot(contains('sitemap')));
      });
    });

    test('creates pages in custom content directory of ContentApp', () async {
      await io.runZoned(() async {
        setupProject(
          pubspec: contentPubspec(),
          serverEntrypoint: contentAppEntrypoint(directory: 'docs'),
        );

        // will/should create the page under 'docs/' and not 'content/'
        expect(await runner.run(['new', 'page', 'faq']), equals(0));

        expect(exists('docs/faq.md'), isTrue);
        expect(exists('content/faq.md'), isFalse);
      });
    });

    test('creates the page under the given --path', () async {
      await io.runZoned(() async {
        setupProject(pubspec: contentPubspec(), serverEntrypoint: contentAppEntrypoint());

        expect(await runner.run(['new', 'page', 'faq', '--path', 'content/support']), equals(0));

        expect(exists('content/support/faq.md'), isTrue);
        expect(exists('content/faq.md'), isFalse);
      });
    });

    test('writes nothing with --dry-run', () async {
      await io.runZoned(() async {
        setupProject(pubspec: contentPubspec(), serverEntrypoint: contentAppEntrypoint());

        expect(await runner.run(['new', 'page', 'getting_started', '--dry-run']), equals(0));

        expect(exists('content/getting_started.md'), isFalse);
      });
    });

    test("cancels when the format can't be parsed", () async {
      await io.runZoned(() async {
        setupProject(
          pubspec: contentPubspec(),
          serverEntrypoint: contentAppEntrypoint(parsers: 'MarkdownParser()'),
        );

        // no html parser registered, this would prompt the user to confirm they want to create the page or not
        // but not here since there is no terminal attached, so it cancels directly
        expect(await runner.run(['new', 'page', 'changelog', '--format', 'html']), equals(1));

        // doesn't create the file
        expect(exists('content/changelog.html'), isFalse);
      });
    });

    test('cancels when the requested layout is not registered', () async {
      await io.runZoned(() async {
        setupProject(
          pubspec: contentPubspec(),
          // only the docs layout is registered
          serverEntrypoint: contentAppEntrypoint(layouts: 'DocsLayout()'),
        );

        // the blog layout is not defined, so this would prompt the user to confirm, however no terminal is
        // attached, so the command cancels directly
        expect(await runner.run(['new', 'page', 'post', '--layout', 'blog']), equals(1));

        expect(exists('content/post.md'), isFalse);
      });
    });

    test('does not check the parsers or layouts of a ContentApp with no parsers or layouts', () async {
      await io.runZoned(() async {
        setupProject(
          pubspec: contentPubspec(),
          serverEntrypoint: '''
import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';

void main() {
  runApp(ContentApp.custom(loaders: [FilesystemLoader('content')]));
}
''',
        );

        // since no parsers and no layouts are defined, the command can't warn the user about missing parser or layout
        // so it will create the page
        expect(await runner.run(['new', 'page', 'changelog', '--format', 'html', '--layout', 'blog']), equals(0));

        expect(exists('content/changelog.html'), isTrue);
      });
    });

    test('warns but still generates page when no ContentApp is found', () async {
      await io.runZoned(() async {
        setupProject(
          pubspec: contentPubspec(),
          serverEntrypoint: '''
import 'package:jaspr/server.dart';
import 'package:jaspr/dom.dart';

void main() {
  runApp(Document(body: div([])));
}
''',
        );
        // in this test, the ContentApp isn't defined in the server entrypoint, maybe it's elsewhere
        // but since we don't know, the command warns that it didn't find the ContentApp but still generates the page

        expect(await runner.run(['new', 'page', 'faq']), equals(0));

        expect(exists('content/faq.md'), isTrue);
      });
    });

    test('fails for a client-side project', () async {
      await io.runZoned(() async {
        setupProject(
          mode: 'client',
          pubspec: contentPubspec(mode: 'client'),
        );

        expect(await runner.run(['new', 'page', 'faq']), equals(1));

        expect(exists('content/faq.md'), isFalse);
      });
    });

    test('fails for a name that exits out of the content directory', () async {
      await io.runZoned(() async {
        setupProject(pubspec: contentPubspec(), serverEntrypoint: contentAppEntrypoint());

        expect(await runner.run(['new', 'page', '../faq']), equals(usageExitCode));
      });
    });

    test('fails when the name is an absolute path', () async {
      await io.runZoned(() async {
        setupProject(pubspec: contentPubspec(), serverEntrypoint: contentAppEntrypoint());

        expect(await runner.run(['new', 'page', '/etc/faq']), equals(usageExitCode));
      });
    });

    test('fails when too many positional arguments are given', () async {
      await io.runZoned(() async {
        setupProject(pubspec: contentPubspec(), serverEntrypoint: contentAppEntrypoint());

        expect(await runner.run(['new', 'page', 'faq1', 'faq2', 'faq3']), equals(usageExitCode));
      });
    });
  });
}
