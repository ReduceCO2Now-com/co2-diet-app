import 'package:app_settings/app_settings.dart';
import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';

/// Shown inside the barcode scan screen when the camera permission is denied.
///
/// Presents a rationale for camera access and a button that deep-links to the
/// OS Settings app via [AppSettings.openAppSettings].
///
/// T-03-03-03: Camera permission is managed at the OS level via
/// `mobile_scanner` + `permission_handler`. This widget provides the
/// recovery path (Settings deep-link) — no app-level bypass is possible.
class CameraPermissionDeniedWidget extends StatelessWidget {
  /// Creates [CameraPermissionDeniedWidget].
  const CameraPermissionDeniedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'Camera access is needed to scan barcodes',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Allow access in your device settings to use the barcode scanner',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            const FilledButton(
              onPressed: AppSettings.openAppSettings,
              child: Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
