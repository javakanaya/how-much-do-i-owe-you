// models/person_balance.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/models/balance_model.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';

class PersonBalance {
  final String userId;
  final String name;
  final String initials;
  final Color avatarColor;
  final Color textColor;
  final int transactionCount;
  final double balance;
  final bool isPositive;

  PersonBalance({
    required this.userId,
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.textColor,
    required this.transactionCount,
    required this.balance,
    required this.isPositive,
  });

  // Factory method to create PersonBalance from BalanceModel and UserModel
  factory PersonBalance.fromModels({
    required BalanceModel balanceModel,
    required UserModel userModel,
    required String currentUserId,
    required int transactionCount,
  }) {
    // Get the other user's ID
    final String otherUserId = balanceModel.getOtherUserId(currentUserId);

    // Make sure we're getting the correct person
    if (userModel.userId != otherUserId) {
      throw ArgumentError(
        'User model does not match the expected user ID in the balance model',
      );
    }

    // Calculate balance from current user's perspective
    final double balanceAmount = balanceModel.getAmountForUser(currentUserId);

    // Determine if balance is positive (they owe us) or negative (we owe them)
    final bool isPositive = balanceAmount < 0; // If negative, they owe us

    return PersonBalance(
      userId: userModel.userId,
      name: userModel.displayName,
      initials: _getInitials(userModel.displayName),
      avatarColor: _getAvatarColor(userModel.displayName),
      textColor: _getTextColor(userModel.displayName, isPositive),
      transactionCount: transactionCount,
      balance: balanceAmount.abs(), // Store as absolute value for display
      isPositive: isPositive,
    );
  }

  // Helper method to get initials from name
  static String _getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.split(' ');
    if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }

  // Helper method to get avatar color based on name
  static Color _getAvatarColor(String name) {
    if (name.isEmpty) return const Color(0xFFE6F0FF);

    // Simple hash function for name
    final hash = name.codeUnits.fold(0, (prev, element) => prev + element);

    // List of color options (matching your SVG design)
    final colors = [
      const Color(0xFFF0F7FF), // Light blue
      const Color(0xFFFFF0F0), // Light red
      const Color(0xFFF0FFF0), // Light green
      const Color(0xFFFFF0E0), // Light orange
      const Color(0xFFF5F0FF), // Light purple
    ];

    return colors[hash % colors.length];
  }

  // Helper method to get text color based on name and balance status
  static Color _getTextColor(String name, bool isPositive) {
    if (isPositive) {
      return AppTheme.primaryColor; // Blue for positive balance (they owe us)
    } else {
      return const Color(0xFFFF4757); // Red for negative balance (we owe them)
    }
  }

  // Method to create a dummy list of PersonBalance objects for UI testing
  static List<PersonBalance> getDummyData() {
    return [
      PersonBalance(
        userId: '1',
        name: 'Michael',
        initials: 'M',
        avatarColor: const Color(0xFFF0F7FF),
        textColor: AppTheme.primaryColor,
        transactionCount: 3,
        balance: 42.50,
        isPositive: true,
      ),
      PersonBalance(
        userId: '2',
        name: 'Sarah',
        initials: 'S',
        avatarColor: const Color(0xFFFFF0F0),
        textColor: const Color(0xFFFF4757),
        transactionCount: 1,
        balance: 15.00,
        isPositive: false,
      ),
    ];
  }
}
