import 'package:flutter/material.dart';
import 'package:birdo/auth/login/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');
    if (email != null) {
      _emailController.text = email;
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showDialog("Error", "New password and confirm password do not match.");
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    final url = Uri.parse("http://api.thebirdo.com/api/change-password");
    final Map<String, dynamic> body = {
      'email': _emailController.text,
      'current_password': _currentPasswordController.text,
      'new_password': _newPasswordController.text,
      'new_password_confirmation': _confirmPasswordController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await _updateUserStatus();

        _showDialog("Success",
            responseData['message'] ?? "Password changed successfully.",
            success: true);
      } else {
        final responseData = jsonDecode(response.body);
        _showDialog(
            "Error", responseData['message'] ?? "Password change failed.");
      }
    } catch (e) {
      _showDialog("Error", "An error occurred. Please try again.");
    }

    if (mounted) {
      setState(() {
        _isChangingPassword = false;
      });
    }
  }

  Future<void> _updateUserStatus() async {
    final email = _emailController.text; // Ensure email is filled in
    final statusUrl = Uri.parse("http://api.thebirdo.com/api/update-status");

    try {
      final response = await http.post(
        statusUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'status': 1}),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } else {
        _showDialog("Error", "Failed to update status.");
      }
    } catch (e) {
      _showDialog("Error", "An error occurred while updating status.");
    }
  }

  void _showDialog(String title, String message, {bool success = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (success) {
                // Navigate to login page on success
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Login()));
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
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
                  "Change Password",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildTextField(_emailController, 'Email', false),
                const SizedBox(height: 20),
                _buildTextField(
                    _currentPasswordController, 'Current Password', true),
                const SizedBox(height: 20),
                _buildTextField(_newPasswordController, 'New Password', true),
                const SizedBox(height: 20),
                _buildTextField(
                    _confirmPasswordController, 'Confirm New Password', true),
                const SizedBox(height: 30),
                FilledButton(
                  onPressed: _isChangingPassword ? null : _changePassword,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF34BB91),
                    minimumSize: const Size(280, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: _isChangingPassword
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 18,
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

  Widget _buildTextField(
      TextEditingController controller, String hintText, bool obscureText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: controller,
        readOnly: hintText == 'Email',
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide.none,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
        ),
        obscureText: obscureText,
      ),
    );
  }
}
