// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateChangesHash() => r'd41b488d2400885495ff80b1b6534c99e41d4796';

/// See also [authStateChanges].
@ProviderFor(authStateChanges)
final authStateChangesProvider = AutoDisposeStreamProvider<User?>.internal(
  authStateChanges,
  name: r'authStateChangesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authStateChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateChangesRef = AutoDisposeStreamProviderRef<User?>;
String _$currentUserHash() => r'25b5ca78380228b50cd8c91689f0d14e5b424fd8';

/// See also [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<User?>;
String _$authErrorHash() => r'203ad9b384c82cea3afc95b3ff30014261d3aafc';

/// See also [AuthError].
@ProviderFor(AuthError)
final authErrorProvider =
    AutoDisposeNotifierProvider<AuthError, String?>.internal(
      AuthError.new,
      name: r'authErrorProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$authErrorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthError = AutoDisposeNotifier<String?>;
String _$authServiceHash() => r'9a60cec24b254d86da409df85ea66a9b611d4265';

/// See also [AuthService].
@ProviderFor(AuthService)
final authServiceProvider =
    AutoDisposeNotifierProvider<AuthService, void>.internal(
      AuthService.new,
      name: r'authServiceProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$authServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthService = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
