import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/router/route_names.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../di/injection.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class NicknamePage extends StatefulWidget {
  final NicknameRequired nicknameState;
  const NicknamePage({super.key, required this.nicknameState});

  @override
  State<NicknamePage> createState() => _NicknamePageState();
}

class _NicknamePageState extends State<NicknamePage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        _isValid = _nameController.text.trim().length >= 2;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onContinue(BuildContext context) {
    if (!_isValid) return;
    context.read<AuthBloc>().add(CreateAccountEvent(
          phone: widget.nicknameState.phone,
          nickname: _nameController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    const Color buttonColor = AppColors.blue;
    const Color inputBackground = AppColors.authFieldBackground;
    const Color background = AppColors.authBackground;

    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go(RouteNames.home);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return Scaffold(
              backgroundColor: background,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                        Text(
                          '👋 What should we call you?',
                          style: AppTextStyles.authTitle,
                        ),
                      const SizedBox(height: 20),
                      Text(
                        'This name stays only on your device.',
                        style: AppTextStyles.authSubtitle.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        decoration: BoxDecoration(
                          color: inputBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                style: AppTextStyles.authBody15,
                                decoration: InputDecoration(
                                  hintText: 'Eg: Johnnnie',
                                  hintStyle: AppTextStyles.authBody15.copyWith(
                                    color: AppColors.white.withValues(alpha: 0.4),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (_isValid)
                              const Icon(Icons.check_circle, color: AppColors.success),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isValid
                              ? buttonColor
                              : AppColors.disabledButton,
                          minimumSize: const Size(double.infinity, 56),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: (isLoading || !_isValid) ? null : () => _onContinue(context),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Continue',
                                style: AppTextStyles.authButtonText.copyWith(
                                  color: _isValid 
                                      ? AppColors.white 
                                      : AppColors.white.withValues(alpha: 0.3),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
