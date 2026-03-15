import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:zybo_expense_manager/features/sync/data/repositories/sync_repository.dart';
import 'package:zybo_expense_manager/features/categories/presentation/bloc/category_bloc.dart';
import 'package:zybo_expense_manager/features/categories/presentation/bloc/category_event.dart';
import 'package:zybo_expense_manager/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:zybo_expense_manager/features/transactions/presentation/bloc/transaction_event.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SyncRepository syncRepository;
  final CategoryBloc categoryBloc;
  final TransactionBloc transactionBloc;

  AuthBloc({
    required this.authRepository,
    required this.syncRepository,
    required this.categoryBloc,
    required this.transactionBloc,
  }) : super(AuthInitial()) {
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
        // Fetch existing cloud data before going to Home
        await syncRepository.fetchFromCloud();

        // Tell BLoCs to reload data from SQLite so UI updates instantly
        categoryBloc.add(LoadCategoriesEvent());
        transactionBloc.add(LoadTransactionsEvent());
        
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
      // New account — likely no data, but safe to fetch to sync last_time
      await syncRepository.fetchFromCloud();
      
      // Tell BLoCs to reload data from SQLite so UI updates
      categoryBloc.add(LoadCategoriesEvent());
      transactionBloc.add(LoadTransactionsEvent());
      
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
