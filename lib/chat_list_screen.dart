import 'package:chatapp/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _searchController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  List<DocumentSnapshot> _searchResults = [];
  List<DocumentSnapshot> _friends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final friendsUIDs = List<String>.from(userDoc['friends'] ?? []);

    final friendsDocs = await Future.wait(
      friendsUIDs.map((uid) => FirebaseFirestore.instance.collection('users').doc(uid).get()),
    );

    setState(() {
      _friends = friendsDocs;
    });
  }

  void _searchUsers(String query) async {
    final results = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: query)
        .get();

    setState(() {
      _searchResults = results.docs;
    });
  }

  void _addFriend(String uid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'friends': FieldValue.arrayUnion([uid]),
    });

    setState(() {
      _searchResults = [];
    });

    _loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2979FF),
        title: const Text(
          'Nhắn tin',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                  hintText: 'Tìm kiếm',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _searchUsers(_searchController.text);
                    },
                  ),
                  border: OutlineInputBorder()
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.isNotEmpty ? _searchResults.length : _friends.length,
              itemBuilder: (context, index) {
                final user = _searchResults.isNotEmpty ? _searchResults[index] : _friends[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                  child: ListTile(
                    title: Text(user['username']),
                    trailing: _searchResults.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => _addFriend(user.id),
                    )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            friendUID: user.id,
                            friendName: user['username'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}