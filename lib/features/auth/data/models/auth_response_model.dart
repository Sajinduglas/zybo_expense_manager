class OtpResponseModel {
  final String status;
  final String otp;
  final bool userExists;
  final String? nickname;
  final String? token; // null when user_exists=false

  const OtpResponseModel({
    required this.status,
    required this.otp,
    required this.userExists,
    this.nickname,
    this.token,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      status: json['status'] as String,
      otp: json['otp'].toString(),
      userExists: json['user_exists'] as bool,
      nickname: json['nickname'] as String?,
      token: json['token'] as String?,
    );
  }
}

class CreateAccountResponseModel {
  final String status;
  final String token;

  const CreateAccountResponseModel({
    required this.status,
    required this.token,
  });

  factory CreateAccountResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateAccountResponseModel(
      status: json['status'] as String,
      token: json['token'] as String,
    );
  }
}
