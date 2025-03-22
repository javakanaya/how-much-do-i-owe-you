// ui/screens/settlement/settlement_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/settlement_model.dart';
import 'package:how_much_do_i_owe_you/models/transaction_model.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/providers/settlement_provider.dart';
import 'package:how_much_do_i_owe_you/services/settlement_service.dart';
import 'package:how_much_do_i_owe_you/services/transaction_service.dart';
import 'package:how_much_do_i_owe_you/services/user_service.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';

class SettlementDetailScreen extends StatefulWidget {
  final String settlementId;

  const SettlementDetailScreen({super.key, required this.settlementId});

  @override
  State<SettlementDetailScreen> createState() => _SettlementDetailScreenState();
}

class _SettlementDetailScreenState extends State<SettlementDetailScreen> {
  final SettlementService _settlementService = SettlementService();
  final TransactionService _transactionService = TransactionService();
  final UserService _userService = UserService();

  bool _isLoading = true;
  bool _isCancelling = false;
  String? _errorMessage;
  SettlementModel? _settlement;
  UserModel? _payer;
  UserModel? _receiver;
  List<TransactionModel> _transactions = [];

  // Currency formatter for Rupiah
  final rupiahFormat = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: AppConstants.currencyDecimalDigits,
  );

  @override
  void initState() {
    super.initState();
    _loadSettlementDetails();
  }

  Future<void> _loadSettlementDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load settlement
      final settlement = await _settlementService.getSettlementById(
        widget.settlementId,
      );

      if (settlement == null) {
        throw Exception('Settlement not found');
      }

      // Load users
      final payer = await _userService.getUserById(settlement.payerId);
      final receiver = await _userService.getUserById(settlement.receiverId);

      // Load transactions
      final List<TransactionModel> transactions = [];
      for (var transactionId in settlement.transactionIds) {
        final transaction = await _transactionService.getTransactionById(
          transactionId,
        );
        if (transaction != null) {
          transactions.add(transaction);
        }
      }

      setState(() {
        _settlement = settlement;
        _payer = payer;
        _receiver = receiver;
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading settlement details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelSettlement() async {
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).user?.uid;

    if (currentUserId == null) return;

    // Only the payer or receiver can cancel a settlement
    if (_settlement?.payerId != currentUserId &&
        _settlement?.receiverId != currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You don\'t have permission to cancel this settlement'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Check if settlement is less than 24 hours old
    final now = DateTime.now();
    final difference = now.difference(_settlement!.date);
    if (difference.inHours > 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settlements can only be cancelled within 24 hours'),
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
            title: const Text('Cancel Settlement?'),
            content: const Text(
              'This will revert the settlement and mark all transactions as unsettled. '
              'This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('KEEP SETTLEMENT'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
                child: const Text('CANCEL SETTLEMENT'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      setState(() {
        _isCancelling = true;
      });

      final settlementProvider = Provider.of<SettlementProvider>(
        context,
        listen: false,
      );

      final success = await settlementProvider.cancelSettlement(
        widget.settlementId,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settlement cancelled successfully'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );

        // Reload settlement details
        _loadSettlementDetails();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              settlementProvider.errorMessage ?? 'Failed to cancel settlement',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isCancelling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<AuthProvider>(context).user?.uid;
    final isUserPayer = _settlement?.payerId == currentUserId;
    final isUserReceiver = _settlement?.receiverId == currentUserId;

    // Calculate time difference outside the build method for use in conditions
    final DateTime now = DateTime.now();
    final bool isRecentSettlement =
        _settlement != null && now.difference(_settlement!.date).inHours <= 24;

    return Scaffold(
      appBar: AppBar(title: const Text('Settlement Details')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorState()
              : _settlement == null
              ? const Center(child: Text('Settlement not found'))
              : SafeArea(
                child: Column(
                  children: [
                    // Details content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSettlementHeader(),
                            const SizedBox(height: 24),
                            _buildUserDetails(isUserPayer),
                            const SizedBox(height: 24),
                            _buildTransactionsList(),
                          ],
                        ),
                      ),
                    ),

                    // Cancel button (only for recent settlements)
                    if (_settlement != null &&
                        _settlement!.status != 'canceled' &&
                        (isUserPayer || isUserReceiver) &&
                        isRecentSettlement)
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
                          text: 'Cancel Settlement',
                          icon: Icons.cancel,
                          onPressed: _isCancelling ? () {} : _cancelSettlement,
                          isLoading: _isCancelling,
                        ),
                      ),
                  ],
                ),
              ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              style: const TextStyle(color: AppTheme.errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Retry',
              icon: Icons.refresh,
              onPressed: _loadSettlementDetails,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        Row(
          children: [
            _buildStatusBadge(_settlement!.status),
            const Spacer(),
            Text(
              DateFormat(
                AppConstants.dateTimeFormatDisplay,
              ).format(_settlement!.date),
              style: const TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Settlement ID
        const Text(
          'Settlement ID',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
        ),

        const SizedBox(height: 4),

        Text(
          _settlement!.settlementId,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // Total amount
        const Text(
          'Total Amount',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
        ),

        const SizedBox(height: 4),

        Text(
          rupiahFormat.format(_settlement!.amount),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildUserDetails(bool isUserPayer) {
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
            const Text(
              'Settlement Between',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Payer details
            Row(
              children: [
                // Payer avatar
                CircleAvatar(
                  backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                  radius: 20,
                  child:
                      _payer?.photoURL != null
                          ? CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(_payer!.photoURL!),
                          )
                          : const Icon(
                            Icons.arrow_upward,
                            color: AppTheme.errorColor,
                          ),
                ),

                const SizedBox(width: 12),

                // Payer info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUserPayer
                            ? 'You (Payer)'
                            : '${_payer?.displayName ?? 'Unknown'} (Payer)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (_payer?.email != null)
                        Text(
                          _payer!.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Arrow
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
              child: Icon(Icons.arrow_downward, color: AppTheme.primaryColor),
            ),

            // Receiver details
            Row(
              children: [
                // Receiver avatar
                CircleAvatar(
                  backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                  radius: 20,
                  child:
                      _receiver?.photoURL != null
                          ? CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(_receiver!.photoURL!),
                          )
                          : const Icon(
                            Icons.arrow_downward,
                            color: AppTheme.secondaryColor,
                          ),
                ),

                const SizedBox(width: 12),

                // Receiver info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        !isUserPayer
                            ? 'You (Receiver)'
                            : '${_receiver?.displayName ?? 'Unknown'} (Receiver)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (_receiver?.email != null)
                        Text(
                          _receiver!.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transactions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child:
              _transactions.isEmpty
                  ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No transactions found',
                        style: TextStyle(color: AppTheme.textSecondaryColor),
                      ),
                    ),
                  )
                  : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _transactions.length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      return ListTile(
                        title: Text(
                          transaction.description,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          DateFormat(
                            AppConstants.dateFormatDisplay,
                          ).format(transaction.date),
                        ),
                        trailing: Text(
                          rupiahFormat.format(transaction.amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        onTap: () {
                          // Navigate to transaction detail
                          Navigator.pushNamed(
                            context,
                            AppConstants.transactionDetailRoute,
                            arguments: transaction.transactionId,
                          );
                        },
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
      case 'completed':
        bgColor = AppTheme.secondaryColor.withOpacity(0.2);
        textColor = AppTheme.secondaryColor;
        label = 'Completed';
        break;
      case 'canceled':
        bgColor = AppTheme.errorColor.withOpacity(0.2);
        textColor = AppTheme.errorColor;
        label = 'Canceled';
        break;
      case 'pending':
        bgColor = Colors.amber.withOpacity(0.2);
        textColor = Colors.amber.shade900;
        label = 'Pending';
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
}
