// ui/screens/settlement/widgets/cancel_settlement_button.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/providers/settlement_provider.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';

class CancelSettlementButton extends StatefulWidget {
  final String settlementId;
  final VoidCallback onCancelled;

  const CancelSettlementButton({
    super.key,
    required this.settlementId,
    required this.onCancelled,
  });

  @override
  State<CancelSettlementButton> createState() => _CancelSettlementButtonState();
}

class _CancelSettlementButtonState extends State<CancelSettlementButton> {
  bool _isCancelling = false;

  Future<void> _cancelSettlement() async {
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

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settlement cancelled successfully'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );

        // Reload settlement details
        widget.onCancelled();
      } else {
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
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 16,
        right: 16,
        bottom: 48,
      ),
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
    );
  }
}
