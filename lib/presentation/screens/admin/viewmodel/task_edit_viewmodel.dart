import 'package:flutter/material.dart';
import 'package:lumonidy_tasks/models/task.dart';
import 'package:lumonidy_tasks/blocs/admin/admin_bloc.dart';
import 'package:lumonidy_tasks/blocs/admin/admin_event.dart';
import 'package:lumonidy_tasks/utils/utils.dart';

class TaskEditViewModel {
  final Task task;
  late List<TextEditingController> controllers;
  bool selectedStatus = true;
  int changeCount = 0;
  late List<String> originalFieldValues;

  TaskEditViewModel(this.task) {
    controllers = List.generate(
      Task.fieldTypes.length,
      (index) => TextEditingController(
        text: _getFieldValue(Task.fieldTypes.keys.toList()[index]),
      ),
    );
    selectedStatus = task.status;
    originalFieldValues = List.generate(
      Task.fieldTypes.length,
      (index) => _getFieldValue(Task.fieldTypes.keys.toList()[index]),
    );
  }

  String _getFieldValue(String fieldName) {
    switch (fieldName) {
      case 'title':
        return task.title;
      case 'description':
        return task.description;
      case 'openedBy':
        return task.openedBy.id;
      case 'openedDate':
        return Utils.formatTimestamp(task.openedDate);
      case 'status':
        return task.status.toString();
      case 'subtasks':
        return task.subtasks.toString();
      case 'values':
        return task.values.toString();
      case 'assignedTo':
        return task.assignedTo.toString();
      default:
        return '';
    }
  }

  String getFieldLabel(String fieldName) {
    switch (fieldName) {
      case 'title':
        return 'Título';
      case 'description':
        return 'Descripción';
      case 'openedBy':
        return 'Opened By';
      case 'openedDate':
        return 'Opened Date';
      case 'status':
        return 'Estado';
      case 'subtasks':
        return 'Subtareas';
      case 'values':
        return 'Valores';
      case 'assignedTo':
        return 'Asignado a';
      default:
        return '';
    }
  }

  void updateFieldValue(String fieldName, String newValue) {
    switch (fieldName) {
      case 'title':
        task.title = newValue;
        break;
      case 'description':
        task.description = newValue;
        break;
      case 'status':
        task.status = newValue == 'true';
        selectedStatus = task.status;
        break;
      default:
        break;
    }
    incrementChangeCount();
  }

  void incrementChangeCount() {
    changeCount++;
  }

  void resetFieldValues() {
    for (int i = 0; i < controllers.length; i++) {
      // Restaurar el valor original del campo en el controlador
      controllers[i].clear(); // Limpiar el texto actual
      controllers[i].text =
          originalFieldValues[i]; // Establecer el valor original
    }
    changeCount = 0; // Reiniciar el contador de cambios
  }

  void applyChanges(AdminBloc adminBloc) {
    adminBloc.add(UpdateTaskEvent(task));
    resetFieldValues(); // Restaurar los valores de los campos después de aplicar cambios
  }

  void setSelectedStatus(bool selected) {
    selectedStatus = selected;
  }
}
