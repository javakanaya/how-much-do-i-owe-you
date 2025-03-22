// ui/screens/activity/activity_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/transaction_model.dart';
import 'package:how_much_do_i_owe_you/providers/activity_provider.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/ui/screens/activity/widgets/transaction_card.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  // Currency formatter for Rupiah
  final rupiahFormat = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: AppConstants.currencyDecimalDigits,
  );

  @override
  void initState() {
    super.initState();
    // Initialize activity provider with current user ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userModel?.userId != null) {
        Provider.of<ActivityProvider>(
          context,
          listen: false,
        ).initialize(authProvider.userModel!.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    final transactions = activityProvider.transactions;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'all') {
                activityProvider.filterTransactions('all');
              } else if (value == 'you_paid') {
                activityProvider.filterTransactions('you_paid');
              } else if (value == 'you_owe') {
                activityProvider.filterTransactions('you_owe');
              } else if (value == 'settled') {
                activityProvider.filterTransactions('settled');
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'all',
                    child: Text('All Transactions'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'you_paid',
                    child: Text('You Paid'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'you_owe',
                    child: Text('You Owe'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'settled',
                    child: Text('Settled'),
                  ),
                ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: SafeArea(
        child:
            activityProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : activityProvider.errorMessage != null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        activityProvider.errorMessage!,
                        style: const TextStyle(color: AppTheme.errorColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        text: 'Retry',
                        icon: Icons.refresh,
                        onPressed: () => activityProvider.fetchTransactions(),
                      ),
                    ],
                  ),
                )
                : transactions.isEmpty
                ? _buildEmptyState()
                : _buildTransactionList(transactions),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Transactions Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your transaction history will appear here',
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Add First Transaction',
              icon: Icons.add,
              onPressed: () {
                Navigator.pushNamed(context, AppConstants.newTransactionRoute);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<TransactionModel> transactions) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.userModel?.userId;

    return RefreshIndicator(
      onRefresh: () => activityProvider.fetchTransactions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];

          return TransactionCard(
            transaction: transaction,
            currentUserId: currentUserId!,
            onTap: () {
              // Navigate to transaction details
              Navigator.pushNamed(
                context,
                AppConstants.transactionDetailRoute,
                arguments: transaction.transactionId,
              );
            },
          );
        },
      ),
    );
  }
}
