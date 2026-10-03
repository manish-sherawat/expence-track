// ignore_for_file: avoid_print
import 'dart:io';

/// Strict CI guard ensuring ZERO Material and ZERO Cupertino imports
/// across lib/ and test/.
void main(List<String> args) {
  final targetDirs = [Directory('lib'), Directory('test')];
  final forbiddenPatterns = [
    RegExp(r'''['"]package:flutter/material\.dart['"]'''),
    RegExp(r'''['"]package:flutter/cupertino\.dart['"]'''),
  ];

  int violations = 0;

  for (final dir in targetDirs) {
    if (!dir.existsSync()) continue;

    final files = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        for (final pattern in forbiddenPatterns) {
          if (pattern.hasMatch(line)) {
            print(
              'VIOLATION in ${file.path}:${i + 1}:\n'
              '  $line\n'
              '  --> Material and Cupertino are strictly forbidden! Use only widgets.dart, rendering.dart, etc.\n',
            );
            violations++;
          }
        }
      }
    }
  }

  if (violations > 0) {
    print('FAILED: Found $violations forbidden Material/Cupertino import(s)!');
    exit(1);
  } else {
    print('SUCCESS: Verified 0 Material and 0 Cupertino imports in lib/ and test/.');
    exit(0);
  }
}
