import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/config/app_constants.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/firebase_options.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/ui/screens/auth/login_screen.dart';
import 'package:how_much_do_i_owe_you/ui/screens/home/home_screen.dart';
import 'package:how_much_do_i_owe_you/ui/screens/app_error_screen.dart';
import 'package:how_much_do_i_owe_you/ui/screens/app_loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (user) {
          if (user == null) {
            return const LoginScreen();
          } else {
            return const HomeScreen();
          }
        },
        loading: () => const AppLoadingScreen(),
        error:
            (error, stackTrace) =>
                AppErrorScreen(message: 'Authentication error: $error'),
      ),
    );
  }
}
