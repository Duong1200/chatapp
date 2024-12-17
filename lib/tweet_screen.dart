import 'package:chatapp/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TweetScreen extends StatefulWidget {
  @override
  _TweetScreenState createState() => _TweetScreenState();
}

class _TweetScreenState extends State<TweetScreen> {
  final _tweetController = TextEditingController();
  bool _isLoading = false;

  Future<void> _postTweet() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String username = userDoc['username'] ?? 'User';

      await FirebaseFirestore.instance.collection('tweets').add({
        'content': _tweetController.text,
        'uid': user.uid,
        'username': username,
        'createdAt': Timestamp.now(),
        'likes': [],
        'comments': [],
      });

      _tweetController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng bài thất bại: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2979FF),
        title: const Text(
          'Nhật kí',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tweetController,
              decoration: InputDecoration(
                hintText: 'Bạn đang nghĩ gì...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _postTweet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2979FF), // Nền xanh dương
                minimumSize: Size(double.infinity, 50), // Độ dài nút bằng TextField
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Đăng bài',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('tweets').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Chưa có bài viết nào.'));
                  }

                  final tweets = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: tweets.length,
                    itemBuilder: (context, index) {
                      final tweet = tweets[index];
                      final tweetId = tweet.id;
                      final content = tweet['content'];
                      final likes = List<String>.from(tweet['likes']);
                      final comments = List<Map<String, dynamic>>.from(tweet['comments']);
                      final username = tweet['username'];
                      final hasLiked = likes.contains(FirebaseAuth.instance.currentUser!.uid);

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Stack(
                          children: [
                            ListTile(
                              title: Text(
                                username,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(content),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          hasLiked ? Icons.favorite : Icons.favorite_border,
                                          color: hasLiked ? Colors.red : null,
                                        ),
                                        onPressed: () => _likeTweet(tweetId, likes),
                                      ),
                                      Text('${likes.length} Thích'),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Bình luận',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  SizedBox(height: 10),
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
                                  TextField(
                                    decoration: InputDecoration(hintText: 'Bình luận...'),
                                    onSubmitted: (value) => _addComment(tweetId, value),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editTweet(tweetId, content);
                                  } else if (value == 'delete') {
                                    _deleteTweet(tweetId);
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Text('Chỉnh sửa'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Xoá'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _likeTweet(String tweetId, List likes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final hasLiked = likes.contains(user.uid);
    if (hasLiked) {
      await FirebaseFirestore.instance.collection('tweets').doc(tweetId).update({
        'likes': FieldValue.arrayRemove([user.uid]),
      });
    } else {
      await FirebaseFirestore.instance.collection('tweets').doc(tweetId).update({
        'likes': FieldValue.arrayUnion([user.uid]),
      });
    }
  }

  Future<void> _addComment(String tweetId, String comment) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String username = userDoc['username'] ?? 'User';
      await FirebaseFirestore.instance.collection('tweets').doc(tweetId).update({
        'comments': FieldValue.arrayUnion([
          {'uid': user.uid, 'comment': comment, 'username': username, 'createdAt': Timestamp.now()}
        ]),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bình luận thất bại: $e')),
    );
  }
  }

  Future<void> _editTweet(String tweetId, String oldContent) async {
    TextEditingController _editController = TextEditingController(text: oldContent);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chỉnh sửa bài viết'),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(
              hintText: 'Nhập nội dung mới...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                String newContent = _editController.text.trim();
                if (newContent.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('tweets').doc(tweetId).update({
                    'content': newContent,
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Nội dung không thể để trống')),
                  );
                }
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTweet(String tweetId) async {
    try {
      await FirebaseFirestore.instance.collection('tweets').doc(tweetId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xoá bài thất bại: $e')),
    );
  }
  }
}