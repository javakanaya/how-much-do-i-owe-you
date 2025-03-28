import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(AppConstants.appName),
          ],
        ),
      ),
    );
  }
}
