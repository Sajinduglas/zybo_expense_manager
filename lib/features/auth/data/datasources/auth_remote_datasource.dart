import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDatasource {
  Future<OtpResponseModel> sendOtp(String phone);
  Future<CreateAccountResponseModel> createAccount(String phone, String nickname);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio dio;

  AuthRemoteDatasourceImpl({required this.dio});

  @override
  Future<OtpResponseModel> sendOtp(String phone) async {
    try {
      final response = await dio.post(
        ApiConstants.sendOtp,
        data: {'phone': phone},
      );
      return OtpResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        message: e.response?.data?['detail'] ?? e.message ?? 'Network error',
      );
    }
  }

  @override
  Future<CreateAccountResponseModel> createAccount(String phone, String nickname) async {
    try {
      final response = await dio.post(
        ApiConstants.createAccount,
        data: {'phone': phone, 'nickname': nickname},
      );
      return CreateAccountResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        message: e.response?.data?['detail'] ?? e.message ?? 'Network error',
      );
    }
  }
}
