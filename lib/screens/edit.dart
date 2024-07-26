import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:notes/data/models.dart';
import 'package:notes/services/database.dart';

class EditNotePage extends StatefulWidget {
  final Function() triggerRefetch;
  final NotesModel? existingNote;

  const EditNotePage({
    Key? key,
    required this.triggerRefetch,
    this.existingNote,
  }) : super(key: key);

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  bool isDirty = false;
  bool isNoteNew = true;
  late FocusNode titleFocus;
  late FocusNode contentFocus;
  late NotesModel currentNote;
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleFocus = FocusNode();
    contentFocus = FocusNode();
    titleController = TextEditingController();
    contentController = TextEditingController();

    if (widget.existingNote == null) {
      currentNote = NotesModel(
        content: '',
        title: '',
        date: DateTime.now(),
        isImportant: false,
        id: 0,
      );
      isNoteNew = true;
    } else {
      currentNote = widget.existingNote!;
      isNoteNew = false;
    }

    titleController.text = currentNote.title;
    contentController.text = currentNote.content;
  }

  @override
  void dispose() {
    titleFocus.dispose();
    contentFocus.dispose();
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  focusNode: titleFocus,
                  autofocus: true,
                  controller: titleController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onSubmitted: (text) {
                    titleFocus.unfocus();
                    FocusScope.of(context).requestFocus(contentFocus);
                  },
                  onChanged: (value) {
                    markTitleAsDirty(value);
                  },
                  textInputAction: TextInputAction.next,
                  style: TextStyle(
                    fontFamily: 'ZillaSlab',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Enter a title',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 32,
                      fontFamily: 'ZillaSlab',
                      fontWeight: FontWeight.w700,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  focusNode: contentFocus,
                  controller: contentController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onChanged: (value) {
                    markContentAsDirty(value);
                  },
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: 'Start typing...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: SafeArea(
                bottom: false,
                child: Container(
                  height: 80,
                  color: Theme.of(context).canvasColor.withOpacity(0.3),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: handleBack,
                      ),
                      Spacer(),
                      IconButton(
                        tooltip: 'Mark note as important',
                        icon: Icon(currentNote.isImportant
                            ? Icons.flag
                            : Icons.outlined_flag),
                        onPressed: titleController.text.trim().isNotEmpty &&
                                contentController.text.trim().isNotEmpty
                            ? markImportantAsDirty
                            : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: handleDelete,
                      ),
                      AnimatedContainer(
                        margin: EdgeInsets.only(left: 10),
                        duration: Duration(milliseconds: 200),
                        width: isDirty ? 100 : 0,
                        height: 42,
                        curve: Curves.decelerate,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            // primary: Theme.of(context).accentColor,
                            // onPrimary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(100),
                                bottomLeft: Radius.circular(100),
                              ),
                            ),
                          ),
                          icon: Icon(Icons.done),
                          label: Text(
                            'SAVE',
                            style: TextStyle(letterSpacing: 1),
                          ),
                          onPressed: handleSave,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> handleSave() async {
    setState(() {
      currentNote = currentNote.copyWith(
        title: titleController.text,
        content: contentController.text,
      );
    });

    if (isNoteNew) {
      var latestNote = await NotesDatabaseService.db.addNoteInDB(currentNote);
      setState(() {
        currentNote = latestNote;
      });
    } else {
      await NotesDatabaseService.db.updateNoteInDB(currentNote);
    }

    setState(() {
      isNoteNew = false;
      isDirty = false;
    });

    widget.triggerRefetch();
    titleFocus.unfocus();
    contentFocus.unfocus();
  }

  void markTitleAsDirty(String title) {
    setState(() {
      isDirty = true;
    });
  }

  void markContentAsDirty(String content) {
    setState(() {
      isDirty = true;
    });
  }

  void markImportantAsDirty() {
    setState(() {
      currentNote = currentNote.copyWith(isImportant: !currentNote.isImportant);
    });
    handleSave();
  }

  Future<void> handleDelete() async {
    if (isNoteNew) {
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text('Delete Note'),
            content: Text('This note will be deleted permanently'),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'DELETE',
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                onPressed: () async {
                  await NotesDatabaseService.db.deleteNoteInDB(currentNote);
                  widget.triggerRefetch();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  void handleBack() {
    Navigator.pop(context);
  }
}
