// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [NotificationPrefsDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [notificationPrefsRepositoryProvider] which
/// is also keep-alive.

@ProviderFor(notificationPrefsDao)
final notificationPrefsDaoProvider = NotificationPrefsDaoProvider._();

/// Provides the [NotificationPrefsDao] bound to the live `AppDatabase`.
///
/// keepAlive: true — DAO must persist for the full ProviderScope lifetime
/// because it is referenced by [notificationPrefsRepositoryProvider] which
/// is also keep-alive.

final class NotificationPrefsDaoProvider
    extends
        $FunctionalProvider<
          NotificationPrefsDao,
          NotificationPrefsDao,
          NotificationPrefsDao
        >
    with $Provider<NotificationPrefsDao> {
  /// Provides the [NotificationPrefsDao] bound to the live `AppDatabase`.
  ///
  /// keepAlive: true — DAO must persist for the full ProviderScope lifetime
  /// because it is referenced by [notificationPrefsRepositoryProvider] which
  /// is also keep-alive.
  NotificationPrefsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPrefsDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPrefsDaoHash();

  @$internal
  @override
  $ProviderElement<NotificationPrefsDao> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationPrefsDao create(Ref ref) {
    return notificationPrefsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPrefsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationPrefsDao>(value),
    );
  }
}

String _$notificationPrefsDaoHash() =>
    r'642327bb1c9b9b66103442a3fdb9c60e8313647d';

/// Provides the [INotificationPrefsRepository] for the Notification Settings
/// feature.
///
/// The declared return type is the abstract [INotificationPrefsRepository]
/// interface — callers in the presentation layer depend only on the
/// interface, not on [NotificationPrefsRepository].

@ProviderFor(notificationPrefsRepository)
final notificationPrefsRepositoryProvider =
    NotificationPrefsRepositoryProvider._();

/// Provides the [INotificationPrefsRepository] for the Notification Settings
/// feature.
///
/// The declared return type is the abstract [INotificationPrefsRepository]
/// interface — callers in the presentation layer depend only on the
/// interface, not on [NotificationPrefsRepository].

final class NotificationPrefsRepositoryProvider
    extends
        $FunctionalProvider<
          INotificationPrefsRepository,
          INotificationPrefsRepository,
          INotificationPrefsRepository
        >
    with $Provider<INotificationPrefsRepository> {
  /// Provides the [INotificationPrefsRepository] for the Notification Settings
  /// feature.
  ///
  /// The declared return type is the abstract [INotificationPrefsRepository]
  /// interface — callers in the presentation layer depend only on the
  /// interface, not on [NotificationPrefsRepository].
  NotificationPrefsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPrefsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPrefsRepositoryHash();

  @$internal
  @override
  $ProviderElement<INotificationPrefsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  INotificationPrefsRepository create(Ref ref) {
    return notificationPrefsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(INotificationPrefsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<INotificationPrefsRepository>(value),
    );
  }
}

String _$notificationPrefsRepositoryHash() =>
    r'bd86dbc12357dfe2c08e6a5ebaceb492b161f8b5';
