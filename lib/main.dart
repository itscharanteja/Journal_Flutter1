import 'package:flutter/material.dart';
import 'package:untitled/JourneyMap.dart';
import 'package:untitled/LoginPage.dart';
import 'package:untitled/MainScreen.dart';
import 'package:untitled/NewJournal.dart';
import 'package:untitled/ViewJournal.dart';
import 'package:untitled/journal_entry.dart';

void main() {
  runApp(const TravelJournal());
}

class TravelJournal extends StatelessWidget {
  const TravelJournal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Travel Journal',
      home: const LoginPage(),
      routes: {
        '/MainScreen': (context) => const MainScreen(),
        '/NewJournal': (context) => const NewJournal(),
        '/ViewJournal': (context) => const ViewJournal(),
        '/JourneyMap': (context) => const JourneyMap(),
      },
    );
  }
}
