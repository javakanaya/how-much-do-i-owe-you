import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/ui/screens/transaction/transaction_creation_screen.dart';
import 'package:provider/provider.dart';
import '../config/app_constants.dart';
import '../providers/auth_provider.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/registration_screen.dart';
import '../ui/screens/auth/password_reset_screen.dart';
import '../ui/screens/dashboard/home_screen.dart';
// Import other screens as they are created

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.loginRoute:
        return MaterialPageRoute(
          builder: (context) {
            // If already authenticated, redirect to home
            if (Provider.of<AuthProvider>(
              context,
              listen: false,
            ).isAuthenticated) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        );

      case AppConstants.registerRoute:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());

      case AppConstants.passwordResetRoute:
        return MaterialPageRoute(builder: (_) => const PasswordResetScreen());

      case AppConstants.homeRoute:
        return MaterialPageRoute(
          builder: (context) {
            // If not authenticated, redirect to login
            if (!Provider.of<AuthProvider>(
              context,
              listen: false,
            ).isAuthenticated) {
              return const LoginScreen();
            }
            return const HomeScreen();
          },
        );

      case AppConstants.newTransactionRoute:
        return MaterialPageRoute(
          builder: (context) {
            // If not authenticated, redirect to login
            if (!Provider.of<AuthProvider>(
              context,
              listen: false,
            ).isAuthenticated) {
              return const LoginScreen();
            }
            return const TransactionCreationScreen();
          },
        );

      // Default route for undefined routes
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
