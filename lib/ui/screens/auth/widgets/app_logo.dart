import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogo({super.key, this.size = 64, this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.account_balance_wallet,
      size: size,
      color: color ?? Theme.of(context).primaryColor,
    );
  }
}
