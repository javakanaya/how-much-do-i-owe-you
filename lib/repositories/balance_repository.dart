import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:how_much_do_i_owe_you/models/index.dart';

class BalanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _balancesCollection => _firestore.collection('balances');

  // Fetch all balances for a user
  Future<List<BalanceModel>> getUserBalances(String userId) async {
    final queryA = await _balancesCollection.where('userIdA', isEqualTo: userId).get();

    final queryB = await _balancesCollection.where('userIdB', isEqualTo: userId).get();

    List<BalanceModel> balances = [];

    for (var doc in queryA.docs) {
      balances.add(BalanceModel.fromFirestore(doc));
    }

    for (var doc in queryB.docs) {
      final balance = BalanceModel.fromFirestore(doc);
      // Invert the balance if userIdB is the current user
      balances.add(balance.copyWith(amount: -balance.amount));
    }

    return balances;
  }
}

/* 
 * Sample Usage Example:
 * ---------------------
 * 
 * // Example firestore data:
 * // Document 1 in 'balances' collection
 * {
 *   "id": "balance1",
 *   "userIdA": "user123",
 *   "userIdB": "friend456",
 *   "amount": 50.0,         // user123 owes friend456 $50
 *   "description": "Dinner at restaurant",
 *   "date": "2023-08-15"
 * }
 * 
 * // Document 2 in 'balances' collection
 * {
 *   "id": "balance2",
 *   "userIdA": "friend789",
 *   "userIdB": "user123",
 *   "amount": 25.0,         // friend789 owes user123 $25
 *   "description": "Movie tickets",
 *   "date": "2023-08-10"
 * }
 * 
 * // Usage in code:
 * final repository = BalanceRepository();
 * final balances = await repository.getUserBalances("user123");
 * 
 * // Result would be:
 * // [
 * //   BalanceModel(id: "balance1", userIdA: "user123", userIdB: "friend456", amount: 50.0, ...),
 * //   BalanceModel(id: "balance2", userIdA: "friend789", userIdB: "user123", amount: -25.0, ...)  // Note: amount is inverted
 * // ]
 * 
 * // Interpretation:
 * // Positive amount means current user owes money to the other user
 * // Negative amount means other user owes money to current user
 */
