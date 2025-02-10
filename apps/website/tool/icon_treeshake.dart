import 'dart:convert';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

final icons = [
  0xe121, // moon
  0xe17b, // sun
  0xe070, // check
  0xe0a2, // copy
  0xe1c1, // lightbulb
  0xe36f, // file-json-2
  0xe28c, // git-fork
  0xe179, // star
  0xe1b1, // x
  0xe118, // menu
  0xe184, // terminal
  0xe54f, // book-text
  0xe34b, // newspaper
  0xe155, // send
  0xe04d, // arrow-right
  0xe285, // rocket
  0xe063, // book-open
  0xe5bd, // hand-heart
  0xe297, // milestone
  0xe08d, // cloud-download
  0xe376, // trophy
  0xe0b1, // database
  0xe3b1, // picture-in-picture
  0xe156, // server
  0xe1dc, // palette
  0xe409, // test-tube
];

void main() async {
  final args = [
    p.absolute('web/font/lucide/lucide.ttf'),
    p.absolute('tool/lucide.ttf'),
  ];

  final process = await Process.start(fontSubsetPath, args);

  process.stdout.listen(stdout.add);
  process.stderr.listen(stderr.add);

  try {
    process.stdin.writeln(icons.join(' '));
  } finally {
    await process.stdin.flush();
    await process.stdin.close();

    await process.exitCode;

    await stdout.flush();
    await stderr.flush();
  }

  final int code = await process.exitCode;
  if (code != 0) {
    throw StateError('Font subsetting failed with exit code $code.');
  }
}

final fontSubsetPath = (() {
  var result = Process.runSync('flutter', ['doctor', '--version', '--machine'], stdoutEncoding: utf8, runInShell: true);
  if ((result.stderr as String).isNotEmpty) {
    throw UnsupportedError('Calling "flutter doctor" resulted in: "${result.stderr}". '
        'Make sure flutter is installed and setup correctly.');
  }
  var output = jsonDecode(result.stdout as String) as Map;
  var fontSubsetPath =
      p.join(output['flutterRoot'] as String, 'bin', 'cache', 'artifacts', 'engine', 'darwin-x64', 'font-subset');

  if (!File(fontSubsetPath).existsSync()) {
    throw UnsupportedError('Could not find font_subset tool in $fontSubsetPath.');
  }
  return fontSubsetPath;
})();
