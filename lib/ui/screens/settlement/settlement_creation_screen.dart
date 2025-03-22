// ui/screens/settlement/settlement_creation_screen.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/widgets/settlement_bottom_bart.dart';
import 'package:provider/provider.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/providers/settlement_provider.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/widgets/settlement_header.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/widgets/settlement_empty_state.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/widgets/settlement_transaction_list.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
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
        bottom: false,
        child: Column(
          children: [
            // Header with total amount
            SettlementHeader(
              userName: widget.userName,
              totalAmount: settlementProvider.totalAmount,
            ),

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
                      ? const SettlementEmptyState()
                      : SettlementTransactionList(
                        transactions: transactions,
                        selectedTransactionIds: _selectedTransactionIds,
                        allTransactionsSelected: _allTransactionsSelected,
                        onToggleTransaction: _toggleTransactionSelection,
                        onToggleAllTransactions: _toggleAllTransactions,
                      ),
            ),

            // Bottom action bar
            SettlementBottomBar(
              selectedTransactionIds: _selectedTransactionIds,
              isCreatingSettlement: settlementProvider.isCreatingSettlement,
              onCreateSettlement: _createSettlement,
            ),
          ],
        ),
      ),
    );
  }
}
