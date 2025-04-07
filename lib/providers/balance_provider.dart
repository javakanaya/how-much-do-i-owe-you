import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/models/index.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/repositories/balance_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'balance_provider.g.dart';

enum BalanceStatus { positive, negative, zero }

@riverpod
BalanceRepository balanceRepository(Ref ref) {
  return BalanceRepository();
}

@riverpod
class BalanceData extends _$BalanceData {
  @override
  FutureOr<List<BalanceModel>> build() async {
    final authUser = ref.watch(currentUserProvider);
    // Return an empty list immediately if there's no authenticated user
    if (authUser == null) {
      return [];
    }

    // Return a Future if there is an authenticated user, meaning "I'll get you the balances soon"
    return _fetchUserBalances(authUser.uid);
  }

  Future<List<BalanceModel>> _fetchUserBalances(String userId) async {
    final repository = ref.read(balanceRepositoryProvider);
    return await repository.getUserBalances(userId);
  }
}
