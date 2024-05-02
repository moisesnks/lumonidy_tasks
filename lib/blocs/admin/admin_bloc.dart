// Path: lib/blocs/admin/admin_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumonidy_tasks/services/firestore_service.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final FirestoreService _firestoreService;

  AdminBloc({required FirestoreService firestoreService})
      : _firestoreService = firestoreService,
        super(AdminInitial()) {
    on<LoadDataEvent>(_onLoadData);
    on<AddTaskEvent>(_onAddTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<UpdateTaskEvent>(_onUpdateTask);
  }

  Future<String> getUserName(String userId) async {
    final user = await _firestoreService.getUser(userId);
    return user?.displayName ?? 'Unknown';
  }

  void _onUpdateTask(UpdateTaskEvent event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await _firestoreService.updateTask(event.task);
      final updatedTasks = await _firestoreService.getTasks();
      emit(AdminUpdated(updatedTasks)); // Emitir el estado actualizado
    } catch (e) {
      emit(AdminError('Failed to update task: $e'));
    }
  }

  void _onDeleteTask(DeleteTaskEvent event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await _firestoreService.deleteTask(event.task.id);
      // Recargar datos después de eliminar la tarea
      final updatedTasks = await _firestoreService.getTasks();
      emit(AdminUpdated(updatedTasks)); // Emitir el estado actualizado
    } catch (e) {
      emit(AdminError('Failed to delete task: $e'));
    }
  }

  void _onLoadData(LoadDataEvent event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final tasks = await _firestoreService.getTasks();
      final users = await _firestoreService.getUsers();
      emit(AdminLoaded(tasks, users));
    } catch (e) {
      emit(AdminError('Failed to load data: $e'));
    }
  }

  void _onAddTask(AddTaskEvent event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await _firestoreService.addTask(event.task);
      // Recargar datos después de agregar la tarea
      final updatedTasks = await _firestoreService.getTasks();
      emit(AdminUpdated(updatedTasks)); // Emitir el estado actualizado
    } catch (e) {
      emit(AdminError('Failed to add task: $e'));
    }
  }
}
