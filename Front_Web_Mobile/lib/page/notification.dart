import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Notification {
  final String senderName;
  final String message;
  final DateTime timestamp;

  Notification({
    required this.senderName,
    required this.message,
    required this.timestamp,
  });
}

class NotificationPage extends StatefulWidget {
  final int userId;

  NotificationPage({required this.userId});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<String> notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final url = 'http://192.168.1.136:8000/notifications/?recipient_id=${widget.userId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          notifications = List<String>.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        print("Failed to load notifications. Status code: ${response.statusCode}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading notifications: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? Center(child: Text('No notifications found.'))
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              title: Text(
                notification,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                "Just now",
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (String result) {
                  // Handle your logic here for different menu options
                  print("Selected: $result");
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'option1',
                    child: Text('Option 1'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'option2',
                    child: Text('Option 2'),
                  ),
                ],
              ),
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/avatar_placeholder.png'), // Use network image if available
              ),
            ),
          );
        },
      ),
    );
  }
}
