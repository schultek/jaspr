import 'dart:io';

import 'package:http/http.dart' as http;

import '../domains/html_domain.dart';
import '../logging.dart';
import 'base_command.dart';

class ConvertHtmlCommand extends BaseCommand {
  ConvertHtmlCommand({super.logger}) {
    argParser
      ..addOption('file', abbr: 'f', help: 'The HTML file to convert.')
      ..addOption('url', abbr: 'u', help: 'The URL to fetch HTML from.')
      ..addOption('query', abbr: 'q', help: 'A CSS selector to narrow down the conversion.');
  }

  @override
  String get description => 'Convert HTML to Jaspr components.';

  @override
  String get name => 'convert-html';

  @override
  String get category => 'Tooling';

  @override
  Future<int> runCommand() async {
    final file = argResults?.option('file');
    final url = argResults?.option('url');
    final query = argResults?.option('query');

    String html;
    if (file != null && url == null) {
      final f = File(file);
      if (!f.existsSync()) {
        logger.write('File not found: $file', level: Level.error);
        return 1;
      }
      html = f.readAsStringSync();
    } else if (file == null && url != null) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode != 200) {
          logger.write('Failed to fetch URL: $url (Status: ${response.statusCode})', level: Level.error);
          return 1;
        }
        html = response.body;
      } catch (e) {
        logger.write('Error fetching URL: $e', level: Level.error);
        return 1;
      }
    } else {
      logger.write('Either --file or --url must be provided.', level: Level.error);
      return 1;
    }

    final result = await HtmlDomain.convertHtml(html, query);
    logger.write(result);
    return 0;
  }
}
