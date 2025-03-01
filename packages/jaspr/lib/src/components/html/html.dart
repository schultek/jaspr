import 'package:universal_web/web.dart' as web;

import '../../foundation/basic_types.dart';
import '../../foundation/events.dart';
import '../../foundation/styles/styles.dart';
import '../../framework/framework.dart';
import '../raw_text/raw_text.dart';

part 'content.dart';
part 'forms.dart';
part 'media.dart';
part 'other.dart';
part 'svg.dart';
part 'table.dart';
part 'text.dart';

final _events = events;

/// Utility method to create a [Text] component.
Component text(String text) {
  return Text(text);
}

/// Utility method to create a [RawText] component.
Component raw(String text) {
  return RawText(text);
}
