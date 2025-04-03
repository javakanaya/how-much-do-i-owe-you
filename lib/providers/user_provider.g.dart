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
String _$userDataHash() => r'7f04aabe8b9823a73f76f1f0ef265cdef9bf8af3';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [userData].
@ProviderFor(userData)
const userDataProvider = UserDataFamily();

/// See also [userData].
class UserDataFamily extends Family<AsyncValue<UserModel?>> {
  /// See also [userData].
  const UserDataFamily();

  /// See also [userData].
  UserDataProvider call(String userId) {
    return UserDataProvider(userId);
  }

  @override
  UserDataProvider getProviderOverride(covariant UserDataProvider provider) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userDataProvider';
}

/// See also [userData].
class UserDataProvider extends AutoDisposeFutureProvider<UserModel?> {
  /// See also [userData].
  UserDataProvider(String userId)
    : this._internal(
        (ref) => userData(ref as UserDataRef, userId),
        from: userDataProvider,
        name: r'userDataProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$userDataHash,
        dependencies: UserDataFamily._dependencies,
        allTransitiveDependencies: UserDataFamily._allTransitiveDependencies,
        userId: userId,
      );

  UserDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<UserModel?> Function(UserDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserDataProvider._internal(
        (ref) => create(ref as UserDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<UserModel?> createElement() {
    return _UserDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserDataProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserDataRef on AutoDisposeFutureProviderRef<UserModel?> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserDataProviderElement
    extends AutoDisposeFutureProviderElement<UserModel?>
    with UserDataRef {
  _UserDataProviderElement(super.provider);

  @override
  String get userId => (origin as UserDataProvider).userId;
}

String _$dummyUserDataHash() => r'36c19a17925c710d5d932fc7449bb9b73590f76d';

/// See also [dummyUserData].
@ProviderFor(dummyUserData)
const dummyUserDataProvider = DummyUserDataFamily();

/// See also [dummyUserData].
class DummyUserDataFamily extends Family<AsyncValue<UserModel?>> {
  /// See also [dummyUserData].
  const DummyUserDataFamily();

  /// See also [dummyUserData].
  DummyUserDataProvider call(String userId) {
    return DummyUserDataProvider(userId);
  }

  @override
  DummyUserDataProvider getProviderOverride(
    covariant DummyUserDataProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dummyUserDataProvider';
}

/// See also [dummyUserData].
class DummyUserDataProvider extends AutoDisposeFutureProvider<UserModel?> {
  /// See also [dummyUserData].
  DummyUserDataProvider(String userId)
    : this._internal(
        (ref) => dummyUserData(ref as DummyUserDataRef, userId),
        from: dummyUserDataProvider,
        name: r'dummyUserDataProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$dummyUserDataHash,
        dependencies: DummyUserDataFamily._dependencies,
        allTransitiveDependencies:
            DummyUserDataFamily._allTransitiveDependencies,
        userId: userId,
      );

  DummyUserDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<UserModel?> Function(DummyUserDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DummyUserDataProvider._internal(
        (ref) => create(ref as DummyUserDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<UserModel?> createElement() {
    return _DummyUserDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DummyUserDataProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DummyUserDataRef on AutoDisposeFutureProviderRef<UserModel?> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _DummyUserDataProviderElement
    extends AutoDisposeFutureProviderElement<UserModel?>
    with DummyUserDataRef {
  _DummyUserDataProviderElement(super.provider);

  @override
  String get userId => (origin as DummyUserDataProvider).userId;
}

String _$currentUserDataHash() => r'e927d4e409d09c0f2f3a4347aec1139b82e79b14';

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
