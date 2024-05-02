import 'package:flutter/material.dart';
import 'package:lumonidy_tasks/presentation/screens/admin/viewmodel/task_edit_viewmodel.dart';

class StatusFormField extends StatelessWidget {
  final String fieldName;
  final String fieldLabel;
  final TaskEditViewModel viewModel;
  final BuildContext context; // Agrega el parámetro BuildContext

  const StatusFormField({
    super.key,
    required this.fieldName,
    required this.fieldLabel,
    required this.viewModel,
    required this.context, // Declara el parámetro BuildContext
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fieldLabel),
        Row(
          children: [
            Radio(
              value: true,
              groupValue: viewModel.selectedStatus,
              onChanged: (value) {
                viewModel.updateFieldValue(fieldName, value.toString());
                // Notificar a Flutter que los datos han cambiado
                // y la interfaz de usuario debe actualizarse
                _updateSelectedStatus(true);
              },
            ),
            const Text('Abierto'),
            Radio(
              value: false,
              groupValue: viewModel.selectedStatus,
              onChanged: (value) {
                viewModel.updateFieldValue(fieldName, value.toString());
                // Notificar a Flutter que los datos han cambiado
                // y la interfaz de usuario debe actualizarse
                _updateSelectedStatus(false);
              },
            ),
            const Text('Cerrado'),
          ],
        ),
      ],
    );
  }

  void _updateSelectedStatus(bool selectedValue) {
    // Llamar a setState para reconstruir la interfaz de usuario
    viewModel.setSelectedStatus(selectedValue);
  }
}
