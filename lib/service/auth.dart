import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../extension/cache_helper.dart';
import '../extension/logs.dart';
import '../model/chat_user.dart';
import 'firestore_database.dart';

enum Status {
  authenticated,
  authenticating,
  authenticationError,
  authenticationCancelled,
}

class Authentication {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  Future<bool> signInByGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    //Get googleAuth Credential by Google Login
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Login with firebaseAuth by googleAuth Credential
      User? firebaseUser =
          (await _firebaseAuth.signInWithCredential(credential)).user;
      if (firebaseUser != null) {
        final QuerySnapshot result = await _firebaseFirestore
            .collection("users")
            .where("uid", isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.isEmpty) {
          //When user has valid credential but query snapshot from firebase is null,
          // then write new user data in firebase firestore
          _firebaseFirestore.collection("users").doc(firebaseUser.uid).set({
            "display_name": firebaseUser.displayName,
            "profile_picture": firebaseUser.photoURL,
            "uid": firebaseUser.uid,
            "created_at": DateTime.now().toString(),
            "email": firebaseUser.email,
            "is_online": true,
            "last_seen": null
          });
          //Get user fromfirebase firestore
          final docRef =
              _firebaseFirestore.collection("users").doc(firebaseUser.uid);
          docRef.get().then((DocumentSnapshot doc) {
            final data = doc.data() as Map<String, dynamic>;
            ChatUser user = ChatUser.fromJson(data);
            //Save user data to local cache
            CacheHelper().saveUserData(user);
          });
          await CacheHelper().setUserLoggedInStatus(true);
          // //Otherwise, user has valid credential and valid query snapshot
          // //Then get user data from firebase firestore
          // DocumentSnapshot documentSnapshot = documents[0];
          // UserModel user = UserModel.fromJson(
          //     documentSnapshot.data() as Map<String, dynamic>);
          // //Then write user data on local cache
          // CacheHelper().saveUserData(user);
          return true;
        } else {
          //Fail with query in firebase firestore
          return false;
        }
      } else {
        // Fail with google sign in
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> signUpWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      var firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // If user sign up successfully, write user data on firebase firestore
        await _firebaseFirestore.collection('users').doc(firebaseUser.uid).set({
          "display_name": displayName,
          "profile_picture":
              'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png',
          "uid": firebaseUser.uid,
          "created_at": DateTime.now().toString(),
          "email": firebaseUser.email,
          "is_online": true,
          "last_seen": null
        });
        // Then get user data from firebase firestore
        final docRef =
            _firebaseFirestore.collection("users").doc(firebaseUser.uid);
        docRef.get().then((DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          ChatUser user = ChatUser.fromJson(data);
          // Save user data on local cache
          CacheHelper().saveUserData(user);
        });
        await CacheHelper().setUserLoggedInStatus(true);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      printLog(e);
      throw ("Error on creating new account");
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      //Attempt to login by firebase authentication
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        // if successful, get user data from firestore firebase
        final docSnapshot = await _firebaseFirestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        final data = docSnapshot.data() as Map<String, dynamic>;
        ChatUser user = ChatUser.fromJson(data);
        // then save user data in local cache
        CacheHelper().saveUserData(user);
        CacheHelper().setUserLoggedInStatus(true);
        return true;
      } else {
        return false;
      }
    } catch (err) {
      printLog(err);
      rethrow;
    }
  }

  Future<void> signOut() async {
    //Set user status to offline
    await FirestoreDatabase()
        .setUserPresenceStatus(_firebaseAuth.currentUser!.uid, false);
    //Sign out user from Firebase
    await _firebaseAuth.signOut();
    //Delete user cache
    await CacheHelper().setUserLoggedInStatus(false);
  }
}
