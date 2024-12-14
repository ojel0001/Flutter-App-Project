import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/screens/welcome_screen.dart';
import 'package:final_project/utils/app_state.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => AppState(),
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WelcomeScreen(),
    );
  }
}
