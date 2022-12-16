import 'package:confide_with_stranger/model/chat_user.dart';
import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  late ChatUser _user;

  ChatUser? get user => _user;

  void updateUser(ChatUser user) {
    _user = user;
    notifyListeners();
  }
}
