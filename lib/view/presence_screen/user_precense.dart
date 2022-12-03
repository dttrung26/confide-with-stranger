import 'package:confide_with_stranger/service/firestore_database.dart';
import 'package:confide_with_stranger/view/chat_screen/chat.dart';
import 'package:flutter/material.dart';

import '../../extension/cache_helper.dart';
import '../../model/user_model.dart';
import '../../widget/common_widget.dart';

class UserPresence extends StatefulWidget {
  const UserPresence({Key? key}) : super(key: key);

  @override
  State<UserPresence> createState() => _UserPresenceState();
}

class _UserPresenceState extends State<UserPresence>
    with WidgetsBindingObserver {
  String? currentUserId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    CacheHelper().getCurrentUserId().then((value) {
      if (value != null) {
        currentUserId = value;
        FirestoreDatabase().setUserPresenceStatus(currentUserId!, true);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //User goes offline
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      FirestoreDatabase().setUserPresenceStatus(currentUserId!, false);
    }
    //User goes online
    if (state == AppLifecycleState.resumed) {
      FirestoreDatabase().setUserPresenceStatus(currentUserId!, true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          children: [
            Text(currentUserId!),

            SizedBox(
              height: 100,
              width: 300,
              child: FutureBuilder<UserModel?>(
                  future: FirestoreDatabase()
                      .getOnlineUserPresence(10, currentUserId!),
                  builder: (BuildContext context,
                      AsyncSnapshot<UserModel?> userSnapshot) {
                    if (userSnapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    return OutlineButton(
                        text: "${userSnapshot.data?.toString()}",
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                  currentUserId: currentUserId!,
                                  peerUser: userSnapshot.data!),
                            ),
                          );
                        });
                  }),
            ),
            // LoadingAnimatedButton(
            //   onTap: () {},
            //   onTapChild: const Text("Finding ..."),
            //   child: const Text("Finding a stranger"),
            // ),
          ],
        ),
      ),
    );
  }
}
