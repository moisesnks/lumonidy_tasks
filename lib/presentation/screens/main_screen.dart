// Path: lib/presentation/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_bloc.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_event.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_state.dart';
import 'package:lumonidy_tasks/presentation/screens/home_screen.dart';
import 'profile_screen.dart';

// Clase para representar la información de cada pantalla
class ScreenInfo {
  final String title;
  final IconData icon;
  final Widget screen;

  ScreenInfo({
    required this.title,
    required this.icon,
    required this.screen,
  });
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _selectedIndex = 0;

  // Lista de información de pantalla, cada elemento contiene título, icono y widget de la pantalla correspondiente
  static final List<ScreenInfo> _screens = [
    ScreenInfo(
      title: 'Home',
      icon: Icons.home,
      screen: const HomeScreen(),
    ),
    ScreenInfo(
      title: 'Profile',
      icon: Icons.person,
      screen: const ProfileScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  final displayName = state.userData.displayName;
                  return Text(
                    'Hola 👋, $displayName!',
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  );
                } else {
                  return const Text('Usuario no autenticado',
                      style: TextStyle(fontSize: 14));
                }
              },
            ),
            Text(
              'Estás en ${_screens[_selectedIndex].title}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: _screens.map((info) => info.screen).toList(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _screens
            .map((info) => BottomNavigationBarItem(
                  icon: Icon(info.icon),
                  label: info.title,
                ))
            .toList(),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
