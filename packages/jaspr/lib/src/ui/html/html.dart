import '../../foundation/basic_types.dart';
import '../../foundation/events.dart';
import '../../framework/framework.dart';
import '../styles/styles.dart';

part 'content.dart';
part 'forms.dart';
part 'media.dart';
part 'other.dart';
part 'text.dart';

final _events = events;

/// Utility method to create a text component when using jaspr html methods
Component text(String text, {bool rawHtml = false}) {
  return Text(text, rawHtml: rawHtml);
}
