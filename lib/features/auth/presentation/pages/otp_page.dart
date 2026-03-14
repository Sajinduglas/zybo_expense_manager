// OTP entry screen removed — the new flow does not require manual OTP entry.
// send-otp response is used directly to authenticate.
import 'package:flutter/material.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('OTP Page (unused)')),
    );
  }
}
