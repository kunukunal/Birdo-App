import 'dart:convert';

import 'package:birdo/auth/login/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName = 'Unknown User';
  String userEmail = 'No Email';
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Unknown User';
      userEmail = prefs.getString('userEmail') ?? 'No Email';
    });
  }

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');

    if (email != null) {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final response = await http.post(
        Uri.parse('https://api.thebirdo.com/api/logout'),
        body: jsonEncode({'email': email, 'fcm_token': fcmToken}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await prefs.clear();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (Route<dynamic> route) => false,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout failed. Please try again.')),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF34BB91),
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34BB91),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 16),
              ),
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
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back, size: 25),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Lottie.asset(
                        'assets/images/Animation - 1747721754440.json',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 280,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(27),
                        ),
                        child: Center(
                          child: Text(
                            userName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 280,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(27),
                        ),
                        child: Center(
                          child: Text(
                            userEmail,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // InkWell(
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => const ChangePassword(),
                      //       ),
                      //     );
                      //   },
                      //   child: Container(
                      //     width: 280,
                      //     height: 50,
                      //     decoration: BoxDecoration(
                      //       color: Colors.grey[50],
                      //       borderRadius: BorderRadius.circular(27),
                      //     ),
                      //     child: const Center(
                      //       child: Padding(
                      //         padding: EdgeInsets.only(left: 20, right: 20),
                      //         child: Row(
                      //           mainAxisAlignment:
                      //               MainAxisAlignment.spaceBetween,
                      //           children: [
                      //             Text(
                      //               'Change Password',
                      //               style: TextStyle(
                      //                   fontSize: 16,
                      //                   fontWeight: FontWeight.w400),
                      //             ),
                      //             Icon(Icons.keyboard_arrow_right,
                      //                 size: 25, color: Colors.grey),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 20),
                      FilledButton(
                        onPressed:
                            _isLoggingOut ? null : _showLogoutConfirmation,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF34BB91),
                          minimumSize: const Size(280, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                        ),
                        child: _isLoggingOut
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Log Out',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
