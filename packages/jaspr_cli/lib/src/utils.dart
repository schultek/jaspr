import 'dart:io';

const _PUB_HOSTED_URL_ENV_NAME = 'PUB_HOSTED_URL';

/// Gets the value of `PUB_HOSTED_URL` enviroment variable. Returns `null` if not found.
///
/// Returning `null` will fallback to https://pub.dev.
String? getPubDevUrl() {
  for (final kv in Platform.environment.entries) {
    if (kv.key.toUpperCase() == _PUB_HOSTED_URL_ENV_NAME) {
      return kv.value;
    }
  }

  return null;
}
