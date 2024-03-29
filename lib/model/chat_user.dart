import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  String uid;
  String displayName;
  String email;
  String profilePicture;
  String createdAt;
  String? lastSeen;
  bool isOnline;

  ChatUser(
      {required this.uid,
      required this.displayName,
      required this.email,
      required this.profilePicture,
      required this.createdAt,
      required this.isOnline,
      this.lastSeen});

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'display_name': displayName,
      'email': email,
      'profile_picture': profilePicture,
      'uid': uid,
      'last_seen': lastSeen,
      'is_online': isOnline
    };
  }

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      uid: json['uid'],
      displayName: json['display_name'],
      email: json['email'],
      profilePicture: json['profile_picture'],
      createdAt: json['created_at'],
      lastSeen: json['last_seen'],
      isOnline: json['is_online'],
    );
  }

  factory ChatUser.fromDocumentSnapshot(DocumentSnapshot doc) {
    return ChatUser(
        profilePicture: doc.get('profile_picture'),
        createdAt: doc.get('created_at'),
        displayName: doc.get('display_name'),
        uid: doc.get('uid'),
        isOnline: doc.get('is_online'),
        email: doc.get('email'),
        lastSeen: doc.get('last_seen'));
  }

  @override
  String toString() {
    // TODO: implement toString
    return "UserModel: $displayName + $uid";
  }
}
