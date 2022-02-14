import 'package:csslib/parser.dart' as css;
import 'package:csslib/visitor.dart' show CssPrinter;
import 'package:html/parser.dart' as html;
import 'package:scopify/scopify.dart';

void main() {
  var myCss = 'p { color: purple; } p > div { height: 200px; }';
  var myHtml = '<p id="my-id">purplified text here<div class="hello"></div></p>';

  // First, we have to parse the CSS and HTMl text.
  var style = css.parse(myCss);
  var node = html.parseFragment(myHtml);

  // Now, we can call scopify. It takes two arguments: a list of HTML nodes, and a list of CSS
  // stylesheets to process.
  scopify(html: [node], css: [style]);

  // The HTML and CSS parse trees were modified in-place. Now, the CSS will only ever modify this
  // HTML code, even when combined with other HTML code.

  // To get the resulting HTML:
  var resultHtml = node.outerHtml;
  print(resultHtml);

  // and CSS:
  var printer = new CssPrinter();
  style.visit(printer);
  var resultCss = printer.toString();
  print(resultCss);
}
