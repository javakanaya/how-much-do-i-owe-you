import 'package:flutter/material.dart';
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

      // Add cases for other routes as they are created

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
