import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confide_with_stranger/extension/logs.dart';

import '../model/chat_user.dart';

class FirestoreDatabase {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> sendMessage({
    required message,
    required docId,
    required senderId,
  }) async {
    _firebaseFirestore
        .collection('rooms')
        .doc(docId)
        .collection('messages')
        .add({
      'content': message,
      'from': senderId,
      'time': DateTime.now().toString(),
    });
  }

  Future<void> updateAdditionalUsersData({
    required String currentUserId,
    required String peerUserId,
    required String docId,
  }) async {
    _firebaseFirestore.collection('rooms').doc(docId).update({
      'users': [currentUserId, peerUserId],
    });
  }

  Future<void> updateAdditionalChatData(
      {required String lastMessage, required String docId}) async {
    _firebaseFirestore.collection('rooms').doc(docId).update({
      'last_message': lastMessage,
      'last_message_time': DateTime.now().toString(),
    });
  }

  Future<void> setAdditionalChatData(
      {required docId,
      required currentUserId,
      required peerUserId,
      required lastMessage}) async {
    _firebaseFirestore.collection('rooms').doc(docId).set({
      'users': [currentUserId, peerUserId],
      'last_message': lastMessage,
      'last_message_time': DateTime.now().toString(),
    });
  }

  Future<ChatUser?> getUserByUid({required String uid}) async {
    final docRef = _firebaseFirestore.collection("users").doc(uid);
    try {
      DocumentSnapshot doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;
      ChatUser user = ChatUser.fromJson(data);
      return user;
    } catch (e) {
      printLog(e);
      return null;
    }
  }

  Future<void> setUserPresenceStatus(String userId, bool isOnline) async {
    return await _firebaseFirestore.collection('users').doc(userId).update({
      "is_online": isOnline,
      //only set current datetime value for "last_seen" if users go offline
      "last_seen": isOnline ? null : DateTime.now().toString(),
    });
  }

//Return a random online user who is not current user
  Future<ChatUser?> getOnlineUserPresence(
      int limit, String currentUserId) async {
    //Replace default admin uid here if needed
    String defaultAdminUid = 'WxiNPb8nhKMqscq8l1FLxOiBi7P2';
    final docRef = _firebaseFirestore
        .collection('users')
        .limit(limit)
        .where('is_online', isEqualTo: true);
    try {
      final value = await docRef.get();
      if (value.docs.length == 1) {
        //If the only 1 online user   is the person who is using the app
        //Then, user should chat with default account of this app developer
        final docRef = _firebaseFirestore
            .collection('users')
            .where('uid', isEqualTo: defaultAdminUid);
        final value = await docRef.get();
        return ChatUser.fromJson(value.docs.first.data());
      } else {
        int randomUserIndex = Random().nextInt(value.docs.length);
        int currentUserIndex = value.docs
            .indexWhere((element) => element.data()['uid'] == currentUserId);
        //if random user index is equal to current user index
        while (currentUserIndex == randomUserIndex) {
          //get a new random user index
          randomUserIndex = Random().nextInt(value.docs.length);
        }
        return ChatUser.fromJson(value.docs.elementAt(randomUserIndex).data());
      }
    } catch (e) {
      printLog(e);
      return null;
    }
  }

  // Future setUserData(User? user) async {
  //   try {
  //     if (user != null) {
  //       var displayName = user.firstName! + user.lastName!;
  //       await _fireStoreDatabase.collection("users").doc(user.userId).set({
  //         "display_name": displayName,
  //         "email": user.email,
  //         "first_name": user.firstName,
  //         "last_name": user.lastName,
  //         "profile_picture": user.profilePicUrl ?? "",
  //         "uid": user.userId,
  //       });
  //     }
  //   } catch (e) {
  //     printLog("Error: $e");
  //     rethrow;
  //   }
  // }
  //
  // Future<User?> getUserData(String? uid) async {
  //   try {
  //     final docRef = _fireStoreDatabase.collection("users").doc(uid);
  //     docRef.get().then(
  //       (DocumentSnapshot doc) {
  //         final data = doc.data() as Map<String, dynamic>;
  //         return User.fromFirebaseUser(data);
  //       },
  //       onError: (e) => print("Error getting document: $e"),
  //     );
  //   } catch (e) {
  //     printLog("Error: $e");
  //     rethrow;
  //   }
  //   return null;
  // }
}
