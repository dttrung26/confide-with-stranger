class UserModel {
  String uid;
  String displayName;
  String email;
  String? profilePicture;
  String createdAt;

  UserModel(
      {required this.uid,
      required this.displayName,
      required this.email,
      this.profilePicture,
      required this.createdAt});

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'display_name': displayName,
      'email': email,
      'profile_picture': profilePicture,
      'uid': uid
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        uid: json['uid'],
        displayName: json['display_name'],
        email: json['email'],
        profilePicture: json['profile_picture'],
        createdAt: json['created_at']);
  }
}
