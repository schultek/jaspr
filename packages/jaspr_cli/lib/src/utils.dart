import 'dart:io';

const _PUB_HOSTED_URL_ENV_NAME = 'PUB_HOSTED_URL';

/// Gets the base url for pub mirror with respect to the value of `PUB_HOSTED_URL` enviroment variable.
///
/// Falls back to https://pub.dev if the enviroment variable is not found.
String getPubDevBaseUrl() {
  for (final kv in Platform.environment.entries) {
    if (kv.key.toUpperCase() == _PUB_HOSTED_URL_ENV_NAME) {
      return kv.value;
    }
  }

  return 'https://pub.dev';
}
