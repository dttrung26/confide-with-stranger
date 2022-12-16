import 'package:confide_with_stranger/extension/string_helper.dart';
import 'package:confide_with_stranger/service/auth.dart';
import 'package:confide_with_stranger/view/authentication_screen/signin.dart';
import 'package:confide_with_stranger/widget/common_widget.dart';
import 'package:flutter/material.dart';

import '../home_screen.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController nickNameController = TextEditingController();

  TextEditingController emailController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  TextEditingController pwConfirmController = TextEditingController();

  bool _isLoading = false;

  final _auth = Authentication();

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(title: "CFSTR", context: context),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: nickNameController,
                      decoration: textFieldInputDecoration("Nickname"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter nickname.";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: textFieldInputDecoration("Email"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter email.";
                        } else if (!value.isValidEmail()) {
                          return "Email is at bad format.";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: pwController,
                      decoration: textFieldInputDecoration("Password"),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter password!";
                        } else if (value.length < 6) {
                          return "Password must contain at least 6 characters";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: pwConfirmController,
                      decoration: textFieldInputDecoration("Confirm Password"),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please confirm password.";
                        } else if (value != pwController.text) {
                          return "Please make sure your passwords match.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        _signUp();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: Colors.blueAccent),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SignIn(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign in",
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await _auth
          .signUpWithEmailAndPassword(
              emailController.text, pwController.text, nickNameController.text)
          .then(
        (isSuccessful) {
          if (isSuccessful) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
          } else {
            _isLoading = false;
          }
        },
      ).catchError((err) {
        showSnackBar(context, err.toString());
        setState(() {
          _isLoading = false;
        });
      });
    }
  }
}
