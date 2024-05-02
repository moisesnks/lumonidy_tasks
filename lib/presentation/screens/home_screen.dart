import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumonidy_tasks/blocs/admin/admin_event.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_bloc.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_state.dart';
import 'package:lumonidy_tasks/blocs/admin/admin_bloc.dart';
import 'package:lumonidy_tasks/blocs/admin/admin_state.dart';
import 'package:lumonidy_tasks/services/firestore_service.dart';

// Screens
import 'package:lumonidy_tasks/presentation/screens/admin/admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late AdminBloc? _adminBloc;

  @override
  void initState() {
    super.initState();
    if (context.read<AuthBloc>().state is AuthAuthenticated) {
      final userData =
          (context.read<AuthBloc>().state as AuthAuthenticated).userData;
      if (userData.role == 'admin') {
        _adminBloc = AdminBloc(firestoreService: FirestoreService());
        _adminBloc!.add(LoadDataEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.userData.role == 'admin') {
            _adminBloc ??= AdminBloc(firestoreService: FirestoreService());

            return BlocListener<AdminBloc, AdminState>(
              bloc: _adminBloc,
              listener: (context, state) {
                if (state is AdminLoaded) {
                  setState(() {});
                }
              },
              child: AdminScreen(
                authBloc: context.read<AuthBloc>(),
                adminBloc: _adminBloc!,
              ),
            );
          } else {
            return const _UserScreen();
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _adminBloc?.close();
    super.dispose();
  }
}

class _UserScreen extends StatelessWidget {
  const _UserScreen();

  @override
  Widget build(BuildContext context) {
    return const Text('User Screen');
  }
}
