import 'package:colony_counter/ui/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CellCountingApp());
}

class CellCountingApp extends StatelessWidget {
  const CellCountingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colony Counter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const HomeScreen(),
    );
  }
}
