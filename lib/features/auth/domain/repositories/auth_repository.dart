import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/auth_response_model.dart';

// ignore_for_file: unused_import
class AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final SharedPreferences prefs;

  AuthRepository({required this.remoteDatasource, required this.prefs});

  Future<OtpResponseModel> sendOtp(String phone) async {
    // Format phone with +91 country code if not already prefixed
    final formatted = phone.startsWith('+') ? phone : '+91$phone';
    return remoteDatasource.sendOtp(formatted);
  }

  Future<CreateAccountResponseModel> createAccount(String phone, String nickname) async {
    final formatted = phone.startsWith('+') ? phone : '+91$phone';
    return remoteDatasource.createAccount(formatted, nickname);
  }

  Future<void> saveSession({
    required String token,
    required String nickname,
    required String phone,
  }) async {
    await prefs.setString(AppConstants.kToken, token);
    await prefs.setString(AppConstants.kNickname, nickname);
    await prefs.setString(AppConstants.kPhone, phone);
  }

  Future<void> saveToken(String token) async {
    await prefs.setString(AppConstants.kToken, token);
  }

  Future<void> completeOnboarding() async {
    await prefs.setBool(AppConstants.kOnboardingComplete, true);
  }

  bool isLoggedIn() => (prefs.getString(AppConstants.kToken) ?? '').isNotEmpty;

  bool isProfileComplete() => (prefs.getString(AppConstants.kNickname) ?? '').isNotEmpty;

  bool isOnboardingComplete() => prefs.getBool(AppConstants.kOnboardingComplete) ?? false;
}
