import 'package:flutter/material.dart';

import 'screens/history_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TranscriptProApp());
}

class TranscriptProApp extends StatefulWidget {
  const TranscriptProApp({super.key});

  @override
  State<TranscriptProApp> createState() => _TranscriptProAppState();
}

class _TranscriptProAppState extends State<TranscriptProApp> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const HistoryScreen(),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transcript Pro',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E0E0E),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color(0xFFD0D0D0),
          surface: Color(0xFF1B1B1B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1B1B1B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1B1B1B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white70),
          ),
        ),
      ),
      home: Scaffold(
        body: pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) {
            setState(() {
              _index = value;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.graphic_eq),
              label: 'Transkriptio',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_copy_outlined),
              label: 'Tallennetut',
            ),
          ],
        ),
      ),
    );
  }
}
