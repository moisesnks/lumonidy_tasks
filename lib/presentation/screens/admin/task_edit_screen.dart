import 'package:flutter/material.dart';
import 'package:lumonidy_tasks/blocs/admin/admin_bloc.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_bloc.dart';
import 'package:lumonidy_tasks/models/task.dart';
import './viewmodel/task_edit_viewmodel.dart';
import './widgets/editable_form_field.dart';
import './widgets/non_editable_field.dart';
import './widgets/status_form_field.dart';

class TaskEditScreen extends StatelessWidget {
  final AdminBloc adminBloc;
  final AuthBloc authBloc;
  final Task task;

  const TaskEditScreen({
    super.key,
    required this.adminBloc,
    required this.authBloc,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = TaskEditViewModel(task);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          viewModel.task.title,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: Task.fieldTypes.length,
          itemBuilder: (context, index) {
            final fieldName = Task.fieldTypes.keys.toList()[index];
            final fieldType = Task.fieldTypes[fieldName];
            final fieldLabel = viewModel.getFieldLabel(fieldName);

            return _buildField(
                context, fieldType!, fieldName, fieldLabel, index, viewModel);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          viewModel.applyChanges(adminBloc);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cambios realizados'),
            ),
          );
          Navigator.pop(context);
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    String fieldType,
    String fieldName,
    String fieldLabel,
    int index,
    TaskEditViewModel viewModel,
  ) {
    if (fieldType == 'editable') {
      if (fieldName == 'status') {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusFormField(context, fieldName, fieldLabel, viewModel),
            const SizedBox(height: 16.0), // Espacio entre campos
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEditableFormField(
                context, fieldName, fieldLabel, index, viewModel),
            const SizedBox(height: 16.0), // Espacio entre campos
          ],
        );
      }
    } else {
      final fieldValue = viewModel.controllers[index].text;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNonEditableField(fieldLabel, fieldValue),
          const SizedBox(height: 16.0), // Espacio entre campos
        ],
      );
    }
  }

  Widget _buildEditableFormField(
    BuildContext context,
    String fieldName,
    String fieldLabel,
    int index,
    TaskEditViewModel viewModel,
  ) {
    return EditableFormField(
      fieldName: fieldName,
      fieldLabel: fieldLabel,
      index: index,
      viewModel: viewModel,
    );
  }

  Widget _buildNonEditableField(String fieldLabel, String fieldValue) {
    return NonEditableField(
      fieldLabel: fieldLabel,
      fieldValue: fieldValue,
    );
  }

  Widget _buildStatusFormField(
    BuildContext context,
    String fieldName,
    String fieldLabel,
    TaskEditViewModel viewModel,
  ) {
    return StatusFormField(
      fieldName: fieldName,
      fieldLabel: fieldLabel,
      viewModel: viewModel,
      context: context,
    );
  }
}
