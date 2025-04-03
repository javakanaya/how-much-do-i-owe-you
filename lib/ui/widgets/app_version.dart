import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';

class AppVersion extends StatelessWidget {
  const AppVersion({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Version ${AppConstants.appVersion}',
      style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12),
    );
  }
}
