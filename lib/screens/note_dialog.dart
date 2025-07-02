import 'package:flutter/material.dart';
// import 'package:intl/find_locale.dart';
import 'package:intl/intl.dart';
class NoteDialog extends StatefulWidget {

  final int? noteId;
  final String? title;
  final String?content;
  final int colorIndex;
  final List<Color> noteColors;
  final Function onNoteSaved;


  const NoteDialog({
    super.key,
    this.noteId,
    this.title,
    this.content,
    required this.colorIndex,
    required this.noteColors,
    required this.onNoteSaved,
  });

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {

  late int _selectedColorIndex;


  @override
  void initState(){
    super.initState();
    _selectedColorIndex=widget.colorIndex;
  }


  @override
  Widget build(BuildContext context) {

    final titleController = TextEditingController(text: widget.title);
    final descriptionController = TextEditingController(text: widget.content);



    final  currentDate =DateFormat('E d MMM').format(DateTime.now());


    return AlertDialog(
      backgroundColor: widget.noteColors[_selectedColorIndex],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        widget.noteId==null ? 'Add Notes' :'Edit Notes',
        style: const TextStyle(
            color: Colors.black87
        )
        ,
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Text(
              currentDate,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,

              ),


            ),

            const SizedBox(height: 16),

            TextField(
              controller: titleController,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withValues(),
                  labelText:'Title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none
                  )
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              maxLines: 5,
              controller: descriptionController,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withValues(),
                  labelText:'Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none
                  )
              ),
            ),

            const SizedBox(height: 16),

            Wrap(
                spacing: 8,
                children:
                List.generate(
                    widget.noteColors.length,
                        (index)=>GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColorIndex = index;
                        });
                      },
                      child: CircleAvatar(
                          radius: 16,
                          backgroundColor: widget.noteColors[index],
                          child: _selectedColorIndex == index
                              ? const Icon(Icons.check,color: Colors.black54, size:16,)
                              :null
                      ),


                    )
                )
            )





          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: const Text('Cancel',style: TextStyle(color: Colors.black54),
          ),
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                )
            ),
            onPressed: () async {
              final newTitle = titleController.text;
              final newDescription= descriptionController.text;

              widget.onNoteSaved(
                  newTitle,
                  newDescription,
                  currentDate,
                  _selectedColorIndex
              );
              Navigator.pop(context);
            },
            child: Text('Save'))
      ],
    );
  }
}
