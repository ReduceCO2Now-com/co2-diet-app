// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for the app's [GoRouter] instance.
///
/// keepAlive: true — the router must persist for the full app lifetime.
/// go_router 17.x uses [StatefulShellRoute.indexedStack] for persistent
/// bottom-navigation state across tab switches.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Riverpod provider for the app's [GoRouter] instance.
///
/// keepAlive: true — the router must persist for the full app lifetime.
/// go_router 17.x uses [StatefulShellRoute.indexedStack] for persistent
/// bottom-navigation state across tab switches.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Riverpod provider for the app's [GoRouter] instance.
  ///
  /// keepAlive: true — the router must persist for the full app lifetime.
  /// go_router 17.x uses [StatefulShellRoute.indexedStack] for persistent
  /// bottom-navigation state across tab switches.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'1a0f8b0fd2426bb3e3dab01daef7646a1d7d665c';
