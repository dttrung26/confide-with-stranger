import 'package:confide_with_stranger/service/auth.dart';
import 'package:confide_with_stranger/view/authentication_screen/signin.dart';
import 'package:confide_with_stranger/view/presence_screen/user_precense.dart';
import 'package:confide_with_stranger/view/search_screen/search_screen.dart';
import 'package:confide_with_stranger/view/settings_screen/settings_screen.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../widget/common_widget.dart';
import 'chat_screen/chat_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(
        title: "CFWSTR",
        context: context,
        actions: [
          IconButton(
            onPressed: () {
              _userLogout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const UserPresence(),
          const ChatList(),
          const SearchScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _customTabbar(),
    );
  }

  void _userLogout() async {
    await Authentication().signOut();
    Navigator.of(context).canPop()
        ? Navigator.of(context).pop()
        : Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const SignIn(),
            ),
            (route) => false);
  }

  Widget _customTabbar() {
    return CustomNavigationBar(
      iconSize: 30.0,
      selectedColor: Colors.white,
      strokeColor: Colors.white,
      unSelectedColor: Color(0xff6c788a),
      backgroundColor: Color(0xff040307),
      items: [
        CustomNavigationBarItem(
          icon: const Icon(Icons.home),
        ),
        CustomNavigationBarItem(
          icon: const Icon(Icons.chat_bubble),
        ),
        CustomNavigationBarItem(
          icon: const Icon(Icons.search),
        ),
        CustomNavigationBarItem(
          icon: const Icon(Icons.account_circle),
        ),
      ],
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}
