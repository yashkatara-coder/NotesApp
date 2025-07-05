import 'package:flutter/material.dart';
import 'package:notesapp_project/screens/note_card.dart';
import 'note_dialog.dart';
import '../database/notes_database.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> notes = [];
  List<Map<String, dynamic>> filteredNotes = [];

  TextEditingController searchController = TextEditingController();
  String sortOption = 'Date';
  int? selectedColorFilter;

  final List<Color> noteColors = [
    const Color(0xFFF3E5F5),
    const Color(0xFFFCE4EC),
    const Color(0xFF89CFF0),
    const Color(0xFFFFABAB),
    const Color(0xFFFFD59A),
    const Color(0xFF98FB98),
    const Color(0xFFFFD700),
    const Color(0xFFFFB6C1),
    const Color(0xFFFAFAD2),
    const Color(0xFFC3D3D3),
  ];

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final fetchedNotes = await NotesDatabase.instance.getNotes();
    setState(() {
      notes = fetchedNotes;
    });
    applyFilters();
  }

  void applyFilters() {
    final query = searchController.text.toLowerCase();

    List<Map<String, dynamic>> temp = notes.where((note) {
      final title = note['title'].toString().toLowerCase();
      final desc = note['description'].toString().toLowerCase();
      final matchesQuery = title.contains(query) || desc.contains(query);
      final matchesColor = selectedColorFilter == null || note['color'] == selectedColorFilter;
      return matchesQuery && matchesColor;
    }).toList();

    if (sortOption == 'Title') {
      temp.sort((a, b) => a['title'].toString().toLowerCase().compareTo(b['title'].toString().toLowerCase()));
    } else {
      temp.sort((a, b) => b['date'].toString().compareTo(a['date'].toString()));
    }

    setState(() {
      filteredNotes = temp;
    });
  }

  TextSpan highlightText(String source, String query) {
    if (query.isEmpty) return TextSpan(text: source);
    final matches = source.toLowerCase().split(query.toLowerCase());
    final spans = <TextSpan>[];
    int start = 0;

    for (int i = 0; i < matches.length; i++) {
      final part = matches[i];
      if (part.isNotEmpty) {
        spans.add(TextSpan(text: source.substring(start, start + part.length)));
        start += part.length;
      }
      if (i < matches.length - 1) {
        spans.add(TextSpan(
          text: source.substring(start, start + query.length),
          style: const TextStyle(backgroundColor: Colors.yellow),
        ));
        start += query.length;
      }
    }
    return TextSpan(style: const TextStyle(color: Colors.white), children: spans);
  }

  void showNoteDialog({
    int? id,
    String? title,
    String? content,
    int colorIndex = 0,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return NoteDialog(
          colorIndex: colorIndex,
          noteColors: noteColors,
          noteId: id,
          title: title,
          content: content,
          onNoteSaved: (newTitle, newDescription, currentDate, selectedColorIndex) async {
            if (id == null) {
              await NotesDatabase.instance.addNotes(newTitle, newDescription, currentDate, selectedColorIndex);
            } else {
              await NotesDatabase.instance.updateNote(newTitle, newDescription, currentDate, selectedColorIndex, id);
            }
            fetchNotes();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNoteDialog(),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search notes...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    searchController.clear();
                    applyFilters();
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => applyFilters(),
            ),
          ),

          // 🔽 Sort & Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: sortOption,
                  dropdownColor: Colors.grey[900],
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(
                      value: 'Date',
                      child: Text('Sort by Date', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: 'Title',
                      child: Text('Sort by Title', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        sortOption = value;
                      });
                      applyFilters();
                    }
                  },
                ),
                const Spacer(),
                DropdownButton<int?>(
                  value: selectedColorFilter,
                  dropdownColor: Colors.grey[900],
                  style: const TextStyle(color: Colors.white),
                  hint: const Text("Filter by Color", style: TextStyle(color: Colors.white)),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("All", style: TextStyle(color: Colors.white)),
                    ),
                    ...List.generate(noteColors.length, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: noteColors[index],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white),
                          ),
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedColorFilter = value;
                    });
                    applyFilters();
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notes_outlined, size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 20),
                  Text(
                    'No Notes Found',
                    style: TextStyle(fontSize: 20, color: Colors.grey[400], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = filteredNotes[index];
                  return NoteCard(
                    note: note,
                    titleSpan: highlightText(note['title'], query),
                    contentSpan: highlightText(note['description'], query),
                    onDelete: () async {
                      await NotesDatabase.instance.deleteNote(note['id']);
                      fetchNotes();
                    },
                    onTap: () {
                      showNoteDialog(
                        id: note['id'],
                        title: note['title'],
                        content: note['description'],
                        colorIndex: note['color'],
                      );
                    },
                    noteColors: noteColors,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
