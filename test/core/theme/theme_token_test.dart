import 'package:co2diet/core/theme/app_theme.dart';
import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors — DESIGN.md color token spot checks', () {
    // Tests 1–8: verify hex values are verbatim from DESIGN.md
    test('Test 1: AppColors.primary == const Color(0xFF005222)', () {
      expect(AppColors.primary, equals(const Color(0xFF005222)));
    });

    test('Test 2: AppColors.onPrimary == const Color(0xFFFFFFFF)', () {
      expect(AppColors.onPrimary, equals(const Color(0xFFFFFFFF)));
    });

    test(
      'Test 3: AppColors.primaryContainer == const Color(0xFF006D2F)',
      () {
        expect(AppColors.primaryContainer, equals(const Color(0xFF006D2F)));
      },
    );

    test(
      'Test 4: AppColors.onPrimaryContainer == const Color(0xFF90EC9F)',
      () {
        expect(
          AppColors.onPrimaryContainer,
          equals(const Color(0xFF90EC9F)),
        );
      },
    );

    test('Test 5: AppColors.surface == const Color(0xFFF9F9FC)', () {
      expect(AppColors.surface, equals(const Color(0xFFF9F9FC)));
    });

    test('Test 6: AppColors.error == const Color(0xFFBA1A1A)', () {
      expect(AppColors.error, equals(const Color(0xFFBA1A1A)));
    });

    test('Test 7: AppColors.secondary == const Color(0xFF0155C7)', () {
      expect(AppColors.secondary, equals(const Color(0xFF0155C7)));
    });

    test(
      'Test 8: AppColors.inverseSurface == const Color(0xFF2F3133)',
      () {
        expect(AppColors.inverseSurface, equals(const Color(0xFF2F3133)));
      },
    );
  });

  group('buildLightTheme — ThemeData assertions', () {
    late ThemeData light;

    setUp(() {
      light = buildLightTheme();
    });

    test('Test 9: colorScheme.primary == AppColors.primary', () {
      expect(light.colorScheme.primary, equals(AppColors.primary));
    });

    test('Test 10: buildLightTheme() does not throw', () {
      expect(buildLightTheme, returnsNormally);
    });

    test('Test 12: colorScheme.surface == AppColors.surface', () {
      expect(light.colorScheme.surface, equals(AppColors.surface));
    });
  });

  group('buildDarkTheme — ThemeData assertions', () {
    test('Test 11: buildDarkTheme() does not throw', () {
      expect(buildDarkTheme, returnsNormally);
    });
  });
}
