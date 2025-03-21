import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/app_theme.dart';
import 'config/app_constants.dart';
import 'config/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppConstants.loginRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
