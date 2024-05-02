import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumonidy_tasks/models/user.dart' as firestore;

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final firestore.User userData;

  const AuthAuthenticated({required this.user, required this.userData})
      : super();

  @override
  List<Object?> get props => [user, userData];
}

class AuthUnauthenticated extends AuthState {
  final String? errorMessage;

  const AuthUnauthenticated({this.errorMessage}) : super();

  @override
  List<Object?> get props => [errorMessage];
}
