import 'package:flutter/material.dart';
import 'services/puzzle_repository.dart'; // Make sure this import matches your path
import 'screens/home_screen.dart';     // Or your root screen widget

void main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize the puzzle repository to load levels.json from assets
  await PuzzleRepository.initialize();

  // 3. Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Words of Wonder',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomeScreen(),
    );
  }
}