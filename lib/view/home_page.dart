import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confide_with_stranger/service/auth.dart';
import 'package:flutter/material.dart';

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
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(title: "CFWSTR", context: context, actions: [
        IconButton(
          onPressed: () {
            _userLogout();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.logout),
        ),
      ]),
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

  _userLogout() {
    Authentication().signOut();
    Navigator.of(context).pop();
  }
}
