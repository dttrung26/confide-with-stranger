import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confide_with_stranger/service/auth.dart';
import 'package:confide_with_stranger/view/signin.dart';
import 'package:flutter/material.dart';

import '../extension/cache_helper.dart';
import '../extension/logs.dart';
import '../widget/common_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _chatTxtController = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;
  @override
  void initState() {
    _checkSignedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(
        title: "CFWSTR",
        context: context,
        actions: [
          IconButton(
            onPressed: () {
              _userLogout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              children: [Text("User")],
            ),
          ),
          SizedBox(
            height: 100,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: textFieldInputDecoration("Enter chat ..."),
                    controller: _chatTxtController,
                  ),
                ),
                SizedBox(
                  width: 20,
                  child: IconButton(
                      onPressed: () {
                        final chat = <String, String>{
                          "name": "someuser",
                          "text": _chatTxtController.text
                        };
                        db
                            .collection("rooms")
                            .doc("someuser")
                            .set(chat)
                            .onError(
                              (error, _) =>
                                  printLog("Error writing documents: $error"),
                            );
                      },
                      icon: Icon(Icons.send)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _checkSignedIn() async {
    bool isSignedIn = await CacheHelper().getUserLoggedInStatus() ?? false;
    if (!isSignedIn) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignIn()),
          (route) => false);
    }
  }

  _userLogout() {
    Authentication().signOut();
    Navigator.of(context).canPop() ? Navigator.of(context).pop() : null;
  }
}
