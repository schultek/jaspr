export 'package:flutter/widgets.dart'
    if (dart.library.js_interop) 'widget/widget_web.dart'
    if (dart.library.io) 'widget/widget_io.dart'
    show Widget;
