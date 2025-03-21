import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import our screens
// Note: These imports would match your project structure
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/registration_screen.dart';
import 'ui/screens/auth/password_reset_screen.dart';

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
      theme: ThemeData(
        primaryColor: const Color(0xFF2176FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2176FF),
          primary: const Color(0xFF2176FF),
          secondary: const Color(0xFF2ED573),
          error: const Color(0xFFFF4757),
          background: const Color(0xFFF0F5FF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F5FF),
        fontFamily:
            'Poppins', // You'll need to add this font to your pubspec.yaml
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xFF2176FF),
              width: 2,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2176FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF2176FF),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/password-reset': (context) => const PasswordResetScreen(),
        // Add more routes as needed for your app's flow
      },
    );
  }
}
