import 'package:confide_with_stranger/view/chat_screen/messages.dart';
import 'package:confide_with_stranger/widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/user_model.dart';
import '../../service/firestore_database.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final UserModel peerUser;
  const ChatScreen(
      {Key? key, required this.currentUserId, required this.peerUser})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final firebaseFireStore = FirestoreDatabase();
  String messagesText = '';
  String chatRoomId = '';
  //     'WxiNPb8nhKMqscq8l1FLxOiBi7P2-Y0aVHp3JeCeh623XSbLQMQZ0tas2';

  @override
  void initState() {
    //Compare string order of two users id to generate a unique chat room id
    if (widget.currentUserId.compareTo(widget.peerUser.uid) > 0) {
      chatRoomId = '${widget.peerUser.uid}-${widget.currentUserId}';
    } else {
      chatRoomId = '${widget.currentUserId}-${widget.peerUser.uid}';
    }
    //Set additional users data in chat room
    firebaseFireStore.setAdditionalUsersData(
        currentUserId: widget.currentUserId,
        peerUserId: widget.peerUser.uid,
        docId: chatRoomId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isOnline = widget.peerUser.isOnline;
    String dateFormat = '';
    if (widget.peerUser.lastSeen != null) {
      var lastSeenDate = DateTime.parse(widget.peerUser.lastSeen!).toLocal();
      DateTime.parse(widget.peerUser.lastSeen!).toLocal();
      var isRecent = DateTime.now().difference(lastSeenDate).inHours < 24;
      dateFormat = isRecent
          ? DateFormat('h:mm a').format(lastSeenDate)
          : DateFormat('h:mm a - d/M').format(lastSeenDate);
    }
    String userPresenceStatus =
        isOnline ? 'Online' : "Last seen at $dateFormat";

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.peerUser.displayName),
            Text(userPresenceStatus)
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircleUserAvatar(
              userProfileUrl: widget.peerUser.profilePicture,
              width: 40,
            ),
          )
        ],
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Scrollbar(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: MessageStream(
                  chatRoomId: chatRoomId,
                  currentUserId: widget.currentUserId,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messagesText = value;
                      },
                      onEditingComplete: () {
                        //TODO: adjust on editing complete
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        hintText: "Message",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      if (messagesText.isNotEmpty) {
                        firebaseFireStore.sendMessage(
                            message: messagesText,
                            docId: chatRoomId,
                            senderId: widget.currentUserId);
                        firebaseFireStore.setAdditionalChatItemData(
                            lastMessage: messagesText, docId: chatRoomId);
                      }
                      messagesText = '';
                    },
                    child: const Text(
                      'Send',
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
