import 'dart:async';
import 'dart:convert';

import 'package:birdo/utils/app_snackbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../footer/footer.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(4, (index) => FocusNode());

  bool _isLoading = false;
  bool _isResendLoading = false;
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  String _getOtpValue() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1) {
      if (index < 3) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
        // Auto verify when all 4 digits are entered
        if (_getOtpValue().length == 4) {
          _verifyOtp();
        }
      }
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOtp() async {
    final String otp = _getOtpValue();

    if (otp.length != 4) {
      _showErrorDialog("Please enter complete OTP");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      final response = await http.post(
        Uri.parse('https://api.thebirdo.com/api/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body:
            jsonEncode({'email': widget.email, 'otp': otp, 'fcm_token': token}),
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");
      dynamic responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        // OTP verified successfully - save login state
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', widget.email);
        await prefs.setString('token', responseBody['token']);

        // You can also save user name if needed (extract from email or get from API)
        await prefs.setString('userName', responseBody['user']['name']);
        await prefs.setInt('user_id', responseBody['user']['id']);
        await prefs.setString('userType', responseBody['user']['type']);

        if (!mounted) return;

        // Show success message
        AppSnackBar.adaptive('success', responseBody['message']);

        // Navigate to main app
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavBar(),
          ),
          (Route<dynamic> route) => false,
        );
      } else if (response.statusCode == 404) {
        _showErrorDialog(responseBody['message']);
        _clearOtpFields();
      } else if (response.statusCode == 400) {
        _showErrorDialog(responseBody['message']);
        _clearOtpFields();
      } else if (response.statusCode == 422) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('errors')) {
          String errorMessage = '';
          if (responseData['errors']['email'] != null) {
            errorMessage += responseData['errors']['email'].first + '\n';
          }
          if (responseData['errors']['otp'] != null) {
            errorMessage += responseData['errors']['otp'].first;
          }
          _showErrorDialog(errorMessage.trim());
        } else {
          _showErrorDialog(responseData['message'] ?? 'Validation failed');
        }
        _clearOtpFields();
      } else {
        final responseData = json.decode(response.body);
        String errorMessage =
            responseData['message'] ?? 'OTP verification failed';
        _showErrorDialog(errorMessage);
        _clearOtpFields();
      }
    } catch (e) {
      _showErrorDialog("An error occurred. Please try again.");
      debugPrint("OTP verification error: $e");
      _clearOtpFields();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResendLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.thebirdo.com/api/generate-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );

      debugPrint("Resend Response Status Code: ${response.statusCode}");
      debugPrint("Resend Response Body: ${response.body}");

      if (response.statusCode == 200) {
        _startResendTimer();
        _clearOtpFields();
        if (mounted) {
          AppSnackBar.adaptive('success', 'OTP sent successfully');
        }
      } else if (response.statusCode == 404) {
        _showErrorDialog("User not found");
      } else if (response.statusCode == 403) {
        _showErrorDialog("User already logged in");
      } else if (response.statusCode == 422) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('errors')) {
          String errorMessage =
              responseData['errors']['email']?.first ?? 'Validation failed';
          _showErrorDialog(errorMessage);
        } else {
          _showErrorDialog(responseData['message'] ?? 'Validation failed');
        }
      } else {
        final responseData = json.decode(response.body);
        String errorMessage = responseData['message'] ?? 'Failed to resend OTP';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog("Failed to resend OTP. Please try again.");
      debugPrint("Resend OTP error: $e");
    } finally {
      setState(() {
        _isResendLoading = false;
      });
    }
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _otpFocusNodes[0].requestFocus();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Logo
                SizedBox(
                  height: 120,
                  child: Image.asset('assets/images/img_1.png'),
                ),
                const SizedBox(height: 30),

                // Title
                const Text(
                  "Verify OTP",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                Text(
                  "Enter the 4-digit code sent to",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF34BB91),
                  ),
                ),
                const SizedBox(height: 40),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 60,
                      height: 60,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _otpFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF34BB91),
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) => _onOtpChanged(value, index),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),

                // Verify Button
                FilledButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF34BB91),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Verify OTP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 30),

                // Resend OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive code? ",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (_resendTimer > 0)
                      Text(
                        "Resend in ${_resendTimer}s",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _isResendLoading ? null : _resendOtp,
                        child: _isResendLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF34BB91),
                                ),
                              )
                            : const Text(
                                "Resend OTP",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF34BB91),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
