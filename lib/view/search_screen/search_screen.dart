import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../extension/debouncer.dart';
import '../../model/chat_user.dart';
import '../../service/firestore_database.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchQueryStream = StreamController<String>();
  Debouncer searchDebouncer = Debouncer(milliseconds: 500);
  StreamController<bool> clearButtonController = StreamController<bool>();
  TextEditingController searchBarTextController = TextEditingController();
  String _searchText = "";
  final ScrollController listScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        searchBar(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirestoreDatabase()
                .searchUserByDisplayName(limit: 1, searchText: _searchText),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator());
              }

              if ((snapshot.data?.docs.length ?? 0) > 0) {
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) =>
                      buildUserItem(snapshot.data?.docs[index]),
                  itemCount: snapshot.data?.docs.length,
                  controller: listScrollController,
                );
              } else {
                return const Center(
                  child: Text("No users"),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget searchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 20),
          const SizedBox(width: 5),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.search,
              controller: searchBarTextController,
              onChanged: (value) {
                searchDebouncer.run(() {
                  if (value.isNotEmpty) {
                    //Enable "X" clear button
                    clearButtonController.add(true);
                    setState(() {
                      _searchText = value;
                    });
                  } else {
                    //Disable "X" clear button
                    clearButtonController.add(false);
                    setState(() {
                      _searchText = "";
                    });
                  }
                });
              },
              decoration: const InputDecoration.collapsed(
                hintText: 'Search nickname (you have to type exactly string)',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          StreamBuilder<bool>(
              stream: clearButtonController.stream,
              builder: (context, snapshot) {
                return snapshot.data == true
                    ? GestureDetector(
                        onTap: () {
                          //Clear input from Search Bar
                          searchBarTextController.clear();
                          //Disable "X" clear button
                          clearButtonController.add(false);
                          //Reset _searchText
                          setState(() {
                            _searchText = "";
                          });
                        },
                        child: const Icon(Icons.clear_rounded,
                            color: Colors.grey, size: 20))
                    : const SizedBox.shrink();
              }),
        ],
      ),
    );
  }

  Widget buildUserItem(DocumentSnapshot? doc) {
    if (doc == null) {
      return const SizedBox.shrink();
    } else {
      ChatUser user = ChatUser.fromDocumentSnapshot(doc);
      return Container(
        margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
        child: TextButton(
          onPressed: () {
            ///TODO: move to Chat Screen with this user
          },
          child: Row(
            children: <Widget>[
              Material(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                clipBehavior: Clip.hardEdge,
                child: user.profilePicture.isNotEmpty
                    ? Image.network(
                        user.profilePicture,
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                      )
                    : const Icon(Icons.account_box_outlined,
                        size: 50, color: Colors.grey),
              ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Column(
                    children: <Widget>[
                      Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Name: ${user.displayName}",
                                maxLines: 1,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 13),
                              ),
                              Text(
                                'Email: ${user.email}',
                                maxLines: 1,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 13),
                              ),
                              user.isOnline
                                  ? const Text("Online",
                                      style: TextStyle(color: Colors.green))
                                  : Text(
                                      'Last seen: ${DateFormat('h:mm a - d/M').format(DateTime.parse(user.lastSeen!))}')
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
