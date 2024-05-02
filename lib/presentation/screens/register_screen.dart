// Path: lib/presentation/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_bloc.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_event.dart';

import 'package:lumonidy_tasks/utils/utils.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, String> credentials = {};

    if (kDebugMode) {
      credentials = Utils.getDebugCredential(index: 1);
    }

    final displayNameController =
        TextEditingController(text: credentials['displayName'] ?? '');
    final emailController =
        TextEditingController(text: credentials['email'] ?? '');
    final passwordController =
        TextEditingController(text: credentials['password'] ?? '');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: displayNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final String displayName = displayNameController.text;
                final String email = emailController.text;
                final String password = passwordController.text;
                // Disparar el evento de registro con el Bloc
                context.read<AuthBloc>().add(RegisterRequested(
                      displayName: displayName,
                      email: email,
                      password: password,
                    ));
                // Navegar a la pantalla de inicio
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Colors.lightGreen,
              ),
              child: const Text(
                'Register',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
