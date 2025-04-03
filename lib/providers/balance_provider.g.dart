// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$balanceRepositoryHash() => r'c59425a0b410e64747a1c67b33267dd64677df24';

/// See also [balanceRepository].
@ProviderFor(balanceRepository)
final balanceRepositoryProvider =
    AutoDisposeProvider<BalanceRepository>.internal(
      balanceRepository,
      name: r'balanceRepositoryProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$balanceRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BalanceRepositoryRef = AutoDisposeProviderRef<BalanceRepository>;
String _$balanceDataHash() => r'43082f51319502de9e129a6ba38c1f6157d03e00';

/// See also [BalanceData].
@ProviderFor(BalanceData)
final balanceDataProvider =
    AutoDisposeAsyncNotifierProvider<BalanceData, List<BalanceModel>>.internal(
      BalanceData.new,
      name: r'balanceDataProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$balanceDataHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BalanceData = AutoDisposeAsyncNotifier<List<BalanceModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
