import 'package:shared_preferences/shared_preferences.dart';

import '../model/user_model.dart';

class CacheHelper {
  static String userLoggedInKey = "CFWSTR_USER_LOGGED_IN_KEY";
  static String userNameKey = "CFWSTR_USER_NAME_KEY";
  static String userEmailKey = "CFWSTR_USER_EMAIL_KEY";
  static String userProfilePicture = "CFWSTR_USER_PROFILE_PICTURE_KEY";

  //Save logged in user in SF
  Future<void> setUserLoggedInStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(userLoggedInKey, value);
  }

  //Get logged in user from SF
  Future<bool?> getUserLoggedInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // If user logged in, return true. Return false if otherwise
    return prefs.getBool(userLoggedInKey) ?? false;
  }

  Future<void> saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userNameKey, user.displayName);
    await prefs.setString(userEmailKey, user.email);
    //TODO: profile picture must be handled
    await prefs.setString(userProfilePicture, user.profilePicture!);
  }
}
