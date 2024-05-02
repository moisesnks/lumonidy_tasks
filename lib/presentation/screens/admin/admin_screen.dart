import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lumonidy_tasks/blocs/admin/admin_bloc.dart';
import 'package:lumonidy_tasks/blocs/admin/admin_event.dart';
import 'package:lumonidy_tasks/blocs/admin/admin_state.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_bloc.dart';
import 'package:lumonidy_tasks/models/task.dart';

import 'task_creation_screen.dart';
import 'task_edit_screen.dart';

class AdminScreen extends StatelessWidget {
  final AuthBloc authBloc;
  final AdminBloc adminBloc;

  const AdminScreen(
      {super.key, required this.adminBloc, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminBloc>(
      create: (context) => adminBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
        ),
        body: _buildBody(context),
        floatingActionButton: _addTaskButton(context),
      ),
    );
  }

  Widget _addTaskButton(BuildContext context) {
    return FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TaskCreationScreen(authBloc: authBloc, adminBloc: adminBloc),
            ),
          ).then((value) {
            adminBloc.add(LoadDataEvent());
          });
        },
        child: const Icon(Icons.add));
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      bloc: adminBloc,
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is AdminLoaded) {
          return _buildTaskList(state.tasks);
        } else if (state is AdminUpdated) {
          return _buildTaskList(state.updatedTasks);
        } else if (state is AdminError) {
          return Center(
            child: Text('Error: ${state.errorMessage}'),
          );
        } else {
          return const Center(
            child: Text('No data'),
          );
        }
      },
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    // Si no hay tareas, mostrar un mensaje tasks = []
    if (tasks.isEmpty) {
      return const Center(
        child: Text('No hay tareas'),
      );
    }

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return _buildTaskCard(context, tasks[index]);
          },
        ));
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    return Card(
      child: ListTile(
        leading: _buildTaskIcon(task),
        title: Text(task.title),
        subtitle: Text(task.description),
        trailing: _buildTaskActions(context, task),
        onTap: _buildTaskOnTap(context, task),
      ),
    );
  }

  _buildTaskOnTap(BuildContext context, Task task) {
    return () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskEditScreen(
            authBloc: authBloc,
            adminBloc: adminBloc,
            task: task,
          ),
        ),
      ).then((value) {
        adminBloc.add(LoadDataEvent());
      });
    };
  }

  Widget _buildTaskActions(BuildContext context, Task task) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskEditScreen(
                    authBloc: authBloc,
                    adminBloc: adminBloc,
                    task: task,
                  ),
                )).then((value) {
              adminBloc.add(LoadDataEvent());
              // refresh the screen
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            showConfirmationDialog(context, task);
          },
        ),
      ],
    );
  }

  Widget _buildTaskIcon(Task task) {
    if (task.status) {
      return SvgPicture.asset(
        'assets/icons/issue.svg',
        width: 24.0,
        height: 24.0,
      );
    } else {
      return SvgPicture.asset(
        'assets/icons/issue_busy.svg',
        width: 24.0,
        height: 24.0,
      );
    }
  }

  void showConfirmationDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Borrar tarea'),
          content: Text(
              'Estás seguro de que quieres eliminar la tarea ${task.title}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                adminBloc.add(DeleteTaskEvent(task));
                Navigator.pop(context);
              },
              child: const Text('Borrar'),
            ),
          ],
        );
      },
    );
  }
}
