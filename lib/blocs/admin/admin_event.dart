// Path: lib/blocs/admin/admin_event.dart

import 'package:equatable/equatable.dart';
import 'package:lumonidy_tasks/models/task.dart';

abstract class AdminEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDataEvent extends AdminEvent {}

class AddTaskEvent extends AdminEvent {
  final Task task;

  AddTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTaskEvent extends AdminEvent {
  final Task task;

  DeleteTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTaskEvent extends AdminEvent {
  final Task task;

  UpdateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}
