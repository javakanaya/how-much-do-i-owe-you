// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userRepositoryHash() => r'8366fba5ac0d6b90c6a637882d24c5e759a5a92f';

/// See also [userRepository].
@ProviderFor(userRepository)
final userRepositoryProvider = AutoDisposeProvider<UserRepository>.internal(
  userRepository,
  name: r'userRepositoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRepositoryRef = AutoDisposeProviderRef<UserRepository>;
String _$currentUserDataHash() => r'e4146b62a82ac236c7a26eef67a08c8e8391b950';

/// See also [CurrentUserData].
@ProviderFor(CurrentUserData)
final currentUserDataProvider =
    AutoDisposeAsyncNotifierProvider<CurrentUserData, UserModel?>.internal(
      CurrentUserData.new,
      name: r'currentUserDataProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$currentUserDataHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentUserData = AutoDisposeAsyncNotifier<UserModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
