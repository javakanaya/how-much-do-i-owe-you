import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/models/index.dart';
import 'package:how_much_do_i_owe_you/models/transaction_participant.dart';
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

    // For development/testing, use dummy transactions
    // Comment this out to use real data
    return getDummyTransactions(authUser.uid);

    return _fetchUserTransactions(authUser.uid);
  }

  Future<List<TransactionModel>> _fetchUserTransactions(String userId) async {
    final repository = ref.read(transactionRepositoryProvider);
    return await repository.getUserTransactions(userId);
  }

  // Helper method to create dummy transactions that align with the dummy balances
  List<TransactionModel> getDummyTransactions(String currentUserId) {
    final now = DateTime.now();
    final dummyUsers = ['user1', 'user2', 'user3', 'user4', 'user5'];

    // These transactions should result in the following balances:
    // - You owe 50,000 to user1
    // - You owe 25,000 to user2
    // - user3 owes you 75,000
    // - user4 owes you 35,000
    // - user5 owes you 10,000 (recently updated)

    return [
      // Transaction 1: User1 paid for dinner (you owe them)
      TransactionModel(
        id: 'tx1',
        description: 'Dinner at Restaurant',
        amount: 150000,
        date: now.subtract(const Duration(days: 5)),
        payerId: dummyUsers[0], // user1
        status: 'pending',
        participants: [
          TransactionParticipant(
            userId: currentUserId,
            owedAmount: 50000, // You owe 50,000
            isPayer: false,
            isSettled: false,
          ),
          TransactionParticipant(
            userId: dummyUsers[0], // user1
            owedAmount: 50000,
            isPayer: true,
            isSettled: false,
          ),
          TransactionParticipant(
            userId: dummyUsers[4], // user5
            owedAmount: 50000,
            isPayer: false,
            isSettled: false,
          ),
        ],
      ),

      // Transaction 2: User2 paid for movie tickets (you owe them)
      TransactionModel(
        id: 'tx2',
        description: 'Movie Tickets',
        amount: 75000,
        date: now.subtract(const Duration(days: 3)),
        payerId: dummyUsers[1], // user2
        status: 'pending',
        participants: [
          TransactionParticipant(
            userId: currentUserId,
            owedAmount: 25000, // You owe 25,000
            isPayer: false,
            isSettled: false,
          ),
          TransactionParticipant(
            userId: dummyUsers[1], // user2
            owedAmount: 25000,
            isPayer: true,
            isSettled: false,
          ),
          TransactionParticipant(
            userId: dummyUsers[3], // user4
            owedAmount: 25000,
            isPayer: false,
            isSettled: false,
          ),
        ],
      ),

      // Transaction 3: You paid for groceries (user3 owes you)
      TransactionModel(
        id: 'tx3',
        description: 'Groceries',
        amount: 150000,
        date: now.subtract(const Duration(days: 7)),
        payerId: currentUserId,
        status: 'pending',
        participants: [
          TransactionParticipant(
            userId: currentUserId,
            owedAmount: 75000,
            isPayer: true,
            isSettled: false,
          ),
          TransactionParticipant(
            userId: dummyUsers[2], // user3
            owedAmount: 75000, // They owe you 75,000
            isPayer: false,
            isSettled: false,
          ),
        ],
      ),

      // Transaction 4: You paid for taxi (user4 owes you)
      TransactionModel(
        id: 'tx4',
        description: 'Taxi Ride',
        amount: 70000,
        date: now.subtract(const Duration(days: 1)),
        payerId: currentUserId,
        status: 'pending',
        participants: [
          TransactionParticipant(
            userId: currentUserId,
            owedAmount: 35000,
            isPayer: true,
            isSettled: false,
          ),
          TransactionParticipant(
            userId: dummyUsers[3], // user4
            owedAmount: 35000, // They owe you 35,000
            isPayer: false,
            isSettled: false,
          ),
        ],
      ),

      // Transaction 5: You paid for lunch (user5 owes you)
      TransactionModel(
        id: 'tx5',
        description: 'Lunch',
        amount: 60000,
        date: now.subtract(const Duration(hours: 12)),
        payerId: currentUserId,
        status: 'pending',
        participants: [
          TransactionParticipant(
            userId: currentUserId,
            owedAmount: 30000,
            isPayer: true,
            isSettled: false,
          ),
          TransactionParticipant(
            userId: dummyUsers[4], // user5
            owedAmount: 30000,
            isPayer: false,
            isSettled: false,
          ),
        ],
      ),

      // Transaction 6: Another transaction with user5 (adds up to 10,000 balance)
      TransactionModel(
        id: 'tx6',
        description: 'Coffee & Snacks',
        amount: 40000,
        date: now.subtract(const Duration(hours: 14)),
        payerId: dummyUsers[4], // user5
        status: 'pending',
        participants: [
          TransactionParticipant(
            userId: currentUserId,
            owedAmount: 20000, // You owe 20,000
            isPayer: false,
            isSettled: false,
          ),
          TransactionParticipant(
            userId: dummyUsers[4], // user5
            owedAmount: 20000,
            isPayer: true,
            isSettled: false,
          ),
        ],
      ),

      // Transaction 7: Settled transaction (for history)
      TransactionModel(
        id: 'tx7',
        description: 'Weekend Trip',
        amount: 500000,
        date: now.subtract(const Duration(days: 20)),
        payerId: currentUserId,
        status: 'settled',
        participants: [
          TransactionParticipant(
            userId: currentUserId,
            owedAmount: 250000,
            isPayer: true,
            isSettled: true,
            settledAt: now.subtract(const Duration(days: 15)),
          ),
          TransactionParticipant(
            userId: dummyUsers[1], // user2
            owedAmount: 250000,
            isPayer: false,
            isSettled: true,
            settledAt: now.subtract(const Duration(days: 15)),
          ),
        ],
      ),
    ];
  }
}
