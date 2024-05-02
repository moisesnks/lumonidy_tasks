import 'package:flutter/material.dart';
import 'package:lumonidy_tasks/presentation/screens/admin/viewmodel/task_edit_viewmodel.dart';

class EditDialog extends StatelessWidget {
  final String fieldName;
  final TaskEditViewModel viewModel;
  final int index;
  final Function(String)? onSave;

  const EditDialog({
    super.key,
    required this.fieldName,
    required this.viewModel,
    required this.index,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar $fieldName'),
      content: TextFormField(
        controller:
            TextEditingController(text: viewModel.controllers[index].text),
        onChanged: (value) {
          viewModel.updateFieldValue(fieldName, value);
        },
        decoration: InputDecoration(
          labelText: viewModel.getFieldLabel(fieldName),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            if (onSave != null) {
              onSave!(viewModel
                  .controllers[index].text); // Pasar el nuevo valor al callback
            }
            Navigator.of(context).pop();
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
