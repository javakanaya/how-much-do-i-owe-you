import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:how_much_do_i_owe_you/providers/balance_provider.dart';
import 'package:how_much_do_i_owe_you/services/balance_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/app_theme.dart';
import 'config/app_constants.dart';
import 'config/app_router.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create service instances
    final authService = AuthService();
    final balanceService = BalanceService();

    return MultiProvider(
      providers: [
        // Register AuthProvider with AuthService
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),

        // Register BalanceProvider with BalanceService
        ChangeNotifierProvider<BalanceProvider>(
          create: (_) => BalanceProvider(balanceService),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Initialize BalanceProvider with current user ID when authenticated
          if (authProvider.isAuthenticated && authProvider.user != null) {
            // We use Future.microtask to avoid calling setState during build
            Future.microtask(() {
              final balanceProvider = Provider.of<BalanceProvider>(
                context,
                listen: false,
              );
              balanceProvider.initialize(authProvider.user!.uid);
            });
          }

          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute:
                authProvider.isAuthenticated
                    ? AppConstants.homeRoute
                    : AppConstants.loginRoute,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
