// ui/screens/settlement/settlement_creation_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/transaction_model.dart';
import 'package:how_much_do_i_owe_you/providers/settlement_provider.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';

class SettlementCreationScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const SettlementCreationScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<SettlementCreationScreen> createState() =>
      _SettlementCreationScreenState();
}

class _SettlementCreationScreenState extends State<SettlementCreationScreen> {
  bool _allTransactionsSelected = true;
  Set<String> _selectedTransactionIds = {};

  // Currency formatter for Rupiah
  final rupiahFormat = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: AppConstants.currencyDecimalDigits,
  );

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final settlementProvider = Provider.of<SettlementProvider>(
      context,
      listen: false,
    );

    await settlementProvider.prepareSettlementWithUser(widget.userId);

    // Initially select all transactions
    setState(() {
      _selectedTransactionIds =
          settlementProvider.transactionsToSettle
              .map((transaction) => transaction.transactionId)
              .toSet();
    });
  }

  void _toggleTransactionSelection(String transactionId) {
    setState(() {
      if (_selectedTransactionIds.contains(transactionId)) {
        _selectedTransactionIds.remove(transactionId);
        _allTransactionsSelected = false;
      } else {
        _selectedTransactionIds.add(transactionId);
        // Check if all transactions are selected
        final settlementProvider = Provider.of<SettlementProvider>(
          context,
          listen: false,
        );
        _allTransactionsSelected =
            _selectedTransactionIds.length ==
            settlementProvider.transactionsToSettle.length;
      }
    });
  }

  void _toggleAllTransactions() {
    final settlementProvider = Provider.of<SettlementProvider>(
      context,
      listen: false,
    );

    setState(() {
      if (_allTransactionsSelected) {
        // Deselect all
        _selectedTransactionIds = {};
      } else {
        // Select all
        _selectedTransactionIds =
            settlementProvider.transactionsToSettle
                .map((transaction) => transaction.transactionId)
                .toSet();
      }
      _allTransactionsSelected = !_allTransactionsSelected;
    });
  }

  Future<void> _createSettlement() async {
    if (_selectedTransactionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one transaction to settle'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final settlementProvider = Provider.of<SettlementProvider>(
      context,
      listen: false,
    );

    // Filter transactions to only include selected ones
    settlementProvider.transactionsToSettle.retainWhere(
      (transaction) =>
          _selectedTransactionIds.contains(transaction.transactionId),
    );

    final success = await settlementProvider.createSettlement();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settlement created successfully!'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settlementProvider = Provider.of<SettlementProvider>(context);
    final transactions = settlementProvider.transactionsToSettle;

    return Scaffold(
      appBar: AppBar(title: Text('Settle with ${widget.userName}')),
      body: SafeArea(
        child: Column(
          children: [
            // Header with total amount
            _buildHeader(settlementProvider),

            // Transactions list
            Expanded(
              child:
                  settlementProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : settlementProvider.errorMessage != null
                      ? Center(
                        child: Text(
                          settlementProvider.errorMessage!,
                          style: const TextStyle(color: AppTheme.errorColor),
                          textAlign: TextAlign.center,
                        ),
                      )
                      : transactions.isEmpty
                      ? _buildEmptyState()
                      : _buildTransactionsList(transactions),
            ),

            // Bottom action bar
            _buildBottomBar(settlementProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(SettlementProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Amount to Settle',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            rupiahFormat.format(provider.totalAmount),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select which transactions to settle with ${widget.userName}:',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'All settled up!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You don\'t have any unsettled transactions\nwith this person.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<TransactionModel> transactions) {
    return Column(
      children: [
        // "Select All" option
        ListTile(
          leading: Checkbox(
            value: _allTransactionsSelected,
            onChanged: (_) => _toggleAllTransactions(),
            activeColor: AppTheme.primaryColor,
          ),
          title: const Text(
            'Select All Transactions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: _toggleAllTransactions,
        ),
        const Divider(height: 1),

        // Transactions
        Expanded(
          child: ListView.separated(
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final isSelected = _selectedTransactionIds.contains(
                transaction.transactionId,
              );

              return CheckboxListTile(
                value: isSelected,
                onChanged:
                    (_) =>
                        _toggleTransactionSelection(transaction.transactionId),
                activeColor: AppTheme.primaryColor,
                title: Text(
                  transaction.description,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  DateFormat(
                    AppConstants.dateFormatDisplay,
                  ).format(transaction.date),
                ),
                secondary: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    rupiahFormat.format(transaction.amount),
                    style: const TextStyle(
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(SettlementProvider provider) {
    return Container(
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
        text: 'Settle Up',
        icon: Icons.check_circle,
        onPressed:
            _selectedTransactionIds.isEmpty || provider.isCreatingSettlement
                ? () {}
                : _createSettlement,
        isLoading: provider.isCreatingSettlement,
      ),
    );
  }
}
