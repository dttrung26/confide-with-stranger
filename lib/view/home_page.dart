import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confide_with_stranger/service/auth.dart';
import 'package:confide_with_stranger/service/firestore_database.dart';
import 'package:confide_with_stranger/view/chat.dart';
import 'package:confide_with_stranger/view/signin.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../extension/cache_helper.dart';
import '../model/user_model.dart';
import '../widget/common_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreDatabase _firebaseFirestore = FirestoreDatabase();
  final Stream<QuerySnapshot> _chatListStream =
      FirebaseFirestore.instance.collection('rooms').snapshots();
  String currentUserId = '';
  @override
  void initState() {
    //Check signIn status, navigate to login screen if user has not signed in
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
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatListStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  return ListView(
                    children: snapshot.data!.docs
                        .map((DocumentSnapshot documentSnapShot) {
                          //Get peerUserId
                          List<String> userIdsList =
                              List<String>.from(documentSnapShot.get('users'));
                          String peerUserId;
                          //users array only contains 2 values: currentUserId and peerUserId
                          peerUserId = userIdsList
                              .firstWhere((id) => id != currentUserId);

                          return FutureBuilder(
                              future:
                                  _firebaseFirestore.getUserByUid(peerUserId),
                              builder: (BuildContext context,
                                  AsyncSnapshot<UserModel?> peerUserSnapShot) {
                                if (snapshot.hasError) {
                                  return const Text('Something went wrong');
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                return _buildChatItem(
                                    documentSnapShot, peerUserSnapShot.data);
                              });
                        })
                        .toList()
                        .cast(),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(DocumentSnapshot snapshot, UserModel? peerUser) {
    Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
    if (peerUser != null) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                currentUserId: currentUserId,
                peerUser: peerUser,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Card(
            color: Theme.of(context).bottomAppBarColor,
            elevation: 1.5,
            child: ListTile(
              contentPadding: const EdgeInsets.only(
                  top: 10, bottom: 10, left: 20.0, right: 10.0),
              // trailing: unread > 0
              //     ? Container(
              //         width: 20,
              //         height: 20,
              //         decoration: BoxDecoration(
              //             color: Theme.of(context).primaryColor,
              //             borderRadius: BorderRadius.circular(10)),
              //         child: Center(
              //           child: Text(
              //             '$unread',
              //             style: const TextStyle(
              //                 fontSize: 11, color: Colors.white),
              //           ),
              //         ),
              //       )
              //     : null,
              leading: Image.network('${peerUser.profilePicture}'),
              title: Row(
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: Text(
                      peerUser.displayName,
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      data['last_message_time'],
                      style: DefaultTextStyle.of(context).style.copyWith(
                          fontStyle: FontStyle.italic, fontSize: 10.0),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              //TODO: replace user typing here
              subtitle: false
                  ? Text(
                      'user is typing here',
                      style: DefaultTextStyle.of(context).style.copyWith(
                          fontStyle: FontStyle.italic, fontSize: 12.0),
                      overflow: TextOverflow.fade,
                    )
                  : Text(
                      data['last_message'],
                      style: DefaultTextStyle.of(context).style,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
              dense: true,
              //TODO: replace isSeen here
              enabled: false,
            ),
          ),
        ),
      );
    } else {
      return Text("Can't build chat item");
    }
  }

  void _checkSignedIn() async {
    bool isSignedIn = await CacheHelper().getUserLoggedInStatus() ?? false;
    if (!isSignedIn) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignIn()),
          (route) => false);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currentUserId = (await CacheHelper().getCurrentUserId())!;
    }
  }

  _userLogout() {
    Authentication().signOut();
    Navigator.of(context).canPop() ? Navigator.of(context).pop() : null;
  }
}
