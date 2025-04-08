import 'package:how_much_do_i_owe_you/models/transaction_model.dart';
import 'package:how_much_do_i_owe_you/models/transaction_participant.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/providers/transaction_provider.dart';
import 'package:how_much_do_i_owe_you/providers/user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_create_provider.g.dart';

// Models for the transaction creation process
class TransactionParticipantEntry {
  final UserModel user;
  final double amount;
  final bool isPayer;

  TransactionParticipantEntry({
    required this.user,
    this.amount = 0,
    this.isPayer = false,
  });

  TransactionParticipantEntry copyWith({UserModel? user, double? amount, bool? isPayer}) {
    return TransactionParticipantEntry(
      user: user ?? this.user,
      amount: amount ?? this.amount,
      isPayer: isPayer ?? this.isPayer,
    );
  }
}

class TransactionCreateState {
  final String description;
  final double amount;
  final List<TransactionParticipantEntry> participants;
  final bool isLoading;

  TransactionCreateState({
    this.description = '',
    this.amount = 0,
    this.participants = const [],
    this.isLoading = false,
  });

  TransactionCreateState copyWith({
    String? description,
    double? amount,
    List<TransactionParticipantEntry>? participants,
    bool? isLoading,
  }) {
    return TransactionCreateState(
      description: description ?? this.description,
      amount: amount ?? this.amount,
      participants: participants ?? this.participants,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Auto-generated provider using riverpod_annotation
@riverpod
class TransactionCreate extends _$TransactionCreate {
  @override
  TransactionCreateState build() {
    return TransactionCreateState();
  }

  // Add current user as participant
  Future<void> addCurrentUserAsParticipant() async {
    final authUser = ref.read(currentUserProvider);
    if (authUser == null) return;

    // Get full user data
    final userData = await ref.read(userRepositoryProvider).getUserById(authUser.uid);
    if (userData == null) return;

    // Add user as participant and set as payer
    final participant = TransactionParticipantEntry(user: userData, isPayer: true);

    final updatedParticipants = [...state.participants, participant];
    state = state.copyWith(participants: updatedParticipants);
  }

  // Add a participant by email (in a real app, you would search users by email)
  Future<void> addParticipantByEmail(String email, String displayName) async {
    // In a real app, you would search for the user in your database
    // Here we just create a mock user for demonstration
    final mockUser = UserModel(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );

    final participant = TransactionParticipantEntry(user: mockUser);

    // Check if user is already a participant
    if (state.participants.any((p) => p.user.id == mockUser.id)) {
      return;
    }

    final updatedParticipants = [...state.participants, participant];
    state = state.copyWith(participants: updatedParticipants);
  }

  void addParticipant(UserModel user) {
    // Check if user is already a participant
    if (state.participants.any((p) => p.user.id == user.id)) {
      return;
    }

    final participant = TransactionParticipantEntry(user: user);
    final updatedParticipants = [...state.participants, participant];
    state = state.copyWith(participants: updatedParticipants);
  }

  // Remove a participant
  void removeParticipant(String userId) {
    // Don't allow removing if only one participant left
    if (state.participants.length <= 1) return;

    final updatedParticipants =
        state.participants.where((participant) => participant.user.id != userId).toList();

    state = state.copyWith(participants: updatedParticipants);
  }

  // Set transaction amount
  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  // Set transaction description
  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  // Update participant amount
  void updateParticipantAmount(String userId, double amount) {
    final updatedParticipants =
        state.participants.map((participant) {
          if (participant.user.id == userId) {
            return participant.copyWith(amount: amount);
          }
          return participant;
        }).toList();

    state = state.copyWith(participants: updatedParticipants);
  }

  // Toggle participant as payer
  void toggleParticipantAsPayer(String userId, bool isPayer) {
    final updatedParticipants =
        state.participants.map((participant) {
          // If we're setting this participant as a payer, unset all others
          if (isPayer) {
            if (participant.user.id == userId) {
              return participant.copyWith(isPayer: true);
            } else {
              return participant.copyWith(isPayer: false);
            }
          } else {
            // If turning off this payer, find another participant to set as payer
            if (participant.user.id == userId) {
              return participant.copyWith(isPayer: false);
            }
          }
          return participant;
        }).toList();

    // Make sure there's always a payer
    final hasPayer = updatedParticipants.any((p) => p.isPayer);
    if (!hasPayer && updatedParticipants.isNotEmpty) {
      updatedParticipants[0] = updatedParticipants[0].copyWith(isPayer: true);
    }

    state = state.copyWith(participants: updatedParticipants);
  }

  // Get remaining amount (total - sum of participant amounts)
  double getRemainingAmount() {
    final totalAssigned = state.participants.fold<double>(
      0.0,
      (sum, participant) => sum + participant.amount,
    );
    return state.amount - totalAssigned;
  }

  // Split amount equally among participants
  void splitEqually() {
    if (state.participants.isEmpty || state.amount <= 0) return;

    final equalAmount = state.amount / state.participants.length;
    final roundedAmount = (equalAmount * 100).round() / 100; // Round to 2 decimal places

    final updatedParticipants =
        state.participants.map((participant) {
          return participant.copyWith(amount: roundedAmount);
        }).toList();

    state = state.copyWith(participants: updatedParticipants);
  }

  // Create the transaction
  Future<bool> createTransaction() async {
    if (state.description.isEmpty || state.amount <= 0) {
      return false;
    }

    // Make sure all amounts are assigned
    final remaining = getRemainingAmount();
    if (remaining.abs() > 0.01) {
      return false;
    }

    // Make sure there's a payer
    final payer = state.participants.firstWhere(
      (p) => p.isPayer,
      orElse:
          () =>
              state.participants.isEmpty
                  ? throw Exception('No participants')
                  : state.participants.first,
    );

    state = state.copyWith(isLoading: true);

    try {
      // Convert participants to the model format
      final transactionParticipants =
          state.participants.map((p) {
            return TransactionParticipant(
              userId: p.user.id,
              owedAmount: p.amount,
              isPayer: p.isPayer,
              isSettled: p.isPayer, // The payer has already paid their part
            );
          }).toList();

      // Create the transaction model
      final transaction = TransactionModel(
        id: '', // ID will be set by Firestore
        description: state.description,
        amount: state.amount,
        date: DateTime.now(),
        payerId: payer.user.id,
        status: 'active',
        participants: transactionParticipants,
      );

      // Save to repository
      final repo = ref.read(transactionRepositoryProvider);
      await repo.createTransaction(transaction);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw Exception('Failed to create transaction: $e');
    }
  }
}
