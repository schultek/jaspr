import 'dart:convert';
import 'dart:math';

class Utils {
  static String getRandomString(int length) {
    var random = Random.secure();
    var values = List<int>.generate(length, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }
}
