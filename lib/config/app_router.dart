import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/ui/screens/activity/transaction_detail_screen.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/settlement_creation_screen.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/settlement_detail_scren.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/settlement_history_screen.dart';
import 'package:how_much_do_i_owe_you/ui/screens/transaction/transaction_creation_screen.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_navigation_bar.dart';

import 'package:provider/provider.dart';
import '../config/app_constants.dart';
import '../providers/auth_provider.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/registration_screen.dart';
import '../ui/screens/auth/password_reset_screen.dart';

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
              return const CustomNavigationBar();
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
            return const CustomNavigationBar();
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

      // Add route for Activity Screen
      case AppConstants.activityRoute:
        return MaterialPageRoute(
          builder: (context) {
            // If not authenticated, redirect to login
            if (!Provider.of<AuthProvider>(
              context,
              listen: false,
            ).isAuthenticated) {
              return const LoginScreen();
            }
            return const CustomNavigationBar(selectedPageIndex: 1);
          },
        );

      // Add route for Profile Screen
      case AppConstants.profileRoute:
        return MaterialPageRoute(
          builder: (context) {
            // If not authenticated, redirect to login
            if (!Provider.of<AuthProvider>(
              context,
              listen: false,
            ).isAuthenticated) {
              return const LoginScreen();
            }
            return const CustomNavigationBar(selectedPageIndex: 2);
          },
        );

      // Add route for Transaction Detail Screen
      case AppConstants.transactionDetailRoute:
        // Extract the transaction ID from settings arguments
        final String transactionId = settings.arguments as String;

        return MaterialPageRoute(
          builder: (context) {
            // If not authenticated, redirect to login
            if (!Provider.of<AuthProvider>(
              context,
              listen: false,
            ).isAuthenticated) {
              return const LoginScreen();
            }
            return TransactionDetailScreen(transactionId: transactionId);
          },
        );

      case AppConstants.settlementCreationRoute:
        // Extract the user ID and name from settings arguments
        final Map<String, dynamic> args =
            settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (context) {
            // If not authenticated, redirect to login
            if (!Provider.of<AuthProvider>(
              context,
              listen: false,
            ).isAuthenticated) {
              return const LoginScreen();
            }
            return SettlementCreationScreen(
              userId: args['userId'],
              userName: args['userName'],
            );
          },
        );

      case AppConstants.settlementDetailRoute:
        // Extract the settlement ID from settings arguments
        final String settlementId = settings.arguments as String;

        return MaterialPageRoute(
          builder: (context) {
            // If not authenticated, redirect to login
            if (!Provider.of<AuthProvider>(
              context,
              listen: false,
            ).isAuthenticated) {
              return const LoginScreen();
            }
            return SettlementDetailScreen(settlementId: settlementId);
          },
        );

      case AppConstants.settlementHistoryRoute:
        return MaterialPageRoute(
          builder: (context) {
            // If not authenticated, redirect to login
            if (!Provider.of<AuthProvider>(
              context,
              listen: false,
            ).isAuthenticated) {
              return const LoginScreen();
            }
            return const SettlementHistoryScreen();
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
