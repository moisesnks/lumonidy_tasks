// Path: lib/presentation/screens/login_screen.dart

import 'package:flutter/foundation.dart' show kDebugMode;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_bloc.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_event.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_state.dart';

import 'package:lumonidy_tasks/utils/utils.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, String> credentials = {};

    if (kDebugMode) {
      credentials = Utils.getDebugCredential(index: 1);
    }

    final emailController =
        TextEditingController(text: credentials['email'] ?? '');
    final passwordController =
        TextEditingController(text: credentials['password'] ?? '');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            _showErrorMessage(context, state.errorMessage);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return _buildLoadingWidget();
            } else {
              return _buildLoginForm(
                  context, emailController, passwordController);
            }
          },
        ),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String? errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage ?? 'Ha cerrado sesión'),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildLoginForm(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - kToolbarHeight - 24.0,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitleWidget(),
              const SizedBox(height: 56.0),
              _buildEmailTextField(emailController),
              const SizedBox(height: 16.0),
              _buildPasswordTextField(passwordController),
              const SizedBox(height: 16.0),
              const Spacer(flex: 1),
              _buildLoginButton(context, emailController, passwordController),
              const SizedBox(height: 16.0),
              _buildRegisterButton(context),
              const SizedBox(height: 16.0), // Espacio adicional al final
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSVGImageWidget() {
    return SvgPicture.asset(
      'assets/logo.svg',
      width: 48,
      height: 48,
    );
  }

  Widget _buildTitleWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSVGImageWidget(),
              const SizedBox(width: 12),
              const Text(
                'Lumonidy Tasks',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Hola! 👋',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailTextField(TextEditingController emailController) {
    return TextFormField(
      controller: emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPasswordTextField(TextEditingController passwordController) {
    return TextFormField(
      controller: passwordController,
      decoration: const InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
      ),
      obscureText: true,
    );
  }

  Widget _buildLoginButton(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController) {
    return ElevatedButton(
      onPressed: () {
        _login(context, emailController.text, passwordController.text);
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        backgroundColor: Colors.lightGreen,
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Login',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _login(BuildContext context, String email, String password) {
    context
        .read<AuthBloc>()
        .add(LoginRequested(email: email, password: password));
  }

  Widget _buildRegisterButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/register');
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        backgroundColor: Colors.greenAccent,
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Register',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
