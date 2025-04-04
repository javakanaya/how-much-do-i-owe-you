import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/providers/user_provider.dart';

class PayerNameWidget extends ConsumerWidget {
  final String payerId;
  const PayerNameWidget({super.key, required this.payerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final payerDataAsync = ref.watch(userDataProvider(payerId));
    final payerDataAsync = ref.watch(dummyUserDataProvider(payerId));

    return payerDataAsync.when(
      data:
          (payerData) => Text(
            'Paid by ${payerData?.displayName ?? 'Unknown'}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
          ),
      loading:
          () => const Text(
            'Loading payer...',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
          ),
      error:
          (_, __) => const Text(
            'Unknown payer',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
          ),
    );
  }
}
