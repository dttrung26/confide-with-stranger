import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDatabase {
  final FirebaseFirestore _fireStoreDatabase = FirebaseFirestore.instance;

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
