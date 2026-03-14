import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<CreateAccountEvent>(_onCreateAccount);
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.sendOtp(event.phone);

      if (response.userExists && response.token != null) {
        // Existing user — token comes from send-otp response, go straight to Home
        await authRepository.saveSession(
          token: response.token!,
          nickname: response.nickname ?? '',
          phone: event.phone,
        );
        emit(AuthSuccess());
      } else {
        // New user — token is null, go to nickname screen
        emit(NicknameRequired(phone: event.phone));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCreateAccount(CreateAccountEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.createAccount(event.phone, event.nickname);
      await authRepository.saveSession(
        token: response.token,
        nickname: event.nickname,
        phone: event.phone,
      );
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
