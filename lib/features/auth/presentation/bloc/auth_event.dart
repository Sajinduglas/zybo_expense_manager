import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SendOtpEvent extends AuthEvent {
  final String phone;
  const SendOtpEvent(this.phone);

  @override
  List<Object?> get props => [phone];
}

class CreateAccountEvent extends AuthEvent {
  final String phone;
  final String nickname;
  const CreateAccountEvent({required this.phone, required this.nickname});

  @override
  List<Object?> get props => [phone, nickname];
}
