// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionRepositoryHash() =>
    r'31e53bde2cd20cda40a2b5caa9bc93a81d3478cd';

/// See also [transactionRepository].
@ProviderFor(transactionRepository)
final transactionRepositoryProvider =
    AutoDisposeProvider<TransactionRepository>.internal(
      transactionRepository,
      name: r'transactionRepositoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$transactionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TransactionRepositoryRef =
    AutoDisposeProviderRef<TransactionRepository>;
String _$transactionDataHash() => r'85708710091eba594adcddd82aebcf1c29147e19';

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

/// See also [transactionData].
@ProviderFor(transactionData)
const transactionDataProvider = TransactionDataFamily();

/// See also [transactionData].
class TransactionDataFamily extends Family<AsyncValue<TransactionModel>> {
  /// See also [transactionData].
  const TransactionDataFamily();

  /// See also [transactionData].
  TransactionDataProvider call(String transactionId) {
    return TransactionDataProvider(transactionId);
  }

  @override
  TransactionDataProvider getProviderOverride(
    covariant TransactionDataProvider provider,
  ) {
    return call(provider.transactionId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'transactionDataProvider';
}

/// See also [transactionData].
class TransactionDataProvider
    extends AutoDisposeFutureProvider<TransactionModel> {
  /// See also [transactionData].
  TransactionDataProvider(String transactionId)
    : this._internal(
        (ref) => transactionData(ref as TransactionDataRef, transactionId),
        from: transactionDataProvider,
        name: r'transactionDataProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$transactionDataHash,
        dependencies: TransactionDataFamily._dependencies,
        allTransitiveDependencies:
            TransactionDataFamily._allTransitiveDependencies,
        transactionId: transactionId,
      );

  TransactionDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.transactionId,
  }) : super.internal();

  final String transactionId;

  @override
  Override overrideWith(
    FutureOr<TransactionModel> Function(TransactionDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TransactionDataProvider._internal(
        (ref) => create(ref as TransactionDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        transactionId: transactionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TransactionModel> createElement() {
    return _TransactionDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionDataProvider &&
        other.transactionId == transactionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, transactionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TransactionDataRef on AutoDisposeFutureProviderRef<TransactionModel> {
  /// The parameter `transactionId` of this provider.
  String get transactionId;
}

class _TransactionDataProviderElement
    extends AutoDisposeFutureProviderElement<TransactionModel>
    with TransactionDataRef {
  _TransactionDataProviderElement(super.provider);

  @override
  String get transactionId => (origin as TransactionDataProvider).transactionId;
}

String _$userTransactionsHash() => r'6b93c36fe56359883d5be23ea5b938e759a41ec2';

/// See also [UserTransactions].
@ProviderFor(UserTransactions)
final userTransactionsProvider = AutoDisposeAsyncNotifierProvider<
  UserTransactions,
  List<TransactionModel>
>.internal(
  UserTransactions.new,
  name: r'userTransactionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserTransactions = AutoDisposeAsyncNotifier<List<TransactionModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
