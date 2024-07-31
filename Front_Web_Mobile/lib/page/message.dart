import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'message_send_page.dart';

class ConversationsPage extends StatefulWidget {
  final int userId;
  final int currentUserID;
  final VoidCallback onMessagesRead;

  ConversationsPage({
    required this.userId,
    required this.currentUserID,
    required this.onMessagesRead,
  });

  @override
  _ConversationsPageState createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  List<dynamic> _conversations = [];
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchConversations();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchConversations() async {
    final url = Uri.parse(
        'http://192.168.1.136:8000/conversations/?user_id=${widget.userId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _conversations = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        print("Failed to load conversations. Status code: ${response.statusCode}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading conversations: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _markMessagesAsRead(int conversationId) async {
    final url = Uri.parse('http://192.168.1.136:8000/mark_messages_as_read/');
    try {
      final response = await http.post(
          url,
          body: {
            'user_id': widget.userId.toString(),
            'conversation_id': conversationId.toString()
          }
      );

      if (response.statusCode == 200) {
        widget.onMessagesRead();
        _fetchConversations(); // Rafraîchit la liste des conversations pour mettre à jour l'interface utilisateur
      } else {
        print("Failed to mark messages as read. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
          ? Center(child: Text('Aucune conversation trouvée.'))
          : ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          final lastMessageSenderID = conversation['last_message_sender_id'];
          final isMessageSentByCurrentUser = lastMessageSenderID == widget.currentUserID;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: InkWell(
              onTap: () {
                _markMessagesAsRead(conversation['conversation_id']);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessageSendPage(
                      currentUserID: widget.userId,
                      recipientID: conversation['other_user_id'],
                      recipientUsername: conversation['other_username'],
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: conversation['profile_image_url'] != null
                            ? NetworkImage(conversation['profile_image_url'])
                            : AssetImage('assets/images/default_avatar.png'),

                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              conversation['other_username'] ?? 'Username not available',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              conversation['last_message'] ?? 'No message yet',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            if (conversation['unread_count'] > 0)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${conversation['unread_count']} nouveau(x)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      if (isMessageSentByCurrentUser)
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}



// class ConversationDetailsPage extends StatefulWidget {
//   final int userId;
//   final int conversationId;
//
//   ConversationDetailsPage({required this.userId, required this.conversationId});
//
//   @override
//   _ConversationDetailsPageState createState() => _ConversationDetailsPageState();
// }
//
// class _ConversationDetailsPageState extends State<ConversationDetailsPage> {
//   Map<String, dynamic> _conversationData = {};
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchConversationDetails();
//   }
//
//   Future<void> _fetchConversationDetails() async {
//     final url = Uri.parse('http://192.168.1.136:8000/conversation/${widget.conversationId}/');
//
//     try {
//       final response = await http.get(url);
//
//       if (response.statusCode == 200) {
//         setState(() {
//           _conversationData = json.decode(response.body);
//           _isLoading = false;
//         });
//       } else {
//         print("Failed to load conversation details. Status code: ${response.statusCode}");
//         _isLoading = false;
//       }
//     } catch (e) {
//       print("Error loading conversation details: $e");
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Conversation Details'),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('User 1 ID: ${_conversationData['user1_id']}'),
//             Text('User 2 ID: ${_conversationData['user2_id']}'),
//             Text('Last Message: ${_conversationData['last_message'] ?? 'No messages yet'}'),
//             Text('Last Message Time: ${_conversationData['last_message_time'] ?? 'Unknown'}'),
//           ],
//         ),
//       ),
//     );
//   }
// }
