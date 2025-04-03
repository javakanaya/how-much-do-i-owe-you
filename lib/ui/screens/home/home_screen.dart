import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/providers/user_provider.dart';
import 'package:how_much_do_i_owe_you/ui/screens/home/widgets/balance_summary.dart';
import 'package:how_much_do_i_owe_you/ui/screens/home/widgets/greeting.dart';
import 'package:how_much_do_i_owe_you/ui/screens/home/widgets/today_date.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);

    return SafeArea(
      child: userDataAsync.when(
        data: (userData) {
          if (userData == null) {
            return const Center(child: Text('No user data available.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User greeting
                Greeting(user: userData),

                const SizedBox(height: 20),

                TodayDate(),

                const SizedBox(height: 24),

                BalanceSummary(),

                const SizedBox(height: 30),

                // Add new transaction button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to add transaction screen
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => AddTransactionScreen()));
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Transaction'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading user data: $error')),
      ),
    );
  }
}
