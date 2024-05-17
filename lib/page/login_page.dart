import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/button.dart';
import 'package:social_media_app/components/text_field.dart';
import 'package:social_media_app/page/forget_pw_page.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  void signIn() async {
    // Show loading circle
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    // try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextController.text.trim(),
          password: passwordTextController.text.trim());

      // pop loading circle
      // ignore: use_build_context_synchronously
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop loading circle
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      //display error message
      displayMessage(e.code);
    }
  }

  // Display a dialog message
  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(message),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                const Icon(
                  Icons.message_sharp,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 50,
                ),
                //welcome back message
                Text("Welcome back, you've been missed!".tr(),
                        style: TextStyle(color: Colors.grey[700]))
                    .tr(),
                const SizedBox(
                  height: 25,
                ),
                //email TextField
                MyTextField(
                    controller: emailTextController,
                    hintText: 'Email',
                    obscureText: false),
                const SizedBox(
                  height: 10,
                ),
                //Password textField
                MyTextField(
                    controller: passwordTextController,
                    hintText: "Password".tr(),
                    obscureText: true),
                const SizedBox(
                  height: 15,
                ),
                // Forget Password
                _buildForgetPassword(),
                const SizedBox(
                  height: 20,
                ),
                //Sign in Button
                MyButton(onTap: signIn, text: "sign in".tr()),
                const SizedBox(
                  height: 25,
                ),
                //Go to register page
                _buildRegister()
              ],
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildRegister() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text("Not a member? ", style: TextStyle(color: Colors.grey[700])).tr(),
        GestureDetector(
          onTap: widget.onTap,
          child: const Text(
            " Register now",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ).tr(),
        )
      ],
    );
  }

  Widget _buildForgetPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const ForgetPassword();
            }));
          },
          child: const Text(
            "Forget Password?",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ).tr(),
        ),
      ],
    );
  }
}
