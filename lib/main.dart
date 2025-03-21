import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import our screens
// Note: These imports would match your project structure
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/registration_screen.dart';
import 'ui/screens/auth/password_reset_screen.dart';
import 'config/app_theme.dart';
import 'config/app_constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'How Much Do I Owe You?',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppConstants.loginRoute,
      routes: {
        AppConstants.loginRoute: (context) => const LoginScreen(),
        AppConstants.registerRoute:
            (context) => const RegistrationScreen(),
        AppConstants.passwordResetRoute:
            (context) => const PasswordResetScreen(),
        // Add more routes as needed for your app's flow
      },
    );
  }
}
