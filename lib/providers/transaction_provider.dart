import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/models/index.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/repositories/transaction_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_provider.g.dart';

@riverpod
TransactionRepository transactionRepository(Ref ref) {
  return TransactionRepository();
}

@riverpod
Future<TransactionModel> transactionData(Ref ref, String transactionId) async {
  final repository = ref.read(transactionRepositoryProvider);

  try {
    return await repository.getTransactionById(transactionId);
  } catch (e) {
    throw Exception('Failed to fetch transaction data: $e');
  }
}

@riverpod
class UserTransactions extends _$UserTransactions {
  @override
  FutureOr<List<TransactionModel>> build() async {
    final authUser = ref.watch(currentUserProvider);

    if (authUser == null) {
      return [];
    }

    return _fetchUserTransactions(authUser.uid);
  }

  Future<List<TransactionModel>> _fetchUserTransactions(String userId) async {
    final repository = ref.read(transactionRepositoryProvider);
    return await repository.getUserTransactions(userId);
  }
}
