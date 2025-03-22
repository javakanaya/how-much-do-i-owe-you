// ui/screens/transaction/transaction_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/transaction_model.dart';
import 'package:how_much_do_i_owe_you/models/participant_model.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/services/transaction_service.dart';
import 'package:how_much_do_i_owe_you/services/user_service.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final TransactionService _transactionService = TransactionService();
  final UserService _userService = UserService();

  bool _isLoading = true;
  bool _isSettling = false;
  String? _errorMessage;
  TransactionModel? _transaction;
  UserModel? _payer;
  List<ParticipantModel> _participants = [];
  Map<String, UserModel> _userMap = {};

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

  Future<void> _loadTransactionDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load transaction
      final transaction = await _transactionService.getTransactionById(
        widget.transactionId,
      );

      if (transaction == null) {
        throw Exception('Transaction not found');
      }

      // Load participants
      final participants = await _transactionService
          .getParticipantsForTransaction(widget.transactionId);

      // Create a map to store user models
      final Map<String, UserModel> userMap = {};

      // Load payer
      final payer = await _userService.getUserById(transaction.payerId);
      if (payer != null) {
        userMap[payer.userId] = payer;
      }

      // Load all participant user models
      for (final participant in participants) {
        if (!userMap.containsKey(participant.userId)) {
          final user = await _userService.getUserById(participant.userId);
          if (user != null) {
            userMap[user.userId] = user;
          }
        }
      }

      setState(() {
        _transaction = transaction;
        _payer = payer;
        _participants = participants;
        _userMap = userMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading transaction details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _settleTransaction() async {
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).user?.uid;
    if (currentUserId == null) return;

    try {
      setState(() {
        _isSettling = true;
      });

      // Find current user's participation
      final userParticipation = _participants.firstWhere(
        (p) => p.userId == currentUserId,
        orElse:
            () =>
                throw Exception(
                  'You are not a participant in this transaction',
                ),
      );

      if (userParticipation.isPayer) {
        // The payer can't settle for themselves
        throw Exception('As the payer, you can\'t settle this transaction');
      }

      if (userParticipation.isSettled) {
        // Already settled
        throw Exception('You have already settled this transaction');
      }

      // Mark the participant as settled
      await _transactionService.markParticipantSettled(
        widget.transactionId,
        currentUserId,
      );

      // Reload transaction details
      await _loadTransactionDetails();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment marked as settled!'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isSettling = false;
      });
    }
  }

  Future<void> _deleteTransaction() async {
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).user?.uid;
    if (currentUserId == null) return;

    // Only the payer can delete the transaction
    if (_transaction?.payerId != currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only the person who paid can delete this transaction'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Transaction?'),
            content: const Text(
              'This will delete the transaction and remove it from everyone\'s balance. This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
                child: const Text('DELETE'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Delete the transaction
      await _transactionService.deleteTransaction(widget.transactionId);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction deleted successfully'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );

      // Navigate back
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting transaction: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<AuthProvider>(context).user?.uid;
    final isCurrentUserPayer = _transaction?.payerId == currentUserId;

    // Find current user's participation
    ParticipantModel? currentUserParticipation;
    bool canSettle = false;

    if (!_isLoading && currentUserId != null) {
      try {
        currentUserParticipation = _participants.firstWhere(
          (p) => p.userId == currentUserId,
        );

        // Can settle if user is not the payer and hasn't settled yet
        canSettle =
            !currentUserParticipation.isPayer &&
            !currentUserParticipation.isSettled &&
            _transaction?.status == 'active';
      } catch (e) {
        // User not found in participants
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          if (!_isLoading && isCurrentUserPayer)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTransaction,
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppTheme.errorColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'Retry',
                      icon: Icons.refresh,
                      onPressed: _loadTransactionDetails,
                    ),
                  ],
                ),
              )
              : _transaction == null
              ? const Center(child: Text('Transaction not found'))
              : SafeArea(
                child: Column(
                  children: [
                    // Transaction details
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTransactionHeader(),
                            const SizedBox(height: 24),
                            _buildTransactionDetails(),
                            const SizedBox(height: 24),
                            _buildParticipantsList(),
                          ],
                        ),
                      ),
                    ),

                    // Settle button for non-payers who haven't settled
                    if (canSettle)
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                        child: PrimaryButton(
                          text: 'Mark as Settled',
                          icon: Icons.check_circle,
                          onPressed: _isSettling ? () {} : _settleTransaction,
                          isLoading: _isSettling,
                        ),
                      ),
                  ],
                ),
              ),
    );
  }

  Widget _buildTransactionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status indicator
        Row(
          children: [
            _buildStatusBadge(_transaction!.status),
            const Spacer(),
            Text(
              DateFormat(
                AppConstants.dateFormatDisplay,
              ).format(_transaction!.date),
              style: const TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Transaction description
        Text(
          _transaction!.description,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        // Total amount
        Text(
          rupiahFormat.format(_transaction!.amount),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionDetails() {
    final currentUserId = Provider.of<AuthProvider>(context).user?.uid;
    final isCurrentUserPayer = _transaction?.payerId == currentUserId;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payer information
            Row(
              children: [
                // Payer avatar
                if (_payer != null) ...[
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    radius: 20,
                    child:
                        _payer!.photoURL != null
                            ? CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(_payer!.photoURL!),
                            )
                            : Text(
                              _getInitials(_payer!.displayName),
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Payer name and role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCurrentUserPayer
                            ? 'You paid'
                            : _payer != null
                            ? '${_payer!.displayName} paid'
                            : 'Someone paid',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'Total amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Text(
                  rupiahFormat.format(_transaction!.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            // Current user's part
            if (currentUserId != null) ...[
              _buildUserPart(currentUserId),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserPart(String userId) {
    try {
      // Find the user's participation
      final userParticipation = _participants.firstWhere(
        (p) => p.userId == userId,
      );

      final isPayer = userParticipation.isPayer;
      final isSettled = userParticipation.isSettled;
      final owedAmount = userParticipation.owedAmount;

      if (isPayer) {
        // Calculate the total amount owed to the payer
        final totalOwedByOthers = _participants
            .where((p) => !p.isPayer)
            .fold<double>(0, (sum, p) => sum + p.owedAmount);

        return Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE3F2FD),
              radius: 20,
              child: Icon(
                Icons.account_balance_wallet,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'You are owed',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${_getSettledCount()} of ${_participants.length - 1} people have settled',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              rupiahFormat.format(totalOwedByOthers),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        );
      } else {
        // User owes money
        return Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  isSettled ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              radius: 20,
              child: Icon(
                isSettled ? Icons.check_circle : Icons.account_balance_wallet,
                color:
                    isSettled ? AppTheme.secondaryColor : AppTheme.errorColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSettled ? 'You paid' : 'You owe',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    isSettled
                        ? 'Settled on ${_getSettlementDate(userParticipation)}'
                        : 'Your share of the expense',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              rupiahFormat.format(owedAmount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color:
                    isSettled ? AppTheme.secondaryColor : AppTheme.errorColor,
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

  Widget _buildParticipantsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Participants',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _participants.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final participant = _participants[index];
              final user = _userMap[participant.userId];

              if (user == null) return const SizedBox.shrink();

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      participant.isPayer
                          ? AppTheme.primaryColor.withOpacity(0.2)
                          : participant.isSettled
                          ? AppTheme.secondaryColor.withOpacity(0.2)
                          : AppTheme.errorColor.withOpacity(0.2),
                  child:
                      user.photoURL != null
                          ? CircleAvatar(
                            backgroundImage: NetworkImage(user.photoURL!),
                          )
                          : Text(
                            _getInitials(user.displayName),
                            style: TextStyle(
                              color:
                                  participant.isPayer
                                      ? AppTheme.primaryColor
                                      : participant.isSettled
                                      ? AppTheme.secondaryColor
                                      : AppTheme.errorColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
                title: Text(user.displayName),
                subtitle: Text(
                  participant.isPayer
                      ? 'Paid the bill'
                      : participant.isSettled
                      ? 'Settled'
                      : 'Owes',
                  style: TextStyle(
                    color:
                        participant.isPayer
                            ? AppTheme.primaryColor
                            : participant.isSettled
                            ? AppTheme.secondaryColor
                            : AppTheme.errorColor,
                  ),
                ),
                trailing:
                    participant.isPayer
                        ? const Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryColor,
                        )
                        : Text(
                          rupiahFormat.format(participant.owedAmount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                participant.isSettled
                                    ? AppTheme.secondaryColor
                                    : AppTheme.errorColor,
                          ),
                        ),
              );
            },
          ),
        ),
      ],
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
        label = status;
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

  // Helper method to get initials from name
  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length > 1 && names[1].isNotEmpty) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // Helper method to get the number of settled participants
  int _getSettledCount() {
    return _participants.where((p) => p.isSettled).length - 1; // Subtract payer
  }

  // Helper method to get formatted settlement date
  String _getSettlementDate(ParticipantModel participant) {
    if (participant.settledAt == null) return 'Unknown date';
    return DateFormat('d MMM yyyy').format(participant.settledAt!);
  }
}
