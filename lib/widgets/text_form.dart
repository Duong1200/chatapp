import 'package:flutter/material.dart';

class TextFormLogin extends StatelessWidget {
  const TextFormLogin({super.key, required this.controller, required this.number, required this.textInputType, required this.obscure, required this.text});
  final TextEditingController controller;
  final int number;
  final String text;
  final TextInputType textInputType;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.only(top: 5, left: 15),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 7,
            ),
          ]
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: textInputType,
        obscureText: obscure,
        decoration: InputDecoration(
            hintText: text,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(0),
            hintStyle: const TextStyle(
              height: 1,
            )
        ),
      ),
      //body: SingleChildScrollView(
      //         child: SafeArea(
      //           child: Container(
      //             width: double.infinity,
      //             padding: const EdgeInsets.symmetric(vertical: 300),
      //             child: const Column(
      //               children: [
      //                 Text(
      //                   'Zalo',
      //                   textAlign: TextAlign.center,
      //                   style: TextStyle(
      //                     color: Color(0xFF2979FF),
      //                     fontSize: 100,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //                 SizedBox(height: 230),
      //                 ButtonLogin(),
      //                 SizedBox(height: 20),
      //                 ButtonSignin(),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
    );
  }
}