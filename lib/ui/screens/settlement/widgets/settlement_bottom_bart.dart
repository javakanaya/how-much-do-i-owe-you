// ui/screens/settlement/widgets/settlement_bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';

class SettlementBottomBar extends StatelessWidget {
  final Set<String> selectedTransactionIds;
  final bool isCreatingSettlement;
  final VoidCallback onCreateSettlement;

  const SettlementBottomBar({
    super.key,
    required this.selectedTransactionIds,
    required this.isCreatingSettlement,
    required this.onCreateSettlement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 48, left: 16, right: 16),
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
            selectedTransactionIds.isEmpty || isCreatingSettlement
                ? () {}
                : onCreateSettlement,
        isLoading: isCreatingSettlement,
      ),
    );
  }
}
