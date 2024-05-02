import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  String title;
  String description;
  final DocumentReference openedBy;
  final Timestamp openedDate;
  final List<Subtask> subtasks;
  final Map<String, dynamic> values;
  final List<DocumentReference> assignedTo;
  bool status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.openedBy,
    required this.openedDate,
    required this.subtasks,
    Map<String, dynamic>? values, // Allow values to be nullable
    required this.assignedTo,
    this.status = true,
  }) : values = values ??
            {
              'priority': 'P0',
              'estimate': 0,
              'effort': 0,
              'dueDate': '',
            };

  static const Map<String, String> fieldTypes = {
    'title': 'editable',
    'description': 'editable',
    'openedBy': 'text',
    'openedDate': 'text',
    'subtasks': 'list',
    'values': 'list',
    'assignedTo': 'list',
    'status': 'editable',
  };

  Task copy(other) {
    return Task(
      id: other.id,
      title: other.title,
      description: other.description,
      openedBy: other.openedBy,
      openedDate: other.openedDate,
      subtasks: other.subtasks,
      values: other.values,
      assignedTo: other.assignedTo,
      status: other.status,
    );
  }

  bool isEditable(String field) {
    return fieldTypes[field] == 'editable';
  }

  factory Task.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse subtasks
    final List<Subtask> subtasks = (data['subtasks'] as List<dynamic>?)
            ?.map((subtaskData) => Subtask.fromMap(subtaskData))
            .toList() ??
        [];

    // Parse values
    final Map<String, dynamic> values = data['values'] ?? {};

    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      openedBy: data['openedBy'] ?? FirebaseFirestore.instance.doc('users/0'),
      openedDate: data['openedDate'] ?? Timestamp.now(),
      subtasks: subtasks,
      values: values,
      assignedTo: List<DocumentReference>.from(data['assignedTo'] ?? []),
      status: data['status'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'openedBy': openedBy,
      'openedDate': openedDate,
      'subtasks': subtasks.map((subtask) => subtask.toMap()).toList(),
      'values': values,
      'assignedTo': assignedTo.map((userRef) => userRef).toList(),
      'status': status,
    };
  }
}

class Subtask {
  final int id;
  final String title;
  final String description;
  final bool status;

  Subtask({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
  });

  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
    };
  }
}
