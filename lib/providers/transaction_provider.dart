// providers/transaction_provider.dart
import 'package:flutter/foundation.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/models/participant_model.dart';
import 'package:how_much_do_i_owe_you/services/transaction_service.dart';

// Helper class for tracking participant data during transaction creation
class TransactionParticipant {
  final UserModel user;
  final double? amount;
  final bool isPayer;

  TransactionParticipant({
    required this.user,
    this.amount,
    required this.isPayer,
  });

  TransactionParticipant copyWith({
    UserModel? user,
    double? amount,
    bool? isPayer,
  }) {
    return TransactionParticipant(
      user: user ?? this.user,
      amount: amount,
      isPayer: isPayer ?? this.isPayer,
    );
  }
}

class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  // Transaction data
  String _description = '';
  double _amount = 0.0;
  List<TransactionParticipant> _participants = [];

  // Loading states
  bool _isLoading = false;
  String? _errorMessage;
  bool _transactionCreated = false;

  // Getters
  String get description => _description;
  double get amount => _amount;
  List<TransactionParticipant> get participants =>
      List.unmodifiable(_participants);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get transactionCreated => _transactionCreated;

  // Reset the state for a new transaction
  void reset() {
    _description = '';
    _amount = 0.0;
    _participants = [];
    _errorMessage = null;
    _transactionCreated = false;
    notifyListeners();
  }

  // Set description
  void setDescription(String description) {
    _description = description;
    notifyListeners();
  }

  // Set amount
  void setAmount(double amount) {
    _amount = amount;
    notifyListeners();
  }

  // Initialize with current user as payer
  void initializeWithUser(UserModel currentUser) {
    if (_participants.isEmpty) {
      _participants.add(
        TransactionParticipant(user: currentUser, amount: 0.0, isPayer: true),
      );
      notifyListeners();
    }
  }

  // Add or update participants based on selection
  void updateParticipants(List<UserModel> selectedUsers) {
    // Create a map of current participants for easy lookup
    final currentParticipants = Map.fromEntries(
      _participants.map((p) => MapEntry(p.user.id, p)),
    );

    // Create a set of selected user IDs
    selectedUsers.map((user) => user.id).toSet();

    // Start with a new list but keep the payer
    final payer = _participants.firstWhere(
      (p) => p.isPayer,
      orElse: () {
        // Return the first participant if there's any, otherwise null
        return _participants.first;
      },
    );

    final newParticipants = <TransactionParticipant>[];

    // Add the payer first if it exists
    newParticipants.add(payer);

    // Add/update participants based on selection
    for (final user in selectedUsers) {
      // Skip the payer (already added)
      if (user.id == payer.user.id) {
        continue;
      }

      // If user was already a participant, preserve their amount
      if (currentParticipants.containsKey(user.id)) {
        newParticipants.add(currentParticipants[user.id]!);
      } else {
        // Add as new participant
        newParticipants.add(
          TransactionParticipant(user: user, amount: 0.0, isPayer: false),
        );
      }
    }

    _participants = newParticipants;
    notifyListeners();
  }

  // Update a participant's amount
  void updateParticipantAmount(String userId, double? amount) {
    final index = _participants.indexWhere((p) => p.user.id == userId);

    if (index != -1) {
      _participants[index] = _participants[index].copyWith(amount: amount);
      notifyListeners();
    }
  }

  // Remove a participant
  void removeParticipant(String userId) {
    // Don't allow removing the payer
    if (_participants.any((p) => p.user.id == userId && p.isPayer)) {
      return;
    }

    _participants.removeWhere((p) => p.user.id == userId);
    notifyListeners();
  }

  // Calculate remaining amount to distribute
  double getRemainingAmount() {
    final allocatedAmount = _participants.fold<double>(
      0.0,
      (sum, participant) => sum + (participant.amount ?? 0.0),
    );

    return _amount - allocatedAmount;
  }

  // Split amount equally among participants
  void splitEqually() {
    if (_amount <= 0 || _participants.isEmpty) return;

    final amountPerPerson = _amount / _participants.length;

    for (var i = 0; i < _participants.length; i++) {
      _participants[i] = _participants[i].copyWith(amount: amountPerPerson);
    }

    notifyListeners();
  }

  // Create transaction
  Future<bool> createTransaction() async {
    // Validate inputs
    if (_description.isEmpty) {
      _errorMessage = 'Please enter a description';
      notifyListeners();
      return false;
    }

    if (_amount <= 0) {
      _errorMessage = 'Please enter a valid amount';
      notifyListeners();
      return false;
    }

    if (_participants.length < 2) {
      _errorMessage =
          'Add at least one other person to share this expense with';
      notifyListeners();
      return false;
    }

    // Validate total amount matches allocated amounts
    final allocatedAmount = _participants.fold<double>(
      0.0,
      (sum, participant) => sum + (participant.amount ?? 0.0),
    );

    final difference = (_amount - allocatedAmount).abs();
    if (difference > 0.01) {
      _errorMessage =
          'The allocated amounts (${allocatedAmount.toStringAsFixed(2)}) '
          'don\'t match the total amount (${_amount.toStringAsFixed(2)})';
      notifyListeners();
      return false;
    }

    // Find payer
    final payerEntry = _participants.firstWhere((p) => p.isPayer);

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _transactionService.createTransaction(
        description: _description.trim(),
        amount: _amount,
        payerId: payerEntry.user.id,
        participants:
            _participants
                .map(
                  (p) => ParticipantModel(
                    userId: p.user.id,
                    transactionId: '', // Will be set by the transaction service
                    owedAmount: p.amount ?? 0.0,
                    isPayer: p.isPayer,
                  ),
                )
                .toList(),
      );

      _transactionCreated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error creating transaction: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
