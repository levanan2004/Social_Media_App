import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/button.dart';
import 'package:social_media_app/components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  // Sign user up
  void signUp() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    // make sure passwords match
    if (passwordTextController.text != confirmPasswordTextController.text) {
      // pop loading circle
      Navigator.pop(context);

      // show error to user
      displayMessage("Passwords don't match!");
      return;
    }

    // try creating the user
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailTextController.text.trim(),
              password: passwordTextController.text.trim());
      // after creating the user, create a new document in cloud firestore called Users
      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'username': emailTextController.text.split('@')[0], // Initial username
        'bio': 'Empty bio..', // Initally empty bio
        // add any additional fields as needed
      });
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
                  Icons.message_outlined,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 50,
                ),
                //welcome back message
                Text("Lets create an account for you",
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
                  height: 10,
                ),
                //Confirm Password textField
                MyTextField(
                    controller: confirmPasswordTextController,
                    hintText: "Confirm Password".tr(),
                    obscureText: true),
                const SizedBox(
                  height: 25,
                ),
                //Sign in Button
                MyButton(onTap: signUp, text: "Sign Up".tr()),
                const SizedBox(
                  height: 25,
                ),
                //Go to register page
                _buildGoToRegisterPage()
              ],
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildGoToRegisterPage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account? ",
                style: TextStyle(color: Colors.grey[700]))
            .tr(),
        GestureDetector(
          onTap: widget.onTap,
          child: const Text(
            " Login now",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ).tr(),
        )
      ],
    );
  }
}
