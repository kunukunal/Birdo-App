import 'package:birdo/auth/profile.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: 70,
          child: Image.asset('assets/images/logo.png'),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Profile(),
              ),
            );
          },
          child: const Icon(
            Icons.account_circle,
            size: 50,
            color: Color(0xFF34BB91),
          ),
        ),
      ],
    );
  }
}
