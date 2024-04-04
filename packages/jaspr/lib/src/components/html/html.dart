import '../../foundation/basic_types.dart';
import '../../foundation/events/events.dart';
import '../../foundation/styles/styles.dart';
import '../../framework/framework.dart';
import '../raw_text/raw_text.dart';

part 'content.dart';
part 'forms.dart';
part 'media.dart';
part 'other.dart';
part 'svg.dart';
part 'text.dart';

final _events = events;

/// Utility method to create a text component when using jaspr html methods.
Component text(String text) {
  return Text(text);
}

/// Utility method to create a raw text component when using jaspr html methods.
Component raw(String text) {
  return RawText(text);
}
