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

    // Fetch for testing purposes
    // throw Exception("This is a test error to preview the error UI");

    // Return a Future if there is an authenticated user, meaning "I'll get you the balances soon"
    return _getDummyBalances(authUser.uid);
  }

  Future<List<BalanceModel>> _fetchUserBalances(String userId) async {
    final repository = ref.read(balanceRepositoryProvider);
    return await repository.getUserBalances(userId);
  }

  // Method for generating dummy data
  List<BalanceModel> _getDummyBalances(String userId) {
    // Create some dummy users to have balances with
    final dummyUsers = [
      'user1', // You owe this user
      'user2', // You owe this user
      'user3', // This user owes you
      'user4', // This user owes you
      'user5', // Zero balance (settled)
    ];

    // Create dummy balances list
    return [
      // Balances where you owe money (negative amounts)
      BalanceModel(
        id: 'balance1',
        userIdA: userId,
        userIdB: dummyUsers[0],
        amount: -50000.0, // You owe 50,000 to user1
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
      ),
      BalanceModel(
        id: 'balance2',
        userIdA: userId,
        userIdB: dummyUsers[1],
        amount: -25000.0, // You owe 25,000 to user2
        lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
      ),

      // Balances where others owe you money (positive amounts)
      BalanceModel(
        id: 'balance3',
        userIdA: userId,
        userIdB: dummyUsers[2],
        amount: 75000.0, // user3 owes you 75,000
        lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
      ),
      BalanceModel(
        id: 'balance4',
        userIdA: userId,
        userIdB: dummyUsers[3],
        amount: 35000.0, // user4 owes you 35,000
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      ),

      // A settled balance (zero amount)
      BalanceModel(
        id: 'balance5',
        userIdA: userId,
        userIdB: dummyUsers[4],
        amount: 10000.0, // Settled balance with user5
        lastUpdated: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }
}
