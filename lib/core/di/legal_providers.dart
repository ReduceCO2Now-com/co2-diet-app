// Legal document DI providers: LegalDocumentLoader.
//
// Kept in a separate file (mirrors co2_settings_providers.dart) to keep
// providers.dart focused on core infrastructure (AppDatabase, profile).

import 'package:co2diet/domain/services/legal_document_loader.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'legal_providers.g.dart';

/// Provides the [LegalDocumentLoader] used by Legal Consent / Legal Hub
/// screens to read `docs/legal/*.md` documents and their versions.
///
/// Not keepAlive — the loader is stateless (const constructor) and holds no
/// DB/stream resources, so it is cheap to reconstruct on demand.
@riverpod
LegalDocumentLoader legalDocumentLoader(Ref ref) => const LegalDocumentLoader();
