import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/app_logo.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/screen_header.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenHeader(
      title: 'How Much Do I Owe You?',
      subtitle: 'Track shared expenses with friends',
      icon: AppLogo(),
    );
  }
}
