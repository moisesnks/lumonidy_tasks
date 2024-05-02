// Path: lib/models/user.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String displayName;
  final String photoURL;
  String? role;
  final List<DocumentReference> assignedTasks = [];

  User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.photoURL,
    this.role,
    List<DocumentReference>? assiggnedTasks,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    List<DocumentReference>? assignedTasks = data['assignedTasks'] != null
        ? List<DocumentReference>.from(data['assignedTasks'])
        : [];

    return User(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'] ?? '',
      role: data['role'] ?? '',
      assiggnedTasks: assignedTasks,
    );
  }
}
