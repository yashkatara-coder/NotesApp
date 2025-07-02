
import 'package:flutter/material.dart';
import 'package:notesapp_project/screens/notes_screen.dart';

// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main(){
  // sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi;

  runApp(NotesApp());
}
class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'NotesApp',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch:Colors.blueGrey,
            scaffoldBackgroundColor: const Color(0xFF1E1E1E)
        ),
        home: const NotesScreen()
    );
  }
}
