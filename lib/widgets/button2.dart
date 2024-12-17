import 'package:flutter/material.dart';

import '../signup_screen.dart';



class ButtonSignin extends StatelessWidget {
  const ButtonSignin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUpScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        alignment: Alignment.center,
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Text(
          'Tạo tài khoản mới',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFF2979FF),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}