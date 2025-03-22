// providers/balance_provider.dart
import 'package:flutter/foundation.dart';
import '../models/balance_model.dart';
import '../models/person_balance_model.dart';
import '../services/balance_service.dart';

class BalanceProvider with ChangeNotifier {
  final BalanceService _balanceService;

  // Constructor with dependency injection
  BalanceProvider(this._balanceService);

  // Current user ID
  String? _currentUserId;

  // List of all balances involving the current user
  List<PersonBalance> _personBalances = [];

  // Total balance (positive = owed to user, negative = user owes)
  double _totalBalance = 0.0;

  // Loading state
  bool _isLoading = false;

  // Error state
  String? _errorMessage;

  // Getters
  double get totalBalance => _totalBalance;
  List<PersonBalance> get personBalances => _personBalances;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize with user ID
  void initialize(String userId) {
    _currentUserId = userId;
    fetchBalances();
  }

  // Fetch balances from service
  Future<void> fetchBalances() async {
    if (_currentUserId == null) return;

    try {
      _setLoading(true);

      // Get balances from service
      final balanceModels = await _balanceService.fetchUserBalances(
        _currentUserId!,
      );

      // Reset total balance
      _totalBalance = 0.0;

      // Create PersonBalance list
      final List<PersonBalance> newPersonBalances = [];

      // Process each balance
      for (var balance in balanceModels) {
        // Get the other user's ID
        final otherUserId = balance.getOtherUserId(_currentUserId!);

        // Get user data from service
        final userModel = await _balanceService.fetchUserById(otherUserId);

        if (userModel == null) continue;

        // Count transactions between users
        final transactionCount = await _balanceService
            .countTransactionsBetweenUsers(_currentUserId!, otherUserId);

        // Create PersonBalance object
        final personBalance = PersonBalance.fromModels(
          balanceModel: balance,
          userModel: userModel,
          currentUserId: _currentUserId!,
          transactionCount: transactionCount,
        );

        // Add to list
        newPersonBalances.add(personBalance);

        // Update total balance
        if (personBalance.isPositive) {
          _totalBalance += personBalance.balance;
        } else {
          _totalBalance -= personBalance.balance;
        }
      }

      // Update the list
      _personBalances = newPersonBalances;
      _errorMessage = null;
    } catch (e) {
      debugPrint('Error in fetchBalances: $e');
      _errorMessage = 'Failed to load balances. Please try again.';

      // For development: use dummy data if there's an error
      _personBalances = PersonBalance.getDummyData();
      _totalBalance = 27.50; // 42.50 - 15.00
    } finally {
      _setLoading(false);
    }
  }

  // Get PersonBalance for a specific user
  PersonBalance? getPersonBalance(String userId) {
    try {
      return _personBalances.firstWhere((balance) => balance.userId == userId);
    } catch (e) {
      return null;
    }
  }

  // Update balance after a transaction or settlement
  Future<void> updateBalanceAfterTransaction(
    String otherUserId,
    double amount,
  ) async {
    if (_currentUserId == null) return;

    try {
      _setLoading(true);

      // Get existing balance between users
      BalanceModel? existingBalance = await _balanceService
          .getBalanceBetweenUsers(_currentUserId!, otherUserId);

      if (existingBalance != null) {
        // Update existing balance
        double newAmount = existingBalance.amount;

        // If current user is userIdA, add amount; otherwise subtract
        if (existingBalance.userIdA == _currentUserId) {
          newAmount += amount;
        } else {
          newAmount -= amount;
        }

        // Update balance
        final updatedBalance = existingBalance.copyWith(
          amount: newAmount,
          lastUpdated: DateTime.now(),
        );

        await _balanceService.updateBalance(updatedBalance);
      } else {
        // Create new balance
        final newBalance = BalanceModel(
          balanceId: '', // Will be set by service
          userIdA: _currentUserId!,
          userIdB: otherUserId,
          amount: amount,
          lastUpdated: DateTime.now(),
        );

        await _balanceService.createBalance(newBalance);
      }

      // Refresh balances
      await fetchBalances();
    } catch (e) {
      debugPrint('Error updating balance: $e');
      _errorMessage = 'Failed to update balance. Please try again.';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Get formatted total balance string
  String getFormattedTotalBalance() {
    final absBalance = _totalBalance.abs();
    final formattedBalance = '\$${absBalance.toStringAsFixed(2)}';

    if (_totalBalance > 0) {
      return '$formattedBalance you are owed';
    } else if (_totalBalance < 0) {
      return '$formattedBalance you owe';
    } else {
      return 'All settled up!';
    }
  }

  // Determine if the total balance is positive, negative, or zero
  BalanceStatus getTotalBalanceStatus() {
    if (_totalBalance > 0) {
      return BalanceStatus.positive;
    } else if (_totalBalance < 0) {
      return BalanceStatus.negative;
    } else {
      return BalanceStatus.zero;
    }
  }

  // Helper to set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

enum BalanceStatus { positive, negative, zero }
