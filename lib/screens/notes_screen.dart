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

  List<Map<String,dynamic>> notes=[];

  @override
  void initState(){
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final fetchedNotes=await NotesDatabase.instance.getNotes();

    setState(() {
      notes = fetchedNotes;
    });
  }

  final List<Color> noteColors=[
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



  void showNoteDialog({int? id,String? title,String? content, int colorIndex=0}){
    showDialog(
        context: context,
        builder: (dialogContext){
          return NoteDialog(
            colorIndex:colorIndex,
            noteColors:noteColors,

            noteId: id,
            title: title,
            content: content,
            onNoteSaved:(newTitle,newDescription,currentDate,selectedColorIndex) async{

              if(id==null){
                await NotesDatabase.instance.addNotes(newTitle,newDescription,currentDate,selectedColorIndex);
              }
              else{
                await NotesDatabase.instance.updateNote(newTitle, newDescription, currentDate, selectedColorIndex, id);
              }
              fetchNotes();
            },
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Notes',
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:()async{

            // await NotesDatabase.instance.addNotes('Sample Title', 'Sample Description', '2025-01-01', 0);

            showNoteDialog();
          },
          backgroundColor:Colors.white,
          child: const Icon(Icons.add, color: Colors.black87,
          ),

        ),
        body: notes.isEmpty? Center(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notes_outlined,
                  size: 80,
                  color: Colors.grey[600],

                ),

                const SizedBox(height:20),

                Text(
                  'No Notes  Found',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,

                  ),
                )

              ],
            )
        ):
        Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing:16,
                  childAspectRatio: 0.85),
              itemCount: notes.length,

              itemBuilder: (context,index){
                final note= notes[index];
                return NoteCard(
                    note: note,
                    onDelete: ()async {
                      await NotesDatabase.instance.deleteNote(note['id']);
                      fetchNotes();
                    },
                    onTap: () {
                      showNoteDialog(
                          id: note['id'],
                          title: note['title'],
                          content: note['description'],
                          colorIndex: note['color']
                      );
                    },
                    noteColors: noteColors);
              }
          ),


        )

    );
  }
}