// ui/screens/activity/widgets/transaction_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/transaction_model.dart';
import 'package:how_much_do_i_owe_you/models/participant_model.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/services/user_service.dart';
import 'package:how_much_do_i_owe_you/services/transaction_service.dart';

class TransactionCard extends StatefulWidget {
  final TransactionModel transaction;
  final String currentUserId;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  final UserService _userService = UserService();
  final TransactionService _transactionService = TransactionService();

  UserModel? _payer;
  List<ParticipantModel> _participants = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Currency formatter for Rupiah
  final rupiahFormat = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: AppConstants.currencyDecimalDigits,
  );

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
  }

  @override
  void didUpdateWidget(TransactionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transaction.transactionId !=
        widget.transaction.transactionId) {
      _loadTransactionDetails();
    }
  }

  Future<void> _loadTransactionDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load payer information
      final payer = await _userService.getUserById(widget.transaction.payerId);

      // Load participants
      final participants = await _transactionService
          .getParticipantsForTransaction(widget.transaction.transactionId);

      setState(() {
        _payer = payer;
        _participants = participants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading transaction details';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUserPayer =
        widget.transaction.payerId == widget.currentUserId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppTheme.errorColor),
                    ),
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transaction date and status
                      Row(
                        children: [
                          Text(
                            DateFormat(
                              AppConstants.dateFormatDisplay,
                            ).format(widget.transaction.date),
                            style: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          _buildStatusBadge(widget.transaction.status),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Transaction description
                      Text(
                        widget.transaction.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Transaction amount
                      Row(
                        children: [
                          // Payer info
                          if (_payer != null) ...[
                            CircleAvatar(
                              backgroundColor: AppTheme.primaryColor
                                  .withOpacity(0.2),
                              radius: 16,
                              child:
                                  _payer!.photoURL != null
                                      ? CircleAvatar(
                                        radius: 14,
                                        backgroundImage: NetworkImage(
                                          _payer!.photoURL!,
                                        ),
                                      )
                                      : Text(
                                        _getInitials(_payer!.displayName),
                                        style: const TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isCurrentUserPayer
                                    ? 'You paid'
                                    : '${_payer!.displayName} paid',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],

                          // Transaction amount
                          Text(
                            rupiahFormat.format(widget.transaction.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color:
                                  isCurrentUserPayer
                                      ? AppTheme.primaryColor
                                      : AppTheme.errorColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Your share
                      if (_participants.isNotEmpty) ...[
                        const Divider(),
                        _buildYourShare(),
                      ],
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'active':
        bgColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        label = 'Active';
        break;
      case 'settled':
        bgColor = AppTheme.secondaryColor.withOpacity(0.2);
        textColor = AppTheme.secondaryColor;
        label = 'Settled';
        break;
      case 'canceled':
        bgColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
        label = 'Canceled';
        break;
      default:
        bgColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        label = status.capitalize();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildYourShare() {
    // Find the current user's participation
    try {
      final userParticipation = _participants.firstWhere(
        (p) => p.userId == widget.currentUserId,
      );

      final isPayer = userParticipation.isPayer;
      final isSettled = userParticipation.isSettled;
      final owedAmount = userParticipation.owedAmount;

      Color amountColor;
      String message;

      if (isPayer) {
        // Current user paid
        final totalOwedByOthers = _participants
            .where((p) => !p.isPayer)
            .fold<double>(0, (sum, p) => sum + p.owedAmount);

        amountColor = AppTheme.primaryColor;
        message = 'You are owed';

        return Row(
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 16,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
            Text(
              rupiahFormat.format(totalOwedByOthers),
              style: TextStyle(fontWeight: FontWeight.bold, color: amountColor),
            ),
          ],
        );
      } else {
        // Current user owes
        amountColor = AppTheme.errorColor;
        message = isSettled ? 'You paid' : 'You owe';

        return Row(
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 16,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
            Text(
              rupiahFormat.format(owedAmount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSettled ? AppTheme.secondaryColor : amountColor,
              ),
            ),
          ],
        );
      }
    } catch (e) {
      // User not found in participants
      return const SizedBox.shrink();
    }
  }

  // Helper method to get initials from name
  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length > 1 && names[1].isNotEmpty) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

// Extension to capitalize first letter of string
extension StringExtension on String {
  String capitalize() {
    return this.isNotEmpty
        ? '${this[0].toUpperCase()}${this.substring(1)}'
        : '';
  }
}
