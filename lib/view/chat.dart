import 'package:confide_with_stranger/view/chat_screen/messages.dart';
import 'package:flutter/material.dart';

import '../model/user_model.dart';
import '../service/firestore_database.dart';

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
  String chatRoomId =
      'WxiNPb8nhKMqscq8l1FLxOiBi7P2-Y0aVHp3JeCeh623XSbLQMQZ0tas2';
  @override
  void initState() {
    //TODO: disable for testing for now, enable later
    //Compare string order of two users id to generate a unique chat room id
    // if (widget.currentUserId.compareTo(widget.peerUser.uid) > 0) {
    //   chatRoomId = '${widget.peerUser.uid}-${widget.currentUserId}';
    // } else {
    //   chatRoomId = '${widget.currentUserId}-${widget.peerUser.uid}';
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                      onEditingComplete: () {},
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
