import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'create_post_screen.dart';
import 'message.dart';
import 'notification.dart'; // Importez votre page de notifications
import 'message_send_page.dart';
import 'actualite.dart';
import 'info.dart';

// Définition de la classe User
class User {
  final String username;
  final String email;
  final int id;

  User({
    required this.username,
    required this.email,
    required this.id,
  });
}

// Widget HomeScreen
class HomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final int userId;

  HomeScreen({
    required this.userName,
    required this.userEmail,
    required this.userId,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _unreadMessagesCount = 0;
  int _unreadNotificationsCount = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _fetchUnreadMessagesCount();
    _fetchUnreadNotificationsCount();
    _screens = [
      Actualite(User(
        username: widget.userName,
        email: widget.userEmail,
        id: widget.userId,
      )),
      NotificationPage(userId: widget.userId), // Votre page de notifications
      ConversationsPage(
        userId: widget.userId,
        currentUserID: widget.userId,
        onMessagesRead: _fetchUnreadMessagesCount,
      ),
      UserInfoPage(userId: widget.userId,),
    ];
  }

  Future<void> _fetchUnreadMessagesCount() async {
    final messageUrl = Uri.parse('http://192.168.1.136:8000/unread_messages_count/?user_id=${widget.userId}');
    try {
      final response = await http.get(messageUrl);
      if (response.statusCode == 200) {
        setState(() {
          _unreadMessagesCount = json.decode(response.body)['count'];
        });
      } else {
        print("Failed to load unread messages count. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading unread messages count: $e");
    }
  }

  Future<void> _fetchUnreadNotificationsCount() async {
    final notificationUrl = Uri.parse('http://192.168.1.136:8000/unread_notifications_count/?user_id=${widget.userId}');
    try {
      final response = await http.get(notificationUrl);
      if (response.statusCode == 200) {
        setState(() {
          _unreadNotificationsCount = json.decode(response.body)['count'];
        });
      } else {
        print("Failed to load unread notifications count. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading unread notifications count: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      // Réinitialiser le compteur de notifications après avoir appuyé dessus
      setState(() {
        _unreadNotificationsCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'TafaResaka',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.white, // Couleur du texte de l'AppBar en blanc
          ),
        ),
        backgroundColor: Color(0xFF178582), // Couleur de l'AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Logique de recherche
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Naviguer vers l'écran de création de publication lorsque le bouton est pressé
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePostScreen(
                userName: widget.userName,
                userEmail: widget.userEmail,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                _onItemTapped(0);
              },
              color: Color(0xFF178582), // Couleur de l'icône
            ),
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.message),
                  onPressed: () {
                    _onItemTapped(2);
                  },
                  color: Color(0xFF178582), // Couleur de l'icône
                ),
                if (_unreadMessagesCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$_unreadMessagesCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    _onItemTapped(1);
                  },
                  color: Color(0xFF178582), // Couleur de l'icône
                ),
                if (_unreadNotificationsCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$_unreadNotificationsCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                _onItemTapped(3);
              },
              color: Color(0xFF178582), // Couleur de l'icône
            ),
          ],
        ),
      ),
    );
  }
}
