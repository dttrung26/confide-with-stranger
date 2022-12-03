import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confide_with_stranger/extension/date_time_helper.dart';
import 'package:firestore_ui/firestore_ui.dart';
import 'package:flutter/material.dart';

class MessageStream extends StatefulWidget {
  final String chatRoomId;
  final String currentUserId;
  const MessageStream(
      {Key? key, required this.chatRoomId, required this.currentUserId})
      : super(key: key);

  @override
  State<MessageStream> createState() => _MessageStreamState();
}

class _MessageStreamState extends State<MessageStream> {
  @override
  Widget build(BuildContext context) {
    final messagesStream = FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .orderBy('time');
    return FirestoreAnimatedList(
        query: messagesStream,
        itemBuilder: (context, snapshot, animation, index) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
            child: MessageBubble(
              index: index,
              document: snapshot,
              isMe: widget.currentUserId == snapshot!['from'],
            ),
          );
        });
    // return StreamBuilder<QuerySnapshot>(
    //   stream: messagesStream,
    //   builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    //     if (snapshot.hasError) {
    //       return const Text('Something went wrong');
    //     }
    //
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const CircularProgressIndicator();
    //     }
    //
    //     return ListView.builder(
    //       scrollDirection: Axis.vertical,
    //       shrinkWrap: true,
    //       itemCount: snapshot.data?.docs.length,
    //       itemBuilder: (context, index) => Text(
    //         snapshot.data?.docs[index].get('content'),
    //       ),
    //     );
    //   },
    // );
  }
}

class MessageBubble extends StatelessWidget {
  final int? index;
  final DocumentSnapshot? document;
  final bool? isMe;

  const MessageBubble({this.index, this.document, this.isMe});

  @override
  Widget build(BuildContext context) {
    var data = document!.data() as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
      child: Row(
        children:
            isMe! ? displayMyMessage(context) : displaySenderMessage(context),
      ),
    );
  }

  List<Widget> displaySenderMessage(context) {
    var theme = Theme.of(context);
    var data = document!.data()! as Map<String, dynamic>;

    return <Widget>[
      Expanded(
        flex: 7,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                DateTimeHelper.formatStringDateTime(data['time']),
                style: theme.textTheme.headline6!.copyWith(
                    fontSize: 10,
                    color: theme.colorScheme.secondary.withOpacity(0.5)),
              ),
              const SizedBox(
                height: 5.0,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0),
                  child: Text(
                    '${data['content']}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      const Expanded(
        flex: 3,
        child: SizedBox(
          width: 0,
          height: 0,
        ),
      )
    ];
  }

  List<Widget> displayMyMessage(context) {
    var theme = Theme.of(context);
    var data = document!.data()! as Map<String, dynamic>;

    return <Widget>[
      const Expanded(
        flex: 3,
        child: SizedBox(
          width: 0,
          height: 0,
        ),
      ),
      Expanded(
        flex: 7,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              //in user chat screen, do not display user email, only display admin email
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Text(
                  DateTimeHelper.formatStringDateTime(data['time']),
                  style: theme.textTheme.headline6!.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.secondary.withOpacity(0.5)),
                ),
              ),

              const SizedBox(
                height: 5.0,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(5.0),
                    )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0),
                  child: Text(
                    '${data['content']}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ];
  }
}
