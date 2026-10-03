import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Zero Material and Zero Cupertino imports across lib and test', () {
    final targetDirs = [Directory('lib'), Directory('test')];
    final forbidden = [
      RegExp(r'''['"]package:flutter/material\.dart['"]'''),
      RegExp(r'''['"]package:flutter/cupertino\.dart['"]'''),
    ];

    final violations = <String>[];

    for (final dir in targetDirs) {
      if (!dir.existsSync()) continue;
      final files = dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in files) {
        // Skip this test file itself when checking for pattern definition
        if (file.path.endsWith('no_material_guard_test.dart')) continue;

        final lines = file.readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          for (final pattern in forbidden) {
            if (pattern.hasMatch(line)) {
              violations.add('${file.path}:${i + 1} -> $line');
            }
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Found forbidden Material or Cupertino imports:\n${violations.join('\n')}',
    );
  });
}
