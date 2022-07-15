library jaspr_html;

import 'src/framework/framework.dart';

part 'src/html/content.dart';
part 'src/html/forms.dart';
part 'src/html/media.dart';
part 'src/html/other.dart';
part 'src/html/text.dart';

/// Utility method to create a text component when using jaspr html methods
Component text(String text, {bool rawHtml = false}) {
  return Text(text, rawHtml: rawHtml);
}
