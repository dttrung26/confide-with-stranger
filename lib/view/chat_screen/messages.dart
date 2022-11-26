import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageStream extends StatefulWidget {
  final String chatRoomId;
  const MessageStream({Key? key, required this.chatRoomId}) : super(key: key);

  @override
  State<MessageStream> createState() => _MessageStreamState();
}

class _MessageStreamState extends State<MessageStream> {
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> messagesStream = FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: messagesStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: snapshot.data?.docs.length,
          itemBuilder: (context, index) => Text(
            snapshot.data?.docs[index].get('content'),
          ),
        );
      },
    );
  }
}
