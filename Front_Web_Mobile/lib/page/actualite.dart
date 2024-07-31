import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_user.dart'; // Importez User depuis le bon fichier
import 'message_send_page.dart'; // Assurez-vous d'importer le fichier de la page de message

class Actualite extends StatefulWidget {
  final User currentUser;

  Actualite(this.currentUser);

  @override
  _ActualiteState createState() => _ActualiteState();
}

class _ActualiteState extends State<Actualite> {
  List _posts = [];
  List _friends = [];
  bool _isLoadingPosts = false;
  bool _isLoadingFriends = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _fetchFriends(widget.currentUser.username);
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoadingPosts = true;
    });

    final url = 'http://192.168.1.136:8000/posts/';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _posts = json.decode(response.body);
          _isLoadingPosts = false;
        });
      } else {
        print("Failed to load posts. Status code: ${response.statusCode}");
        _isLoadingPosts = false;
      }
    } catch (e) {
      print("Error fetching posts: $e");
      _isLoadingPosts = false;
    }
  }

  Future<void> _fetchFriends(String username) async {
    setState(() {
      _isLoadingFriends = true;
    });

    final url = 'http://192.168.1.136:8000/users/${widget.currentUser.id}/all/';
    print('Fetching friends from URL: $url'); // Vérifiez l'URL générée dans le terminal
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _friends = json.decode(response.body);
          _isLoadingFriends = false;
        });
      } else {
        print("Failed to load friends. Status code: ${response.statusCode}");
        _isLoadingFriends = false;
      }
    } catch (e) {
      print("Error fetching friends: $e");
      _isLoadingFriends = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white70, // Couleur de fond de la page
        child: _isLoadingPosts
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            _buildFriendsList(),
            Expanded(child: _buildPostsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    return _isLoadingFriends
        ? Center(child: CircularProgressIndicator())
        : Container(
      height: 126,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    friend['profile_picture'] ??
                        'https://via.placeholder.com/150',
                  ),
                ),
                SizedBox(height: 2),
                Text(friend['username']),
                IconButton(
                  icon: Icon(Icons.message),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessageSendPage(
                          currentUserID: widget.currentUser.id,
                          recipientID: friend['id'],
                          recipientUsername: friend['username'],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostsList() {
    return ListView.builder(
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        final bool isCurrentUserOwner =
            widget.currentUser.id == post['author__username'];
        return Card(
          margin: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      post['author__username'] ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (isCurrentUserOwner)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editPost(post['id']);
                          } else if (value == 'delete') {
                            _confirmDelete(post['id']);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return {'Modifier', 'Supprimer'}.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice.toLowerCase(),
                              child: Text(choice),
                            );
                          }).toList();
                        },
                        icon: Icon(Icons.more_vert),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildContent(post['content']),
              ),
              if (post['image'] != null)
                Image.network(
                  post['image'],
                  errorBuilder: (context, error, stackTrace) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Image not available'),
                    );
                  },
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.thumb_up),
                          color: Colors.lightBlueAccent, // Couleur bleu ciel pour like
                          onPressed: () {
                            // Logique de gestion du like pour cette publication
                          },
                        ),
                        Text('${post['likes'] ?? 20}'),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.comment),
                          color: Colors.yellow, // Couleur jaune pour commentaire
                          onPressed: () {
                            // Logique de gestion du commentaire pour cette publication
                          },
                        ),
                        Text('${post['comments'] ?? 5}'),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.share),
                          color: Colors.red, // Couleur rouge pour partage
                          onPressed: () {
                            // Logique de gestion du partage pour cette publication
                          },
                        ),
                        Text('${post['share'] ?? 75}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(String content) {
    const int maxLines = 3;
    bool isExpanded = false;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              maxLines: isExpanded ? null : maxLines,
              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (content.length > 100) // Assuming a threshold to show 'Voir plus'
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text(
                  isExpanded ? 'Voir moins' : 'Voir plus',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _editPost(int postId) async {
    // Logique pour modifier la publication
  }

  Future<void> _deletePost(int postId) async {
    // Logique pour supprimer la publication
  }

  void _confirmDelete(int postId) {
    // Dialog de confirmation pour supprimer la publication
  }
}
