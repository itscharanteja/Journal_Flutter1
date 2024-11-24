import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'journal_entry.dart';
import 'package:path_provider/path_provider.dart';
import 'package:untitled/JournalDetail.dart';

class ViewJournal extends StatefulWidget {
  final List<JournalEntry>? entries;
  const ViewJournal({super.key, this.entries});

  //
  // final List<JournalEntry> entries;
  // ViewJournal({required this.entries});
  @override
  State<ViewJournal> createState() => _ViewJournalState();
}

class _ViewJournalState extends State<ViewJournal> {
  List<JournalEntry> entries = [];
  // bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final journalFile = File('${directory.path}/journals.json');

      if (await journalFile.exists()) {
        final String fileContent = await journalFile.readAsString();
        print('File content: $fileContent'); // Debugging
        final List<dynamic> data = jsonDecode(fileContent);

        setState(() {
          entries = data.map((entry) {
            // Handle both `imagePath` and `imagePaths`
            List<String> imagePaths = [];
            if (entry.containsKey('imagePaths')) {
              if (entry['imagePaths'] is String) {
                imagePaths = List<String>.from(jsonDecode(entry['imagePaths']));
              }
              // else if (entry.containsKey('imagePath') && entry['imagePath'] != null) {
              //   imagePaths = [entry['imagePath']];
              // }
              else {
                imagePaths = List<String>.from(entry['imagePaths']);
              }
              print('Image paths for entry "${entry['title']}": $imagePaths');
              // List<dynamic> imagePaths = entry['imagePaths'] is String
              //     ? jsonDecode(entry['imagePaths'])
              //     : entry['imagePaths'] as List<dynamic>;
              // imagePath = imagePaths.isNotEmpty ? imagePaths.first : '';
            }
            // else if (entry.containsKey('imagePath')) {
            //   imagePath = entry['imagePath'] ?? '';
            // }

            return JournalEntry(
              title: entry['title'] ?? 'Untitled',
              content: entry['content'] ?? 'No content',
              imagePaths: imagePaths,
              locationName: entry['location'] ?? '',
              mood: entry['mood'] ?? '',
            );
          }).toList();
        });
      } else {
        print('journals.json file does not exist.');
      }
    } catch (e) {
      print('Error loading journals: $e');
    }
  }

  // Future<void> _loadJournals() async{
  //   try{
  //     final directory=await getApplicationDocumentsDirectory();
  //     final journalFile=File('${directory.path}/journals.json');
  //
  //     if(await journalFile.exists()){
  //       final String fileContent= await journalFile.readAsString();
  //       final List<dynamic> data =jsonDecode(fileContent);
  //
  //       setState(() {
  //          entries=data.map((entry){
  //           List<dynamic> imagePaths=jsonDecode(entry['imagePaths']);
  //           return JournalEntry(title: entry['title'], imagePath: imagePaths.isNotEmpty ? imagePaths.first : '', content: entry['content']);
  //
  //         }).toList();
  //         // _isLoading=false;
  //       });
  //     }
  //     // else{
  //     //   setState(() {
  //     //     _isLoading=false;
  //     //   });
  //     // }
  //   }
  //   catch(e){
  //     print('Error loading journals : $e');
  //     // setState(() {
  //     //   _isLoading=false;
  //     // });
  //   }
  // }

  Future<void> _deleteJournal(int index) async {
    setState(() {
      entries.removeAt(index);
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final journalFile = File('${directory.path}/journals.json');

      final updatedData = entries.map((entry) {
        return {
          'title': entry.title,
          'content': entry.content,
          'imagePath': entry.imagePaths,
        };
      }).toList();

      await journalFile.writeAsString(jsonEncode(updatedData));
      print("Journal Entry Deleted.");
    } catch (e) {
      print("error deleting the journal");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[800],
          title: const Text(
            "ViewJournal",
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(17.0),
          child: entries.isEmpty
              ? Center(child: Text("No journals yet"))
              : ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JournalDetail(entry: entry),
                            ));
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (entry.imagePaths.isNotEmpty)
                              Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: FileImage(File(entry.imagePaths[0])),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.title,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  if (entry.mood != null &&
                                      entry.mood!.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(Icons.mood,
                                            size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Mood: ${entry.mood!}",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 4),

                                  // Add Location Display
                                  if (entry.locationName != null &&
                                      entry.locationName!.isNotEmpty) ...[
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Location: ${entry.locationName}",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Text(entry.content.length >
                                                    50
                                                ? '${entry.content.length > 50}'
                                                : entry.content)),
                                        if (entry.content.length > 50)
                                          Text(
                                            'View More....',
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _deleteJournal(index);
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            )
                          ],
                          // title: Text(key,style: TextStyle(fontWeight: FontWeight.bold),),
                          // subtitle: Text(value),
                        ),
                      ),
                    );
                  }),
        ));
  }
}
