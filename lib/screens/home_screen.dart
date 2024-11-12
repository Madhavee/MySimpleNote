import 'package:flutter/material.dart';
import '../models/note.dart';
import '../database/note_db_helper.dart';
import 'note_edit_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    final data = await NoteDatabaseHelper.instance.readAllNotes();
    setState(() {
      notes = data;
      filteredNotes = data;
    });
  }

  void _searchNotes(String query) {
    final filtered = notes.where((note) {
      final titleLower = note.title.toLowerCase();
      final contentLower = note.content.toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower) || contentLower.contains(searchLower);
    }).toList();
    setState(() {
      filteredNotes = filtered;
    });
  }

  Future<void> _confirmDelete(Note note) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Note'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this note?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                await NoteDatabaseHelper.instance.delete(note.id!);
                Navigator.of(context).pop();
                _refreshNotes();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MySimpleNote'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (query) => _searchNotes(query),
            ),
          ),
          // Notes list
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(child: Text('No notes available. Add some!'))
                : ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];


                String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(note.date.split(' ')[0]));

                return Card(
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(formattedDate),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NoteEditScreen(note: note),
                        ),
                      );
                      _refreshNotes();
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                            color: note.isPinned ? Colors.teal : Colors.grey,
                          ),
                          onPressed: () async {
                            setState(() {
                              note.isPinned = !note.isPinned;
                            });
                            await NoteDatabaseHelper.instance.update(note);
                            _refreshNotes();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => NoteEditScreen(note: note),
                              ),
                            );
                            _refreshNotes();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _confirmDelete(note);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NoteEditScreen(),
            ),
          );
          _refreshNotes();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
