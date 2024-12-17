import 'package:chatapp/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class FriendScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Scaffold(body: Center(child: Text('Vui lòng đăng nhập!')));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2979FF),
        title: const Text(
          'Danh sách bạn bè',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            );
          },
          icon: const Icon(
            Icons.arrow_back_sharp,
            size: 33,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Không có bạn bè nào.'));
          }

          final friendsUIDs = List<String>.from(snapshot.data!['friends'] ?? []);

          return FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait(
              friendsUIDs.map(
                    (uid) => FirebaseFirestore.instance.collection('users').doc(uid).get(),
              ),
            ),
            builder: (context, friendsSnapshot) {
              if (friendsSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!friendsSnapshot.hasData || friendsSnapshot.data!.isEmpty) {
                return Center(child: Text('Không có bạn bè nào.'));
              }

              final friends = friendsSnapshot.data!;

              return ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    child: ListTile(
                      title: Text(friend['username']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              friendUID: friend.id,
                              friendName: friend['username'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}