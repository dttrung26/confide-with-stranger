import 'package:confide_with_stranger/service/auth.dart';
import 'package:confide_with_stranger/view/home_page.dart';
import 'package:confide_with_stranger/view/signup.dart';
import 'package:confide_with_stranger/widget/common_widget.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(title: "CFWSTR", context: context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    decoration: textFieldInputDecoration("Email"),
                    controller: _emailController,
                  ),
                  TextField(
                    decoration: textFieldInputDecoration("Password"),
                    controller: _passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: const Text("Forgot Password?"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      _signInByEmailAndPassword();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          color: Colors.blueAccent),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 50.0,
                        width: 200.0,
                        child: Divider(color: Colors.grey.shade300),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: 50,
                        height: 40,
                        child: const Text("or"),
                      ),
                    ],
                  ),
                  MaterialButton(
                    height: 64,
                    shape: CircleBorder(
                        side: BorderSide(color: Colors.grey.shade300)),
                    onPressed: () {
                      _signInByGoogle();
                    },
                    child: Image.asset(
                      'assets/images/google.png',
                      scale: 2.0,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have account? ",
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SignUp(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign up",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  _signInByGoogle() {
    setState(() {
      _isLoading = true;
    });
    Authentication().signInByGoogle().then((isSuccessful) {
      if (isSuccessful) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        setState(() {
          _isLoading = false;
        });
        _passwordController.clear();
      }
    }).catchError((err) {
      _isLoading = false;
      _passwordController.clear();
      showSnackBar(context, err.toString());
      setState(() {
        _isLoading = false;
      });
    });
  }

  _signInByEmailAndPassword() {
    setState(() {
      _isLoading = true;
    });

    Authentication()
        .signInWithEmailAndPassword(
            _emailController.text, _passwordController.text)
        .then((isSuccessful) {
      if (isSuccessful) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        setState(() {
          _isLoading = false;
        });
        _passwordController.clear();
      }
    }).catchError((err) {
      _isLoading = false;
      _passwordController.clear();
      showSnackBar(context, err.toString());
      setState(() {
        _isLoading = false;
      });
    });
  }
}
