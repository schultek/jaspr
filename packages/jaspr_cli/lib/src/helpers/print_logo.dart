import 'dart:math' as math;
import 'package:mason/mason.dart';

import '../project.dart';
import '../version.dart';
import 'print_logo_constants.dart';

// Brand Colors (RGB values, can be customized directly here)
const List<int> darkBlue = [9, 56, 126];
const List<int> mediumBlue = [0, 102, 180];
const List<int> lightBlue = [64, 196, 255];

// ANSI escape sequence helper
String _color(List<int> rgb, {bool bg = false}) {
  return '\x1b[${bg ? 48 : 38};2;${rgb[0]};${rgb[1]};${rgb[2]}m';
}

const String _reset = '\x1b[0m';
const String _bold = '\x1b[1m';

const List<String> _textLines = [
  '     ██╗ █████╗ ███████╗██████╗ ██████╗  ',
  '     ██║██╔══██╗██╔════╝██╔══██╗██╔══██╗ ',
  '     ██║███████║███████╗██████╔╝██████╔╝ ',
  '██   ██║██╔══██║╚════██║██╔═══╝ ██╔══██╗ ',
  '╚█████╔╝██║  ██║███████║██║     ██║  ██║ ',
  ' ╚════╝ ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝ ',
];

List<int>? _getRgb(String char) {
  switch (char) {
    case 'D':
      return darkBlue;
    case 'M':
      return mediumBlue;
    case 'L':
      return lightBlue;
    default:
      return null;
  }
}

String _getGradientColor(int colIdx, int totalCols) {
  final mid = totalCols / 2.0;
  final rgb = [0.0, 0.0, 0.0];
  if (colIdx < mid) {
    final t = colIdx / mid;
    for (int i = 0; i < 3; i++) {
      rgb[i] = (1.0 - t) * darkBlue[i] + t * mediumBlue[i];
    }
  } else {
    final t = (colIdx - mid) / (totalCols - mid);
    for (int i = 0; i < 3; i++) {
      rgb[i] = (1.0 - t) * mediumBlue[i] + t * lightBlue[i];
    }
  }
  return '\x1b[38;2;${rgb[0].round()};${rgb[1].round()};${rgb[2].round()}m';
}

List<String> _applyGradient(List<String> textLines) {
  int maxLen = 0;
  for (final line in textLines) {
    if (line.length > maxLen) maxLen = line.length;
  }

  final result = <String>[];
  for (final line in textLines) {
    final newLine = StringBuffer();
    for (int x = 0; x < line.length; x++) {
      final char = line[x];
      if (char != ' ') {
        newLine.write('${_getGradientColor(x, maxLen)}$char');
      } else {
        newLine.write(char);
      }
    }
    newLine.write(_reset);
    result.add(newLine.toString());
  }
  return result;
}

void printLogo() {
  final mascotLines = <String>[];

  // Combine mascot rows vertically into half-blocks
  for (int y = 0; y < mascotGrid.length; y += 2) {
    final line = StringBuffer();
    for (int x = 0; x < mascotGrid[y].length; x++) {
      final c1 = mascotGrid[y][x];
      final c2 = mascotGrid[y + 1][x];

      final rgb1 = _getRgb(c1);
      final rgb2 = _getRgb(c2);

      if (rgb1 == null && rgb2 == null) {
        line.write(' ');
      } else if (rgb1 == null) {
        line.write('${_color(rgb2!)}▄$_reset');
      } else if (rgb2 == null) {
        line.write('${_color(rgb1)}▀$_reset');
      } else {
        line.write('${_color(rgb2)}${_color(rgb1, bg: true)}▄$_reset');
      }
    }
    mascotLines.add(line.toString());
  }

  print('');

  final textColored = _applyGradient(_textLines);
  textColored.add('');
  textColored.add('  ${_bold}Jaspr CLI$_reset • A modern web framework for Dart');
  textColored.add('  Version $jasprCliVersion ${darkGray.wrap('• Dart $dartSdkVersionShort')}');

  final maxH = math.max(mascotLines.length, textColored.length + 2);
  for (int i = 0; i < maxH; i++) {
    final mPart = i < mascotLines.length ? mascotLines[i] : '                    ';
    final tPart = (i >= 2 && (i - 2) < textColored.length) ? textColored[i - 2] : '';
    print('$mPart    $tPart');
  }

  print('');
}
