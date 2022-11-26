import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confide_with_stranger/extension/logs.dart';

import '../model/user_model.dart';

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

  Future<UserModel?> getUserByUid(String uid) async {
    final docRef = _firebaseFirestore.collection("users").doc(uid);
    try {
      DocumentSnapshot doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;
      UserModel user = UserModel.fromJson(data);
      return user;
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
