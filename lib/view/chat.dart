import 'package:flutter/material.dart';

import '../model/user_model.dart';
import '../service/firestore_database.dart';

//Default owner uid: jdEzxGaMOwZwvx67zswKTSW2Dqw1

class ChatScreen extends StatefulWidget {
  final UserModel senderUser;
  final String? receiverId;
  const ChatScreen({Key? key, required this.senderUser, this.receiverId})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final firebaseFireStore = FirestoreDatabase();
  String messagesText = '';

  @override
  Widget build(BuildContext context) {
    //TODO: replace receiverId
    String docId = '${widget.senderUser.uid}-jdEzxGaMOwZwvx67zswKTSW2Dqw1';

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
                        //TODO: Send Message
                        firebaseFireStore.sendMessage(
                            message: messagesText,
                            docId: docId,
                            senderId: widget.senderUser.uid,
                            receiverId: widget.receiverId);
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
