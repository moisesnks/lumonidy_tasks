import 'package:flutter/material.dart';
import 'package:lumonidy_tasks/presentation/screens/admin/viewmodel/task_edit_viewmodel.dart';
import './edit_dialog.dart';

class EditableFormField extends StatefulWidget {
  final String fieldName;
  final String fieldLabel;
  final int index;
  final TaskEditViewModel viewModel;

  const EditableFormField({
    super.key,
    required this.fieldName,
    required this.fieldLabel,
    required this.index,
    required this.viewModel,
  });

  @override
  EditableFormFieldState createState() => EditableFormFieldState();
}

class EditableFormFieldState extends State<EditableFormField> {
  late String _editedValue;

  @override
  void initState() {
    super.initState();
    _editedValue = widget.viewModel.controllers[widget.index].text;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEditDialog(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.fieldLabel,
          suffixIcon: const Icon(Icons.edit),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          _editedValue,
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) async {
    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => EditDialog(
        fieldName: widget.fieldName,
        viewModel: widget.viewModel,
        index: widget.index,
        onSave: (newValue) {
          setState(() {
            _editedValue = newValue; // Actualizar el valor editado
          });
        },
      ),
    );

    if (newValue != null) {
      setState(() {
        _editedValue = newValue;
      });
    }
  }
}
