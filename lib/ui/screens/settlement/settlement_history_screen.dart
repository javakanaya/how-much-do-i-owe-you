// ui/screens/settlement/settlement_history_screen.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/settlement_detail_scren.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/settlement_model.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/providers/settlement_provider.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';

class SettlementHistoryScreen extends StatefulWidget {
  const SettlementHistoryScreen({super.key});

  @override
  State<SettlementHistoryScreen> createState() =>
      _SettlementHistoryScreenState();
}

class _SettlementHistoryScreenState extends State<SettlementHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadSettlements();
  }

  Future<void> _loadSettlements() async {
    final settlementsProvider = Provider.of<SettlementProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.userModel?.userId != null) {
      settlementsProvider.initialize(authProvider.userModel!.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settlementsProvider = Provider.of<SettlementProvider>(context);
    final currentUserId = Provider.of<AuthProvider>(context).user?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Settlement History')),
      body:
          settlementsProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : settlementsProvider.errorMessage != null
              ? _buildErrorState(settlementsProvider)
              : settlementsProvider.settlements.isEmpty
              ? _buildEmptyState()
              : _buildSettlementsList(
                settlementsProvider.settlements,
                settlementsProvider.userMap,
                currentUserId,
              ),
    );
  }

  Widget _buildErrorState(SettlementProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              provider.errorMessage ?? 'An error occurred',
              style: const TextStyle(color: AppTheme.errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Retry',
              icon: Icons.refresh,
              onPressed: _loadSettlements,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Settlements Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your settlement history will appear here',
              style: TextStyle(color: AppTheme.textSecondaryColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementsList(
    List<SettlementModel> settlements,
    Map<String, dynamic> userMap,
    String? currentUserId,
  ) {
    // Group settlements by date
    final Map<String, List<SettlementModel>> groupedSettlements = {};

    for (var settlement in settlements) {
      final dateStr = DateFormat('yyyy-MM-dd').format(settlement.date);
      if (!groupedSettlements.containsKey(dateStr)) {
        groupedSettlements[dateStr] = [];
      }
      groupedSettlements[dateStr]!.add(settlement);
    }

    // Sort dates in descending order
    final sortedDates =
        groupedSettlements.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final settlementsForDate = groupedSettlements[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                DateFormat.yMMMMd().format(DateTime.parse(date)),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),

            // Settlements for this date
            ...settlementsForDate.map((settlement) {
              final isUserPayer = settlement.payerId == currentUserId;
              final otherUserId =
                  isUserPayer ? settlement.receiverId : settlement.payerId;
              final otherUser = userMap[otherUserId];
              final otherUserName = otherUser?.displayName ?? 'Unknown User';

              return _buildSettlementCard(
                settlement,
                isUserPayer,
                otherUserName,
                otherUser?.photoURL,
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildSettlementCard(
    SettlementModel settlement,
    bool isUserPayer,
    String otherUserName,
    String? otherUserPhotoURL,
  ) {
    // Currency formatter
    final rupiahFormat = NumberFormat.currency(
      locale: AppConstants.currencyLocale,
      symbol: AppConstants.currencySymbol,
      decimalDigits: AppConstants.currencyDecimalDigits,
    );

    // Set colors based on whether user paid or received
    final Color iconColor =
        isUserPayer ? AppTheme.errorColor : AppTheme.secondaryColor;
    final Color bgColor = iconColor.withOpacity(0.1);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => SettlementDetailScreen(
                    settlementId: settlement.settlementId,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // User avatar or icon
              CircleAvatar(
                backgroundColor: bgColor,
                radius: 24,
                child:
                    otherUserPhotoURL != null
                        ? CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(otherUserPhotoURL),
                        )
                        : Icon(
                          isUserPayer
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: iconColor,
                        ),
              ),

              const SizedBox(width: 16),

              // Settlement details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUserPayer
                          ? 'You paid $otherUserName'
                          : '$otherUserName paid you',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateFormat.jm().format(settlement.date),
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (settlement.status == 'canceled')
                      const Text(
                        'Canceled',
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

              // Amount
              Text(
                rupiahFormat.format(settlement.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
