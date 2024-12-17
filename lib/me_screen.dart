import 'package:chatapp/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2979FF),
        title: const Text(
          'Người dùng',
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
        actions: [
          IconButton(
            onPressed: () {
              _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => WelcomeScreen(),
                ),
              );
            },
            icon: Icon(Icons.logout),
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder(
              stream: _firestore.collection('users').doc(_auth.currentUser!.uid).snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                var userData = snapshot.data!.data() as Map<String, dynamic>;
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tên người dùng:', style: TextStyle(fontSize: 18)),
                      Text('${userData['username']}', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                      Text('Số điện thoại: ${userData['phone']}', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Các bài đăng của bạn:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('tweets').where('uid', isEqualTo: _auth.currentUser!.uid).orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Chưa có bài đăng nào.'));
                }

                final tweets = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: tweets.length,
                  itemBuilder: (context, index) {
                    final tweet = tweets[index];
                    final content = tweet['content'];
                    final likes = List<String>.from(tweet['likes']);
                    final comments = List<Map<String, dynamic>>.from(tweet['comments']);
                    final username = tweet['username'];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          username,  // Username of the post
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Post content
                            Text(content),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.favorite_border),
                                SizedBox(width: 4),
                                Text('${likes.length} Thích'),
                                SizedBox(width: 16),
                                Icon(Icons.comment),
                                SizedBox(width: 4),
                                Text('${comments.length} Bình luận'),
                              ],
                            ),
                            SizedBox(height: 8),
                            // Displaying comments
                            if (comments.isNotEmpty)
                              Column(
                                children: comments.map((comment) {
                                  return ListTile(
                                    title: Text(
                                      comment['username'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(comment['comment']),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}