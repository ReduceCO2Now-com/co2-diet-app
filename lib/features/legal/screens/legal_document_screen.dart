import 'package:co2diet/core/di/legal_providers.dart';
import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Identifies one of the four bundled `docs/legal/*.md` documents.
enum LegalDocId {
  /// `docs/legal/terms.md` — Terms of Service.
  terms,

  /// `docs/legal/privacy.md` — Privacy Policy.
  privacy,

  /// `docs/legal/health_disclaimer.md` — Health Disclaimer.
  healthDisclaimer,

  /// `docs/legal/impressum.md` — Impressum.
  impressum,
}

/// Maps [LegalDocId] variants to their bundled asset filename and
/// human-readable screen title.
extension LegalDocIdX on LegalDocId {
  /// The `docs/legal/` asset filename for this document.
  String get assetFileName {
    switch (this) {
      case LegalDocId.terms:
        return 'terms.md';
      case LegalDocId.privacy:
        return 'privacy.md';
      case LegalDocId.healthDisclaimer:
        return 'health_disclaimer.md';
      case LegalDocId.impressum:
        return 'impressum.md';
    }
  }

  /// The human-readable app-bar title for this document.
  String get title {
    switch (this) {
      case LegalDocId.terms:
        return 'Terms of Service';
      case LegalDocId.privacy:
        return 'Privacy Policy';
      case LegalDocId.healthDisclaimer:
        return 'Health Disclaimer';
      case LegalDocId.impressum:
        return 'Impressum';
    }
  }
}

/// Shared full-document screen rendering any of the four
/// `docs/legal/*.md` files given only a [docId].
///
/// The single component both the Legal Consent screen (Plan 06-07) and
/// the Legal Hub (Plan 06-08) reuse for "View Terms/Privacy/Disclaimer/
/// Impressum" -- 06-CONTEXT.md explicitly locks document-screen reuse
/// ("the same full-document screens the Legal Hub uses -- reuse, not
/// separate lighter dialogs").
class LegalDocumentScreen extends ConsumerWidget {
  /// Creates a [LegalDocumentScreen] rendering [docId]'s document.
  const LegalDocumentScreen({required this.docId, super.key});

  /// Which of the four bundled legal documents to render.
  final LegalDocId docId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(docId.title, style: AppTextTheme.headlineLgMobile),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<({String version, String body})>(
          future: ref.watch(legalDocumentLoaderProvider).load(
            docId.assetFileName,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text('Unable to load this document.'),
              );
            }
            return Markdown(data: snapshot.data!.body);
          },
        ),
      ),
    );
  }
}
