import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String content;
  String todoId;
  Timestamp dateCreated;
  bool done;

  Todo({
    required this.content,
    required this.todoId,
    required this.dateCreated,
    required this.done,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content;
    data['todoId'] = todoId;
    data['dateCreated'] = dateCreated;
    data['done'] = done;
    return data;
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      content: json['content'],
      todoId: json['todoId'],
      dateCreated: json['dateCreated'],
      done: json['done'],
    );
  }
}
