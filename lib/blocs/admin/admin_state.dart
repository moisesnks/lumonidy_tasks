// Path: lib/blocs/admin/admin_state.dart

import 'package:equatable/equatable.dart';
import 'package:lumonidy_tasks/models/task.dart';
import 'package:lumonidy_tasks/models/user.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final List<Task> tasks;
  final List<User> users;

  const AdminLoaded(this.tasks, this.users);

  @override
  List<Object?> get props => [tasks, users];
}

class AdminError extends AdminState {
  final String errorMessage;

  const AdminError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class AdminUpdated extends AdminState {
  final List<Task> updatedTasks;

  const AdminUpdated(this.updatedTasks);

  @override
  List<Object?> get props => [updatedTasks];
}
