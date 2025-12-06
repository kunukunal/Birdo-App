import 'dart:convert';

import 'package:birdo/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../footer/footer.dart';
import 'otp.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // bool _isChecked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
      );
    }
  }

  // Future<void> _login() async {
  //   // Navigator.pushReplacement(
  //   //   context,
  //   //   MaterialPageRoute(builder: (context) => const BottomNavBar()),
  //   // );
  //   final String email = _emailController.text.trim();
  //   final String password = _passwordController.text.trim();
  //
  //   if (email.isEmpty) {
  //     _showErrorDialog("Email and Password cannot be empty.");
  //     return;
  //   }
  //
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://api.thebirdo.com/api/login'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'email': email, 'password': password}),
  //     );
  //
  //     debugPrint("Response Status Code: ${response.statusCode}");
  //     debugPrint("Response Body: ${response.body}");
  //
  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //
  //       if (responseData.containsKey('user')) {
  //         final user = responseData['user'];
  //         String name = user['name'] ?? 'Unknown User';
  //         String email = user['email'] ?? 'No Email';
  //
  //         SharedPreferences prefs = await SharedPreferences.getInstance();
  //         await prefs.setString('userName', name);
  //         await prefs.setString('userEmail', email);
  //         await prefs.setBool('isLoggedIn', true);
  //
  //         if (!mounted) return;
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => const BottomNavBar()),
  //         );
  //       } else {
  //         _showErrorDialog("Invalid response from server.");
  //       }
  //     } else {
  //       final responseData = json.decode(response.body);
  //       String errorMessage = responseData['message'] ?? 'Login failed';
  //       _showErrorDialog(errorMessage);
  //     }
  //   } catch (e) {
  //     _showErrorDialog("An error occurred. Please try again.");
  //     debugPrint("Login error: $e");
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _login() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorDialog("Email cannot be empty.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.thebirdo.com/api/generate-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Save email to SharedPreferences for later use
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', email);

        // Show success message
        if (mounted) {
          AppSnackBar.adaptive('success', responseData['message']);

          // Navigate to OTP screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(email: email),
            ),
          );
        }
      } else if (response.statusCode == 404) {
        _showErrorDialog("User not found. Please check your email address.");
      } else if (response.statusCode == 403) {
        _showErrorDialog("User already logged in.");
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
        String errorMessage = responseData['message'] ?? 'Failed to send OTP';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog("An error occurred. Please try again.");
      debugPrint("Login error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: SizedBox(
                    height: 150,
                    child: Image.asset('assets/images/img_1.png'),
                  ),
                ),
                const Text(
                  "Welcome! to",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "THE Birdo",
                  style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFF34BB91),
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter email',
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: TextField(
                //     controller: _passwordController,
                //     obscureText: true,
                //     decoration: InputDecoration(
                //       filled: true,
                //       fillColor: Colors.grey[50],
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(20.0),
                //         borderSide: BorderSide.none,
                //       ),
                //       hintText: 'Password',
                //       hintStyle: const TextStyle(
                //         fontWeight: FontWeight.w300,
                //         fontSize: 16,
                //       ),
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 20),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: Row(
                //     children: [
                //       Checkbox(
                //         value: _isChecked,
                //         onChanged: (bool? value) {
                //           setState(() {
                //             _isChecked = value!;
                //           });
                //         },
                //         activeColor: const Color(0xFF34BB91),
                //       ),
                //       const Text.rich(
                //         TextSpan(children: [
                //           TextSpan(
                //             text: "I agree to ",
                //             style: TextStyle(color: Colors.black, fontSize: 16),
                //           ),
                //           TextSpan(
                //             text: "Terms of Service",
                //             style: TextStyle(
                //                 color: Color(0xFF34BB91), fontSize: 16),
                //           ),
                //           TextSpan(
                //             text: " and \n",
                //             style: TextStyle(color: Colors.black, fontSize: 16),
                //           ),
                //           TextSpan(
                //             text: "Privacy Policy",
                //             style: TextStyle(
                //                 color: Color(0xFF34BB91), fontSize: 16),
                //           ),
                //         ]),
                //       ),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 30),
                FilledButton(
                  onPressed: _isLoading ? null : _login,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF34BB91),
                    minimumSize: const Size(280, 55),
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
                          'Generate OTP',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
