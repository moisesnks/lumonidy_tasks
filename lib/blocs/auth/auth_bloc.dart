// Path: lib/blocs/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:lumonidy_tasks/services/auth_service.dart';
import 'package:lumonidy_tasks/services/storage_service.dart';
import 'package:lumonidy_tasks/services/firestore_service.dart';

import 'auth_event.dart';
import 'auth_state.dart';

import 'package:lumonidy_tasks/models/user.dart' as firestore;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  final StorageService storageService;
  final FirestoreService firestoreService;

  AuthBloc(this.authService, this.storageService, this.firestoreService)
      : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetProfileRequested>(_onGetProfileRequested);
    on<UpdatePhotoRequested>(_onUpdatePhotoRequested);
    on<UpdateProfileNameRequested>(_onUpdateProfileNameRequested);
    on<GetProfileDataRequested>(_onGetProfileDataRequested);
  }

  void _onGetProfileDataRequested(
      GetProfileDataRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = authService.currentUser;
      if (user != null) {
        final firestore.User? userData =
            await firestoreService.getUser(user.uid);
        if (userData != null) {
          emit(AuthAuthenticated(user: user, userData: userData));
        } else {
          emit(const AuthUnauthenticated(errorMessage: 'User data not found'));
        }
      } else {
        emit(const AuthUnauthenticated(errorMessage: 'User not authenticated'));
      }
    } catch (e) {
      emit(AuthUnauthenticated(errorMessage: _mapErrorMessage(e)));
    }
  }

  void _onUpdateProfileNameRequested(
      UpdateProfileNameRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Obtén el usuario actual
      final user = authService.currentUser;
      if (user == null) {
        emit(const AuthUnauthenticated(errorMessage: 'User not authenticated'));
        return;
      }

      // Actualizar el nombre de usuario en AuthService (Firebase Auth)
      final result = await authService.updateDisplayName(
        displayName: event.displayName,
      );

      // Actualizar el nombre de usuario en Firestore
      final firestoreResult = await firestoreService.updateDisplayName(
        user.uid,
        event.displayName,
      );

      if (result.success && firestoreResult.success) {
        // Obtener los datos actualizados del usuario desde Firestore
        final updatedUserData = await firestoreService.getUser(user.uid);

        if (updatedUserData != null) {
          emit(AuthAuthenticated(user: user, userData: updatedUserData));
        } else {
          emit(const AuthUnauthenticated(
              errorMessage: 'Failed to fetch updated user data'));
        }
      } else {
        emit(AuthUnauthenticated(errorMessage: result.message));
      }
    } catch (e) {
      emit(AuthUnauthenticated(errorMessage: _mapErrorMessage(e)));
    }
  }

  void _onUpdatePhotoRequested(
      UpdatePhotoRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Obtén el usuario actual
      final user = authService.currentUser;
      if (user == null) {
        emit(const AuthUnauthenticated(errorMessage: 'User not authenticated'));
        return;
      }

      // Subir la imagen al almacenamiento
      String imageUrl =
          await storageService.uploadFile(event.imageFile, event.userId);

      // Actualizar el perfil del usuario con la nueva URL de imagen y el nombre de usuario actual en Firebase Auth (AuthService)
      final result = await authService.updatePhoto(photoURL: imageUrl);

      // Actualizar el perfil del usuario con la nueva URL de imagen en Firestore
      final firestoreResult = await firestoreService.updatePhotoURL(
        user.uid,
        imageUrl,
      );

      if (result.success && firestoreResult.success) {
        // Obtener los datos actualizados del usuario desde Firestore
        final updatedUserData = await firestoreService.getUser(user.uid);

        if (updatedUserData != null) {
          emit(AuthAuthenticated(user: user, userData: updatedUserData));
        } else {
          emit(const AuthUnauthenticated(
              errorMessage: 'Failed to fetch updated user data'));
        }
      } else {
        emit(AuthUnauthenticated(errorMessage: result.message));
      }
    } catch (e) {
      emit(AuthUnauthenticated(errorMessage: _mapErrorMessage(e)));
    }
  }

  void _onGetProfileRequested(
      GetProfileRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = authService.currentUser;
      final userData = await firestoreService.getUser(user!.uid);
      if (userData != null) {
        emit(AuthAuthenticated(user: user, userData: userData));
      } else {
        emit(const AuthUnauthenticated(errorMessage: 'User not authenticated'));
      }
    } catch (e) {
      emit(AuthUnauthenticated(errorMessage: _mapErrorMessage(e)));
    }
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result =
          await authService.login(email: event.email, password: event.password);
      if (result.success) {
        final userData =
            await firestoreService.getUser(authService.currentUser!.uid);
        if (userData != null) {
          emit(AuthAuthenticated(
              user: authService.currentUser!, userData: userData));
        } else {
          emit(const AuthUnauthenticated(errorMessage: 'User data not found'));
        }
      } else {
        emit(AuthUnauthenticated(errorMessage: result.message));
      }
    } catch (e) {
      emit(AuthUnauthenticated(errorMessage: _mapErrorMessage(e)));
    }
  }

  void _onRegisterRequested(
      RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await authService.register(
          email: event.email,
          password: event.password,
          displayName: event.displayName);
      if (result.success) {
        // Después de registrar el usuario en Firebase Auth, registra también en Firestore
        firestore.User newUser = firestore.User(
          id: authService.currentUser!.uid,
          displayName: event.displayName,
          email: event.email,
          photoURL: authService.currentUser!.photoURL ??
              'https://fakeimg.pl/256x256?text=Null&font=noto',
        );
        final firestoreResult = await firestoreService.createUser(newUser);
        if (firestoreResult.success) {
          final userData = await firestoreService.getUser(newUser.id);
          if (userData != null) {
            emit(AuthAuthenticated(
                user: authService.currentUser!, userData: userData));
          } else {
            emit(
                const AuthUnauthenticated(errorMessage: 'User data not found'));
          }
        } else {
          emit(AuthUnauthenticated(errorMessage: firestoreResult.message));
        }
      } else {
        emit(AuthUnauthenticated(errorMessage: result.message));
      }
    } catch (e) {
      emit(AuthUnauthenticated(errorMessage: _mapErrorMessage(e)));
    }
  }

  void _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await authService.logout();
      if (result.success) {
        emit(const AuthUnauthenticated());
      } else {
        emit(AuthUnauthenticated(errorMessage: result.message));
      }
    } catch (e) {
      emit(AuthUnauthenticated(errorMessage: _mapErrorMessage(e)));
    }
  }

  String _mapErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return authService.mapErrorMessage(error);
    } else {
      return 'Error desconocido al autenticar.';
    }
  }
}
