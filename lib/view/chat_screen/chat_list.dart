import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confide_with_stranger/widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../extension/date_time_helper.dart';
import '../../model/chat_user.dart';
import '../../model/user_model.dart';
import '../../service/firestore_database.dart';
import 'chat.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final _firebaseFirestore = FirestoreDatabase();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserModel>(context, listen: false).user;
    final chatListStream = FirebaseFirestore.instance
        .collection('rooms')
        .where('users', arrayContains: currentUser?.uid)
        .snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: chatListStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Snapshot has error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData) {
          return const Text("No history chat");
        }
        return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              List userIdList = snapshot.data?.docs[index].get('users');
              var peerUserId =
                  userIdList.firstWhere((userId) => userId != currentUser?.uid);
              return FutureBuilder(
                  future: _firebaseFirestore.getUserByUid(uid: peerUserId),
                  builder: (BuildContext context,
                      AsyncSnapshot<ChatUser?> peerUserSnapShot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    return _buildChatItem(
                        snapshot.data?.docs[index].data()
                            as Map<String, dynamic>,
                        peerUserSnapShot.data,
                        currentUser);
                  });
            });
      },
    );
  }

  Widget _buildChatItem(
      Map<String, dynamic> data, ChatUser? peerUser, ChatUser? currentUser) {
    if (peerUser != null) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                peerUser: peerUser,
                currentUser: currentUser!,
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
              leading:
                  CircleUserAvatar(userProfileUrl: peerUser.profilePicture),
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
                      DateTimeHelper.formatStringDateTime(
                          data['last_message_time']),
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
      return const Text("Can't build chat item");
    }
  }
}
