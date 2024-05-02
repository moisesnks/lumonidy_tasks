import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumonidy_tasks/blocs/admin/admin_bloc.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_bloc.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_state.dart';
import 'package:lumonidy_tasks/models/task.dart';
import 'package:lumonidy_tasks/blocs/admin/admin_event.dart';

class TaskCreationScreen extends StatelessWidget {
  const TaskCreationScreen({
    super.key,
    required this.adminBloc,
    required this.authBloc,
  });

  final AdminBloc adminBloc;
  final AuthBloc authBloc;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      bloc: authBloc,
      listener: (context, state) {
        // Puedes manejar acciones según los cambios en el estado de autenticación aquí
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final String userId =
              state.user.uid; // Obteniendo el ID del usuario autenticado

          return _BuildTaskCreationScreen(
            adminBloc: adminBloc,
            userId: userId,
          );
        } else {
          // Manejar otros estados de autenticación si es necesario
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class _BuildTaskCreationScreen extends StatefulWidget {
  final AdminBloc adminBloc;
  final String userId;

  const _BuildTaskCreationScreen({
    required this.adminBloc,
    required this.userId,
  });

  @override
  _BuildTaskCreationScreenState createState() =>
      _BuildTaskCreationScreenState();
}

class _BuildTaskCreationScreenState extends State<_BuildTaskCreationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<Map<String, String>> _subtasks = [];

  void _addSubtask() {
    setState(() {
      _subtasks.add({'label': '', 'description': ''});
    });
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
  }

  void _createTask(BuildContext context) {
    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Title and Description')),
      );
      return;
    }

    bool isValidSubtask = false;
    for (final subtask in _subtasks) {
      final label = subtask['label'] ?? '';
      final description = subtask['description'] ?? '';
      if (label.isNotEmpty && description.isNotEmpty) {
        isValidSubtask = true;
        break;
      }
    }

    if (!isValidSubtask) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill at least one valid subtask')),
      );
      return;
    }

    final List<Subtask> subtasks = _subtasks.map((subtask) {
      return Subtask(
        id: _subtasks.indexOf(subtask),
        title: subtask['label'] ?? '',
        description: subtask['description'] ?? '',
        status: false,
      );
    }).toList();

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      openedBy: FirebaseFirestore.instance.doc('users/${widget.userId}'),
      openedDate: Timestamp.now(),
      subtasks: subtasks,
      assignedTo: [],
    );

    widget.adminBloc.add(AddTaskEvent(newTask));

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16.0),
            Column(
              children: _subtasks.asMap().entries.map((entry) {
                final int index = entry.key;
                final Map<String, String> subtask = entry.value;

                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: subtask['label'],
                        onChanged: (value) {
                          _subtasks[index]['label'] = value;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Subtask Label',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextFormField(
                        initialValue: subtask['description'],
                        onChanged: (value) {
                          _subtasks[index]['description'] = value;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Subtask Description',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _removeSubtask(index);
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _addSubtask,
              child: const Text('Add Subtask'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _createTask(context);
              },
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
