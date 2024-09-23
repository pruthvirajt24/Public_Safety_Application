import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:women_safety_app/res/colors/colors.dart';
import 'package:women_safety_app/res/components/buttons/wide_elevated_button.dart';
import 'package:women_safety_app/res/components/spacing/vspace.dart';
import 'package:women_safety_app/views/child/auth/login_screen.dart';
import 'package:women_safety_app/views/child/auth/register_child_screen.dart';
import 'package:women_safety_app/views/child/auth/register_police_screen.dart';

class AuthSelectionScreen extends StatelessWidget {
  const AuthSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  const Vspace(size: 20),
                  Center(
                    child: Text(
                      "Welcome!",
                      style: TextStyle(
                        fontSize: size.width * 0.09,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.shield,
                    size: 80,
                    color: Colors.blue.shade700,
                  ),
                  Center(
                    child: Text(
                      "Please choose whether to\nlogin or register.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                        // color: policePrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Text(
                      "SignIn",
                      style: TextStyle(
                        fontSize: size.width * 0.06,
                        fontWeight: FontWeight.bold,
                        // color: policePrimary,
                      ),
                    ),
                    const Vspace(size: 10),
                    WideElevatedButton(
                      size: size,
                      label: "Login",
                      onCLick: () {
                        Get.to(() => const LoginScreen());
                      },
                      primary: Colors.grey.shade800,
                    ),
                    /*   const Vspace(size: 10),
                    WideElevatedButton(
                      size: size,
                      label: "Login as Police",
                      onCLick: () {},
                      primary: policePrimary,
                    ), */
                    const Vspace(size: 30),
                    Text(
                      "Register",
                      style: TextStyle(
                        fontSize: size.width * 0.06,
                        fontWeight: FontWeight.bold,
                        // color: policePrimary,
                      ),
                    ),
                    const Vspace(size: 10),
                    WideElevatedButton(
                      size: size,
                      label: "Register as User",
                      onCLick: () {
                        Get.to(() => const RegisterChildScreen(),
                            transition: Transition.cupertino);
                      },
                      primary: primaryColor,
                    ),
                    const Vspace(size: 10),
                    WideElevatedButton(
                      size: size,
                      label: "Register as Police",
                      onCLick: () {
                        Get.to(() => const RegisterPoliceScreen(),
                            transition: Transition.cupertino);
                      },
                      primary: policePrimary,
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
