// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dummy_transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dummyTransactionDataHash() =>
    r'6f8418e74a7857833ba19a903af04fa137624cd0';

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

/// See also [dummyTransactionData].
@ProviderFor(dummyTransactionData)
const dummyTransactionDataProvider = DummyTransactionDataFamily();

/// See also [dummyTransactionData].
class DummyTransactionDataFamily extends Family<AsyncValue<TransactionModel>> {
  /// See also [dummyTransactionData].
  const DummyTransactionDataFamily();

  /// See also [dummyTransactionData].
  DummyTransactionDataProvider call(String transactionId) {
    return DummyTransactionDataProvider(transactionId);
  }

  @override
  DummyTransactionDataProvider getProviderOverride(
    covariant DummyTransactionDataProvider provider,
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
  String? get name => r'dummyTransactionDataProvider';
}

/// See also [dummyTransactionData].
class DummyTransactionDataProvider
    extends AutoDisposeFutureProvider<TransactionModel> {
  /// See also [dummyTransactionData].
  DummyTransactionDataProvider(String transactionId)
    : this._internal(
        (ref) =>
            dummyTransactionData(ref as DummyTransactionDataRef, transactionId),
        from: dummyTransactionDataProvider,
        name: r'dummyTransactionDataProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$dummyTransactionDataHash,
        dependencies: DummyTransactionDataFamily._dependencies,
        allTransitiveDependencies:
            DummyTransactionDataFamily._allTransitiveDependencies,
        transactionId: transactionId,
      );

  DummyTransactionDataProvider._internal(
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
    FutureOr<TransactionModel> Function(DummyTransactionDataRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DummyTransactionDataProvider._internal(
        (ref) => create(ref as DummyTransactionDataRef),
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
    return _DummyTransactionDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DummyTransactionDataProvider &&
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
mixin DummyTransactionDataRef
    on AutoDisposeFutureProviderRef<TransactionModel> {
  /// The parameter `transactionId` of this provider.
  String get transactionId;
}

class _DummyTransactionDataProviderElement
    extends AutoDisposeFutureProviderElement<TransactionModel>
    with DummyTransactionDataRef {
  _DummyTransactionDataProviderElement(super.provider);

  @override
  String get transactionId =>
      (origin as DummyTransactionDataProvider).transactionId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
