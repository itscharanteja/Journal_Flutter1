import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:untitled/journal_entry.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<JournalEntry> journalEntries = [];
  int journalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  Future<void> _loadJournalEntries() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final journalFile = File('${directory.path}/journals.json');

      if (await journalFile.exists()) {
        final String fileContent = await journalFile.readAsString();
        print("File content: $fileContent");

        List<dynamic> data = [];
        if (fileContent.trim().isNotEmpty) {
          try {
            data = jsonDecode(fileContent);
          } catch (e) {
            print("Error parsing JSON: $e");
            data = [];
          }
        }

        setState(() {
          journalEntries = data.map((entry) {
            return JournalEntry(
              title: entry['title'] ?? 'Untitled',
              content: entry['content'] ?? '',
              imagePaths: List<String>.from(jsonDecode(entry['imagePaths'] ?? '[]')),
              locationName: entry['locationName'],
              mood: entry['mood'],
            );
          }).toList();
          journalCount = journalEntries.length;
        });
      } else {
        print("Journal file does not exist at ${journalFile.path}");
        setState(() {
          journalEntries = [];
          journalCount = 0;
        });
      }
    } catch (e, stackTrace) {
      print("Error loading journal entries: $e");
      print("Stack trace: $stackTrace");
      setState(() {
        journalEntries = [];
        journalCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Travel Journal'),
        backgroundColor: Colors.grey[800],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Journals: $journalCount',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/NewJournal').then((_) {
                  _loadJournalEntries();
                });
              },
              child: const Text('Add New Journal'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/ViewJournal');
              },
              child: const Text('View Journals'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/JourneyMap');
              },
              child: const Text('View Journey Map'),
            ),
          ],
        ),
      ),
    );
  }
}
