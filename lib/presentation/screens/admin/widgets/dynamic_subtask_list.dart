import 'package:flutter/material.dart';
import 'package:lumonidy_tasks/models/task.dart';
import 'subtask_formfield.dart';

class DynamicSubtasksList extends StatefulWidget {
  final GlobalKey<DynamicSubtasksListState> subtasksListKey;

  const DynamicSubtasksList({super.key, required this.subtasksListKey});

  @override
  DynamicSubtasksListState createState() => DynamicSubtasksListState();
}

class DynamicSubtasksListState extends State<DynamicSubtasksList> {
  final List<_SubtaskEntry> _subtasks = [];

  void addSubtask() {
    setState(() {
      _subtasks.add(_SubtaskEntry());
    });
  }

  void removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
  }

  List<Subtask> getSubtasks() {
    return _subtasks.map((subtask) {
      return Subtask(
        id: _subtasks.indexOf(subtask),
        title: subtask.labelController.text.trim(),
        description: subtask.descriptionController.text.trim(),
        status: false,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Subtasks:',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Column(
          children: _subtasks.asMap().entries.map((entry) {
            final index = entry.key;
            final subtask = entry.value;

            return SubtaskFormField(
              labelController: subtask.labelController,
              descriptionController: subtask.descriptionController,
              onDelete: () {
                removeSubtask(index);
              },
            );
          }).toList(),
        ),
        ElevatedButton(
          onPressed: () {
            widget.subtasksListKey.currentState?.addSubtask();
          },
          child: const Text('Add Subtask'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (var subtask in _subtasks) {
      subtask.labelController.dispose();
      subtask.descriptionController.dispose();
    }
    super.dispose();
  }
}

class _SubtaskEntry {
  final TextEditingController labelController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  _SubtaskEntry();
}
