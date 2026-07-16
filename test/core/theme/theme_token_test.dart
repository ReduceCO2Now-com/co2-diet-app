import 'package:co2diet/core/theme/app_theme.dart';
import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors', () {
    test('Test 1: AppColors.primary == const Color(0xFF005222)', () {
      expect(AppColors.primary, equals(const Color(0xFF005222)));
    });

    test('Test 2: AppColors.onPrimary == const Color(0xFFFFFFFF)', () {
      expect(AppColors.onPrimary, equals(const Color(0xFFFFFFFF)));
    });

    test(
      'Test 3: AppColors.primaryContainer == const Color(0xFF006D2F)',
      () {
        expect(
          AppColors.primaryContainer,
          equals(const Color(0xFF006D2F)),
        );
      },
    );

    test('Test 4: AppColors.surface == const Color(0xFFF9F9FC)', () {
      expect(AppColors.surface, equals(const Color(0xFFF9F9FC)));
    });

    test('Test 5: AppColors.error == const Color(0xFFBA1A1A)', () {
      expect(AppColors.error, equals(const Color(0xFFBA1A1A)));
    });
  });

  group('buildLightTheme', () {
    late ThemeData light;

    setUp(() {
      light = buildLightTheme();
    });

    test(
      'Test 6: colorScheme.primary == AppColors.primary',
      () {
        expect(light.colorScheme.primary, equals(AppColors.primary));
      },
    );

    test('Test 8: buildLightTheme builds without throwing', () {
      expect(() => buildLightTheme(), returnsNormally);
    });
  });

  group('buildDarkTheme', () {
    late ThemeData dark;

    setUp(() {
      dark = buildDarkTheme();
    });

    test(
      'Test 7: buildDarkTheme colorScheme.surface == AppColors.inverseSurface',
      () {
        expect(
          dark.colorScheme.surface,
          equals(AppColors.inverseSurface),
        );
      },
    );

    test('Test 8: buildDarkTheme builds without throwing', () {
      expect(() => buildDarkTheme(), returnsNormally);
    });
  });
}
