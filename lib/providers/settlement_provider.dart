// providers/settlement_provider.dart
import 'package:flutter/foundation.dart';
import 'package:how_much_do_i_owe_you/models/transaction_model.dart';
import 'package:how_much_do_i_owe_you/models/settlement_model.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/services/settlement_service.dart';
import 'package:how_much_do_i_owe_you/services/transaction_service.dart';
import 'package:how_much_do_i_owe_you/services/user_service.dart';
import 'package:uuid/uuid.dart';

class SettlementProvider with ChangeNotifier {
  final SettlementService _settlementService = SettlementService();
  final TransactionService _transactionService = TransactionService();
  final UserService _userService = UserService();
  final Uuid _uuid = const Uuid();

  String _currentUserId = '';
  String _otherUserId = '';
  List<TransactionModel> _transactionsToSettle = [];
  List<SettlementModel> _settlements = [];
  Map<String, UserModel> _userMap = {};
  double _totalAmount = 0.0;
  bool _isLoading = false;
  bool _isCreatingSettlement = false;
  String? _errorMessage;

  // Getters
  List<TransactionModel> get transactionsToSettle => _transactionsToSettle;
  List<SettlementModel> get settlements => _settlements;
  Map<String, dynamic> get userMap => _userMap;
  double get totalAmount => _totalAmount;
  bool get isLoading => _isLoading;
  bool get isCreatingSettlement => _isCreatingSettlement;
  String? get errorMessage => _errorMessage;

  // Initialize with current user ID
  void initialize(String userId) {
    _currentUserId = userId;
    fetchSettlements();
  }

  // Fetch all settlements for the current user
  Future<void> fetchSettlements() async {
    if (_currentUserId.isEmpty) return;

    try {
      _setLoading(true);
      _errorMessage = null;

      // Get all settlements involving the current user
      final settlements = await _settlementService.getSettlementsForUser(
        _currentUserId,
      );

      // Build a map of all user IDs involved in the settlements
      final Set<String> userIds = {};
      for (var settlement in settlements) {
        userIds.add(settlement.payerId);
        userIds.add(settlement.receiverId);
      }

      // Remove current user from the set
      userIds.remove(_currentUserId);

      // Fetch user details for all involved users
      final Map<String, UserModel> users = {};
      for (var userId in userIds) {
        final user = await _userService.getUserById(userId);
        if (user != null) {
          users[userId] = user;
        }
      }

      _settlements = settlements;
      _userMap = users;
    } catch (e) {
      debugPrint('Error fetching settlements: $e');
      _errorMessage = 'Failed to load settlements. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  // Prepare settlement with another user
  Future<void> prepareSettlementWithUser(String otherUserId) async {
    try {
      _setLoading(true);
      _otherUserId = otherUserId; // javakanaya
      _errorMessage = null;

      // Get all unsettled transactions between these users
      final transactions = await _transactionService
          .getUnsettledTransactionsBetweenUsers(
            otherUserId, // javakanaya
            _currentUserId, // javakanaya3
          );

      // Calculate total settlement amount
      double total = 0.0;
      for (var transaction in transactions) {
        // Only include transactions where the current user owes money
        // payer not javakanaya3
        if (transaction.payerId != _currentUserId) {
          // For each transaction, find the participant entry for the current user

          final participant = await _transactionService
              .getParticipantForTransaction(
                transaction.transactionId,
                _currentUserId,
              );
          if (participant != null && !participant.isSettled) {
            total += participant.owedAmount;
          }
        }
      }

      _transactionsToSettle = transactions;
      _totalAmount = total;
    } catch (e) {
      debugPrint('Error preparing settlement: $e');
      _errorMessage = 'Failed to load transactions. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  // Create settlement
  Future<bool> createSettlement() async {
    if (_transactionsToSettle.isEmpty) {
      _errorMessage = 'No transactions to settle.';
      notifyListeners();
      return false;
    }

    try {
      _isCreatingSettlement = true;
      notifyListeners();

      // Extract transaction IDs
      final transactionIds =
          _transactionsToSettle
              .map((transaction) => transaction.transactionId)
              .toList();

      // Create settlement model
      final settlementId = _uuid.v4();
      final settlement = SettlementModel(
        settlementId: settlementId,
        payerId: _currentUserId,
        receiverId: _otherUserId,
        amount: _totalAmount,
        date: DateTime.now(),
        status: 'completed',
        transactionIds: transactionIds,
      );

      // Create settlement and update transactions
      await _settlementService.createSettlement(settlement);

      // Refresh settlements list
      await fetchSettlements();

      _errorMessage = null;
      return true;
    } catch (e) {
      debugPrint('Error creating settlement: $e');
      _errorMessage = 'Failed to create settlement. Please try again.';
      notifyListeners();
      return false;
    } finally {
      _isCreatingSettlement = false;
      notifyListeners();
    }
  }

  // Cancel settlement
  Future<bool> cancelSettlement(String settlementId) async {
    try {
      _isCreatingSettlement = true;
      notifyListeners();

      final success = await _settlementService.cancelSettlement(settlementId);

      if (!success) {
        _errorMessage =
            'Failed to cancel settlement. It may be older than 24 hours.';
        notifyListeners();
        return false;
      }

      // Refresh settlements list
      await fetchSettlements();

      _errorMessage = null;
      return true;
    } catch (e) {
      debugPrint('Error canceling settlement: $e');
      _errorMessage = 'Failed to cancel settlement: $e';
      notifyListeners();
      return false;
    } finally {
      _isCreatingSettlement = false;
      notifyListeners();
    }
  }

  // Helper to set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
