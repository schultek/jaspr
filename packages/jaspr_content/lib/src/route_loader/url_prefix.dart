/// @docImport 'route_loader.dart';
library;

/// Throws an [ArgumentError] for the argument with [parameterName]
/// if [prefix] isn't a valid [RouteLoaderBase.urlPrefix].
void checkUrlPrefix(String prefix, {String parameterName = 'urlPrefix'}) {
  if (!prefix.startsWith('/') || prefix.endsWith('/')) {
    throw ArgumentError.value(prefix, parameterName, 'Must start with a `/` and not end with one, such as `/docs`');
  }

  final segments = prefix.substring(1).split('/');
  for (final segment in segments) {
    if (segment.isEmpty || segment == '.' || segment == '..') {
      throw ArgumentError.value(prefix, parameterName, 'Each segment must be non-empty and not `.` or `..`');
    }
  }

  // Routes treat `:` as the start of a parameter,
  // and are matched against the percent-encoded path of the requested URL,
  // so a character that needs encoding never matches.
  // A prefix that is already encoded isn't decoded for the paths that static generation writes to.
  if (prefix.contains(':') || prefix.contains('%') || Uri(path: prefix).path != prefix) {
    throw ArgumentError.value(
      prefix,
      parameterName,
      'Must not contain `:`, `%`, or a character that URLs percent-encode, '
      'such as a space, `?`, `#`, or a non-ASCII letter',
    );
  }

  // TODO: Support a `.` in the last segment, such as in `/docs/0.10.0`.
  // Static generation and MarkdownOutput take a URL whose
  // last segment contains a `.` for the URL of a file.
  // The root index page, whose URL is the prefix,
  // is then written to a file at the path where the other pages need a folder.
  if (segments.last.contains('.')) {
    throw ArgumentError.value(
      prefix,
      parameterName,
      'Must not contain a `.` in the last segment, so use a prefix such as `/docs/v2` instead',
    );
  }
}
