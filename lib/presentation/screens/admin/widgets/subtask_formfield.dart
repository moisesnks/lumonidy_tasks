import 'package:flutter/material.dart';

class SubtaskFormField extends StatelessWidget {
  final TextEditingController labelController;
  final TextEditingController descriptionController;
  final VoidCallback onDelete;

  const SubtaskFormField({
    super.key,
    required this.labelController,
    required this.descriptionController,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: labelController,
            decoration: const InputDecoration(labelText: 'Task Label'),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Task Description'),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ],
    );
  }
}
