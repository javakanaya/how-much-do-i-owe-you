import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/registration_screen.dart';
import '../ui/screens/auth/password_reset_screen.dart';
// Import other screens as they are created

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppConstants.registerRoute:
        return MaterialPageRoute(
          builder: (_) => const RegistrationScreen(),
        );

      case AppConstants.passwordResetRoute:
        return MaterialPageRoute(
          builder: (_) => const PasswordResetScreen(),
        );

      // Add cases for other routes as they are created

      // Default route for undefined routes
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text(
                    'No route defined for ${settings.name}',
                  ),
                ),
              ),
        );
    }
  }
}
