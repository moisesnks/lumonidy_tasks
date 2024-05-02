import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'services/firestore_service.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_state.dart';

import 'blocs/admin/admin_bloc.dart';

import 'presentation/screens/login_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  AuthService authService = AuthService();
  StorageService storageService = StorageService();
  FirestoreService firestoreService = FirestoreService();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authService, storageService, firestoreService),
        ),
        BlocProvider<AdminBloc>(
          create: (context) => AdminBloc(firestoreService: firestoreService),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumonidy Tasks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'CL'), // Configura el idioma y país deseado
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return BlocProvider<AdminBloc>(
                    create: (context) => context.read<AdminBloc>(),
                    child: const MainScreen(),
                  );
                } else {
                  return const LoginScreen();
                }
              },
            ),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
