import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'chat_list_screen.dart';
import 'friend_screen.dart';
import 'tweet_screen.dart';
import 'me_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    ChatListScreen(),
    FriendScreen(),
    TweetScreen(),
    MeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.chat, color: Color(0xFF2979FF)), label: 'Nhắn tin'),
          BottomNavigationBarItem(icon: Icon(Icons.people, color: Color(0xFF2979FF)), label: 'Bạn bè'),
          BottomNavigationBarItem(icon: Icon(Icons.article, color: Color(0xFF2979FF)), label: 'Nhật kí'),
          BottomNavigationBarItem(icon: Icon(Icons.person, color: Color(0xFF2979FF)), label: 'Người dùng'),
        ],
        selectedItemColor: Color(0xFF2979FF),
        unselectedItemColor: Color(0xFF2979FF),
        selectedLabelStyle: TextStyle(color: Color(0xFF2979FF), fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(color: Color(0xFF2979FF), fontWeight: FontWeight.bold),
      ),
    );
  }
}