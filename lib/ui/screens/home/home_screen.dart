// ui/screens/dashboard/home_screen.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/ui/screens/home/widgets/balance_summary_widget.dart';
import 'package:how_much_do_i_owe_you/ui/screens/home/widgets/greeting_widget.dart';
import 'package:how_much_do_i_owe_you/ui/screens/home/widgets/person_balance_card.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/settlement_history_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/providers/balance_provider.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize balance provider with current user ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userModel?.userId != null) {
        Provider.of<BalanceProvider>(
          context,
          listen: false,
        ).initialize(authProvider.userModel!.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final balanceProvider = Provider.of<BalanceProvider>(context);
    final user = authProvider.userModel;

    // Get current date
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM');
    final formattedDate = dateFormat.format(now);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and Points section
              GreetingWidget(user: user),

              const SizedBox(height: 20),

              // Date Section
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),

              const SizedBox(height: 10),

              // Balance Summary
              BalanceSummaryWidget(balanceProvider: balanceProvider),

              const SizedBox(height: 24),

              // People you owe / who owe you
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Balances',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to full list of balances
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),

              // List of people with balances
              balanceProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : balanceProvider.personBalances.isEmpty
                  ? _buildEmptyBalances()
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        balanceProvider.personBalances.length > 3
                            ? 3
                            : balanceProvider.personBalances.length,
                    itemBuilder: (context, index) {
                      return PersonBalanceCard(
                        balance: balanceProvider.personBalances[index],
                      );
                    },
                  ),

              const SizedBox(height: 16),

              // Settlement History Link
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettlementHistoryScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.history,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Settlement History',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add transaction screen
          Navigator.pushNamed(context, AppConstants.newTransactionRoute).then((
            value,
          ) {
            // Refresh data when returning from add transaction screen
            if (value == true) {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              if (authProvider.userModel?.userId != null) {
                Provider.of<BalanceProvider>(
                  context,
                  listen: false,
                ).fetchBalances();
              }
            }
          });
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyBalances() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No balances yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a transaction to start tracking balances',
              style: TextStyle(color: AppTheme.textSecondaryColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
