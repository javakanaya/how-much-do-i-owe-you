import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/firebase_options.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/ui/screens/app_error_screen.dart';
import 'package:how_much_do_i_owe_you/ui/screens/app_loading_screen.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/login_screen.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/register_screen.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/app_navigation_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    // Handle Firebase initialization errors
    debugPrint('Failed to initialize Firebase: $e');
    runApp(
      ProviderScope(
        child: MaterialApp(home: AppErrorScreen(message: 'Failed to initialize app: $e')),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,

      // Using a single main route to an AuthWrapper that handles navigation
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const AppNavigationWrapper();
          } else {
            return const LoginScreen();
          }
        }, // Let AuthWrapper handle auth state
        loading: () => const AppLoadingScreen(),
        error:
            (error, stackTrace) =>
                AppErrorScreen(message: 'Authentication error: $error'),
      ),

      // Define additional routes for non-auth dependent screens
      routes: {
        '/register': (context) => const RegisterScreen(),
        // '/about': (context) => const AboutScreen(),
        // Other routes that don't depend on auth state
      },
    );
  }
}
