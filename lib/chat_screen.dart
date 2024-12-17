import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String friendUID;
  final String friendName;

  ChatScreen({required this.friendUID, required this.friendName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _messages = FirebaseFirestore.instance.collection('messages');

  Stream<QuerySnapshot> _messageStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.empty();

    return _messages
        .where('participants', arrayContains: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void _sendMessage() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _messageController.text.trim().isEmpty) return;

    _messages.add({
      'sender': user.uid,
      'receiver': widget.friendUID,
      'text': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'participants': [user.uid, widget.friendUID],
    });

    _messageController.clear();
  }

  void _editMessage(String messageId, String currentText) async {
    final TextEditingController editController = TextEditingController(text: currentText);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chỉnh sửa tin nhắn'),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(hintText: 'Nhập tin nhắn mới'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (editController.text.trim().isNotEmpty) {
                await _messages.doc(messageId).update({'text': editController.text});
              }
              Navigator.pop(context);
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(String messageId) async {
    await _messages.doc(messageId).delete();
  }

  void _showMessageOptions(String messageId, String messageText, bool isMe) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMe) ListTile(
              leading: Icon(Icons.edit),
              title: Text('Chỉnh sửa'),
              onTap: () {
                Navigator.pop(context);
                _editMessage(messageId, messageText);
              },
            ),
            if (isMe) ListTile(
              leading: Icon(Icons.delete),
              title: Text('Thu hồi tin nhắn'),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(messageId);
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel),
              title: Text('Hủy'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2979FF),
        title: Text(
          widget.friendName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messageStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Không có tin nhắn nào!'));
                }
                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['sender'] == FirebaseAuth.instance.currentUser!.uid;
                    final messageText = message['text'] ?? '';

                    return GestureDetector(
                      onLongPress: () {
                        if (isMe) {
                          _showMessageOptions(message.id, messageText, isMe);
                        }
                      },
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            messageText,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Nhập tin nhắn...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}