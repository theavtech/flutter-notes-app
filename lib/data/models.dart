import 'dart:math';

class NotesModel {
  final int id;
  final String title;
  final String content;
  final bool isImportant;
  final DateTime date;

  NotesModel({
    required this.id,
    required this.title,
    required this.content,
    required this.isImportant,
    required this.date,
  });

  factory NotesModel.fromMap(Map<String, dynamic> map) {
    return NotesModel(
      id: map['_id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      date: DateTime.parse(map['date'] as String),
      isImportant: (map['isImportant'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'content': content,
      'isImportant': isImportant ? 1 : 0,
      'date': date.toIso8601String(),
    };
  }

  factory NotesModel.random() {
    final random = Random();
    return NotesModel(
      id: random.nextInt(1000) + 1,
      title: 'Lorem Ipsum ' * (random.nextInt(4) + 1),
      content: 'Lorem Ipsum ' * (random.nextInt(4) + 1),
      isImportant: random.nextBool(),
      date: DateTime.now().add(Duration(hours: random.nextInt(100))),
    );
  }

  NotesModel copyWith({
    int? id,
    String? title,
    String? content,
    bool? isImportant,
    DateTime? date,
  }) {
    return NotesModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isImportant: isImportant ?? this.isImportant,
      date: date ?? this.date,
    );
  }
}
