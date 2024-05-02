// Path: lib/presentation/screens/profile_screen.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_bloc.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_event.dart';
import 'package:lumonidy_tasks/blocs/auth/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final User user = state.user;
          String displayName = user.displayName ?? '';
          String photoURL = user.photoURL ?? '';

          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (photoURL.isNotEmpty)
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          _showImagePicker(context, context.read<AuthBloc>());
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(photoURL),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text('Name'),
                    subtitle: Text(displayName),
                    trailing: const Icon(Icons.edit),
                    onTap: () {
                      _showEditProfileDialog(context, displayName);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Email'),
                    subtitle: Text(user.email ?? 'Not available'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, String currentDisplayName) {
    TextEditingController nameController =
        TextEditingController(text: currentDisplayName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'New Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newDisplayName = nameController.text;
                if (newDisplayName.isNotEmpty) {
                  context.read<AuthBloc>().add(UpdateProfileNameRequested(
                        displayName: newDisplayName,
                      ));
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showImagePicker(BuildContext context, AuthBloc authBloc) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(authBloc, ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(authBloc, ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickImage(AuthBloc authBloc, ImageSource source) async {
    try {
      final imagePicker = ImagePicker();
      final XFile? image = await imagePicker.pickImage(source: source);
      User? user = (authBloc.state as AuthAuthenticated).user;

      if (image != null) {
        authBloc.add(UpdatePhotoRequested(
          userId: user.uid,
          imageFile: File(image.path),
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
    }
  }
}
