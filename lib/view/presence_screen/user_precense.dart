import 'package:confide_with_stranger/constants/app_constants.dart';
import 'package:confide_with_stranger/service/firestore_database.dart';
import 'package:confide_with_stranger/view/chat_screen/chat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../extension/cache_helper.dart';
import '../../model/chat_user.dart';
import '../../model/user_model.dart';
import '../../widget/common_widget.dart';

class UserPresence extends StatefulWidget {
  const UserPresence({Key? key}) : super(key: key);

  @override
  State<UserPresence> createState() => _UserPresenceState();
}

class _UserPresenceState extends State<UserPresence>
    with WidgetsBindingObserver {
  ChatUser? get currentUser =>
      Provider.of<UserModel>(context, listen: false).user;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    CacheHelper().getCurrentUserId().then((value) {
      if (value != null) {
        FirestoreDatabase().setUserPresenceStatus(currentUser!.uid, true);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //User goes offline
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      FirestoreDatabase().setUserPresenceStatus(currentUser!.uid, false);
    }

    //User goes online
    if (state == AppLifecycleState.resumed) {
      FirestoreDatabase().setUserPresenceStatus(currentUser!.uid, true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    ChatUser? currentUser = Provider.of<UserModel>(context, listen: false).user;
    Future<ChatUser?> chatUserFuture =
        FirestoreDatabase().getOnlineUserPresence(10, currentUser!.uid);
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            // Text(currentUser.toString()),
            SizedBox(
              height: 100,
              width: 300,
              child: FutureBuilder<ChatUser?>(
                  future: chatUserFuture,
                  builder: (BuildContext context,
                      AsyncSnapshot<ChatUser?> userSnapshot) {
                    if (userSnapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    return Column(
                      children: [
                        userSnapshot.data?.uid == adminUid
                            ? const Text(
                                "No online users for now. Let's talk with admin")
                            : const SizedBox.shrink(),
                        OutlineButton(
                            text: "Let's chat!",
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                      currentUser: currentUser,
                                      peerUser: userSnapshot.data!),
                                ),
                              );
                            }),
                      ],
                    );
                  }),
            ),
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              height: 75,
              width: 300,
              child: OutlineButton(
                onPressed: () {
                  //Reset Begin to talk button
                  setState(() {
                    chatUserFuture = FirestoreDatabase()
                        .getOnlineUserPresence(10, currentUser.uid);
                  });
                },
                text: 'Find again',
              ),
            )
          ],
        ),
      ),
    );
  }
}
