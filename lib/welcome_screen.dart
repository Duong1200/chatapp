import 'package:chatapp/widgets/button.dart';
import 'package:chatapp/widgets/button2.dart';
import 'package:chatapp/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                          children: [
                            TextSpan(
                                text: 'AloApp',
                                style: TextStyle(
                                  color: Color(0xFF2979FF),
                                  fontSize: 100,
                                  fontWeight: FontWeight.bold,
                                )
                            )
                          ]
                      ),
                    )
                ),
              )),
          const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: ButtonLogin()
          ),
          const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
              child: ButtonSignin()
          ),
        ],
      ),
    );
  }
}