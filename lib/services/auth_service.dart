// Path: lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthResult {
  final bool success;
  final String message;

  AuthResult(this.success, this.message);
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<AuthResult> updatePhoto({required String photoURL}) async {
    try {
      await _auth.currentUser!.updatePhotoURL(photoURL);
      return AuthResult(true, 'Photo updated successfully');
    } on FirebaseAuthException catch (e) {
      return AuthResult(false, mapErrorMessage(e));
    } catch (e) {
      return AuthResult(false, 'Unknown error updating photo: $e');
    }
  }

  Future<AuthResult> updateDisplayName({required String displayName}) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String currentPhotoUrl = currentUser.photoURL ?? '';

        // Verificar si la photoURL actual contiene ui-avatars.com
        bool isDefaultPhoto = currentPhotoUrl.contains('ui-avatars.com');

        // Actualizar solo el displayName
        await currentUser.updateDisplayName(displayName);

        // Si la photoURL actual es una imagen predeterminada, también actualizarla
        if (isDefaultPhoto) {
          String updatedPhotoUrl =
              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&background=random&rounded=true&size=256';

          await currentUser.updatePhotoURL(updatedPhotoUrl);
        }

        return AuthResult(true, 'Display name updated successfully');
      } else {
        return AuthResult(false, 'User not authenticated');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult(false, mapErrorMessage(e));
    } catch (e) {
      return AuthResult(false, 'Unknown error updating display name: $e');
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return AuthResult(true, 'Login successful');
    } on FirebaseAuthException catch (e) {
      return AuthResult(false, mapErrorMessage(e));
    } catch (e) {
      return AuthResult(false, 'Error desconocido al autenticar: $e');
    }
  }

  Future<AuthResult> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Obtener el usuario recién creado
      User? user = userCredential.user;

      if (user != null) {
        // Generar la URL de la imagen con el nombre del usuario
        String photoUrl =
            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&background=random&rounded=true&size=256';

        await user.updatePhotoURL(photoUrl);
        await user.updateDisplayName(displayName);

        return AuthResult(true, 'Registration successful');
      } else {
        return AuthResult(false, 'User registration failed');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult(false, mapErrorMessage(e));
    } catch (e) {
      return AuthResult(false, 'Unknown error while registering: $e');
    }
  }

  Future<AuthResult> logout() async {
    try {
      await _auth.signOut();
      return AuthResult(true, 'Logout successful');
    } catch (e) {
      return AuthResult(false, 'Error desconocido al cerrar sesión: $e');
    }
  }

  String mapErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se ha encontrado un usuario con ese correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'weak-password':
        return 'La contraseña proporcionada es demasiado débil.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con el correo electrónico proporcionado.';
      case 'invalid-credential':
        return 'Credenciales no válidas. ¿Has probado a registrarte?';
      default:
        return 'Error desconocido: ${e.message} - ${e.code}';
    }
  }
}
