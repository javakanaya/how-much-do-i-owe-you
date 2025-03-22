// providers/activity_provider.dart
import 'package:flutter/foundation.dart';
import 'package:how_much_do_i_owe_you/models/transaction_model.dart';
import 'package:how_much_do_i_owe_you/services/transaction_service.dart';

class ActivityProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  // Current user ID
  String? _currentUserId;

  // List of all transactions
  List<TransactionModel> _allTransactions = [];

  // List of filtered transactions
  List<TransactionModel> _filteredTransactions = [];

  // Current filter
  String _currentFilter = 'all'; // all, you_paid, you_owe, settled

  // Loading state
  bool _isLoading = false;

  // Error state
  String? _errorMessage;

  // Getters
  List<TransactionModel> get transactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;

  // Initialize with user ID
  void initialize(String userId) {
    _currentUserId = userId;
    fetchTransactions();
  }

  // Fetch transactions
  Future<void> fetchTransactions() async {
    if (_currentUserId == null) return;

    try {
      _setLoading(true);

      // Get transactions from service
      final transactions = await _transactionService.getTransactionsForUser(
        _currentUserId!,
      );

      // Sort by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      // Update the lists
      _allTransactions = transactions;

      // Apply current filter
      _applyFilter();

      _errorMessage = null;
    } catch (e) {
      debugPrint('Error in fetchTransactions: $e');
      _errorMessage = 'Failed to load transactions. Please try again.';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Filter transactions
  void filterTransactions(String filter) {
    _currentFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  // Apply the current filter
  void _applyFilter() {
    if (_currentFilter == 'all') {
      _filteredTransactions = List.from(_allTransactions);
    } else if (_currentFilter == 'you_paid') {
      _filteredTransactions =
          _allTransactions
              .where((transaction) => transaction.payerId == _currentUserId)
              .toList();
    } else if (_currentFilter == 'you_owe') {
      _filteredTransactions =
          _allTransactions
              .where(
                (transaction) =>
                    transaction.participants.contains(_currentUserId) &&
                    transaction.payerId != _currentUserId,
              )
              .toList();
    } else if (_currentFilter == 'settled') {
      _filteredTransactions =
          _allTransactions
              .where((transaction) => transaction.status == 'settled')
              .toList();
    }
  }

  // Get transaction by ID
  TransactionModel? getTransactionById(String transactionId) {
    try {
      return _allTransactions.firstWhere(
        (transaction) => transaction.transactionId == transactionId,
      );
    } catch (e) {
      return null;
    }
  }

  // Helper to set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
