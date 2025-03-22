// providers/settlement_provider.dart
import 'package:flutter/foundation.dart';
import 'package:how_much_do_i_owe_you/models/settlement_model.dart';
import 'package:how_much_do_i_owe_you/models/transaction_model.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/services/settlement_service.dart';
import 'package:how_much_do_i_owe_you/services/user_service.dart';

class SettlementProvider with ChangeNotifier {
  final SettlementService _settlementService = SettlementService();
  final UserService _userService = UserService();

  // Current user ID
  String? _currentUserId;

  // List of all settlements
  List<SettlementModel> _settlements = [];

  // Map of user data for quick lookup
  Map<String, UserModel> _userMap = {};

  // Transaction data for current settlement process
  List<TransactionModel> _transactionsToSettle = [];
  String? _selectedUserId;
  double _totalAmount = 0.0;

  // Loading states
  bool _isLoading = false;
  bool _isCreatingSettlement = false;
  bool _isCancellingSettlement = false;
  String? _errorMessage;
  bool _settlementCreated = false;

  // Getters
  List<SettlementModel> get settlements => _settlements;
  Map<String, UserModel> get userMap => _userMap;
  List<TransactionModel> get transactionsToSettle => _transactionsToSettle;
  String? get selectedUserId => _selectedUserId;
  double get totalAmount => _totalAmount;
  bool get isLoading => _isLoading;
  bool get isCreatingSettlement => _isCreatingSettlement;
  bool get isCancellingSettlement => _isCancellingSettlement;
  String? get errorMessage => _errorMessage;
  bool get settlementCreated => _settlementCreated;

  // Initialize with user ID
  void initialize(String userId) {
    _currentUserId = userId;
    fetchSettlements();
  }

  // Reset the state for a new settlement
  void reset() {
    _transactionsToSettle = [];
    _selectedUserId = null;
    _totalAmount = 0.0;
    _errorMessage = null;
    _settlementCreated = false;
    notifyListeners();
  }

  // Fetch all settlements for the current user
  Future<void> fetchSettlements() async {
    if (_currentUserId == null) return;

    try {
      _setLoading(true);

      // Get settlements from service
      final settlements = await _settlementService.getSettlementsForUser(
        _currentUserId!,
      );

      // Get user data for all involved users
      final userIds = <String>{};
      for (var settlement in settlements) {
        userIds.add(settlement.payerId);
        userIds.add(settlement.receiverId);
      }

      // Remove current user
      userIds.remove(_currentUserId);

      // Fetch all users
      for (var userId in userIds) {
        final user = await _userService.getUserById(userId);
        if (user != null) {
          _userMap[userId] = user;
        }
      }

      _settlements = settlements;
      _errorMessage = null;
    } catch (e) {
      debugPrint('Error in fetchSettlements: $e');
      _errorMessage = 'Failed to load settlements. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  // Prepare to create a settlement with a specific user
  Future<void> prepareSettlementWithUser(String userId) async {
    if (_currentUserId == null) return;

    try {
      _setLoading(true);
      _errorMessage = null;
      _selectedUserId = userId;

      // Get settleable transactions
      final transactions = await _settlementService.getSettleableTransactions(
        _currentUserId!,
        userId,
      );

      // Calculate total amount
      _totalAmount = await _settlementService.calculateOutstandingAmount(
        _currentUserId!,
        userId,
      );

      _transactionsToSettle = transactions;
    } catch (e) {
      debugPrint('Error preparing settlement: $e');
      _errorMessage = 'Failed to prepare settlement. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  // Create a settlement
  Future<bool> createSettlement() async {
    if (_currentUserId == null || _selectedUserId == null) {
      _errorMessage = 'Invalid user selection';
      notifyListeners();
      return false;
    }

    if (_transactionsToSettle.isEmpty) {
      _errorMessage = 'No transactions selected for settlement';
      notifyListeners();
      return false;
    }

    try {
      _isCreatingSettlement = true;
      _errorMessage = null;
      notifyListeners();

      // Get transaction IDs
      final transactionIds =
          _transactionsToSettle
              .map((transaction) => transaction.transactionId)
              .toList();

      // Create settlement
      await _settlementService.createSettlement(
        payerId: _currentUserId!,
        receiverId: _selectedUserId!,
        amount: _totalAmount,
        transactionIds: transactionIds,
      );

      _settlementCreated = true;
      _isCreatingSettlement = false;
      notifyListeners();

      // Refresh settlements list
      await fetchSettlements();

      return true;
    } catch (e) {
      _errorMessage = 'Error creating settlement: $e';
      _isCreatingSettlement = false;
      notifyListeners();
      return false;
    }
  }

  // Cancel a settlement
  Future<bool> cancelSettlement(String settlementId) async {
    try {
      _isCancellingSettlement = true;
      _errorMessage = null;
      notifyListeners();

      final success = await _settlementService.cancelSettlement(settlementId);

      _isCancellingSettlement = false;
      notifyListeners();

      if (success) {
        // Refresh settlements list
        await fetchSettlements();
      }

      return success;
    } catch (e) {
      _errorMessage = 'Error cancelling settlement: $e';
      _isCancellingSettlement = false;
      notifyListeners();
      return false;
    }
  }

  // Get settlements between current user and another user
  Future<List<SettlementModel>> getSettlementsBetweenUsers(
    String otherUserId,
  ) async {
    if (_currentUserId == null) return [];

    try {
      return await _settlementService.getSettlementsBetweenUsers(
        _currentUserId!,
        otherUserId,
      );
    } catch (e) {
      debugPrint('Error getting settlements between users: $e');
      return [];
    }
  }

  // Helper to set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
