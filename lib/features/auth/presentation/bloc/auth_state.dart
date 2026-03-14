import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// Send-OTP succeeded — user already exists, session is saved, navigate to home
class AuthSuccess extends AuthState {}

/// Send-OTP succeeded — new user, needs nickname entry
/// Token is NOT available yet; it will come from create-account API
class NicknameRequired extends AuthState {
  final String phone;

  const NicknameRequired({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
