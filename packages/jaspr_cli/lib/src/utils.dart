import 'dart:io';

const _PUB_HOSTED_URL_ENV_NAME = 'PUB_HOSTED_URL';

String? getPubDevUrl() {
  for (final kv in Platform.environment.entries) {
    if (kv.key.toUpperCase() == _PUB_HOSTED_URL_ENV_NAME) {
      return kv.value;
    }
  }

  return null;
}
