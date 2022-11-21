import 'package:confide_with_stranger/extension/cache_helper.dart';
import 'package:confide_with_stranger/view/home_page.dart';
import 'package:confide_with_stranger/view/signin.dart';
import 'package:confide_with_stranger/view/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _isUserLoggedIn = false;

  @override
  void initState() {
    _getLoggedInUserStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => HomePage(),
        '/signIn': (context) => SignIn(),
        '/signUp': (context) => SignUp(),
      },
    );
  }

  _getLoggedInUserStatus() async {
    _isUserLoggedIn =
        await CacheHelper().getUserLoggedInStatus() != null ? false : true;
  }
}
