// Path: lib/blocs/auth_event.dart

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String displayName;
  final String email;
  final String password;

  RegisterRequested(
      {required this.displayName, required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class UpdateProfileNameRequested extends AuthEvent {
  final String displayName;

  UpdateProfileNameRequested({required this.displayName});
}

class GetProfileRequested extends AuthEvent {
  @override
  List<Object?> get props => [];
}

class UpdatePhotoRequested extends AuthEvent {
  // Future<String> uploadFile(File imageFile, String userId)
  final String userId;
  final dynamic imageFile;

  UpdatePhotoRequested({required this.userId, required this.imageFile});
}

class LogoutRequested extends AuthEvent {}

class GetProfileDataRequested extends AuthEvent {
  @override
  List<Object?> get props => [];
}
