import 'package:confide_with_stranger/model/chat_user.dart';
import 'package:confide_with_stranger/model/user_model.dart';
import 'package:confide_with_stranger/view/authentication_screen/signin.dart';
import 'package:confide_with_stranger/view/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../extension/cache_helper.dart';
import '../service/firestore_database.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () {
      checkSignedIn();
    });
    super.initState();
  }

  void checkSignedIn() async {
    //Get user from FirebaseAuth
    var currentUser = FirebaseAuth.instance.currentUser;
    bool isSignedIn = await CacheHelper().getUserLoggedInStatus();
    if (isSignedIn && currentUser != null) {
      //Get user from Firebase Firestore
      ChatUser? chatUser =
          await FirestoreDatabase().getUserByUid(uid: currentUser.uid);
      if (chatUser != null) {
        Provider.of<UserModel>(context, listen: false).updateUser(chatUser);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SignIn(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Image.asset(
            'assets/images/flutter_dark_logo.png',
          ),
        ),
      ),
    );
  }
}
