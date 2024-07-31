import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Message {
  final int id;
  final int sender;
  final int recipient;
  final String content;
  final String createdAt;
  final String? imageUrl;
  final String type;
  final String? fileUrl;

  Message({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.content,
    required this.createdAt,
    this.imageUrl,
    required this.type,
    this.fileUrl,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      sender: json['sender'],
      recipient: json['recipient'],
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
      imageUrl: json['image_url'],
      type: json['type'] ?? 'text',
      fileUrl: json['file_url'],
    );
  }
}

class MessageSendPage extends StatefulWidget {
  final int currentUserID;
  final int recipientID;
  final String recipientUsername;

  MessageSendPage({
    required this.currentUserID,
    required this.recipientID,
    required this.recipientUsername,
  });

  @override
  _MessageSendPageState createState() => _MessageSendPageState();
}

class _MessageSendPageState extends State<MessageSendPage> {
  TextEditingController _messageController = TextEditingController();
  List<Message> conversationMessages = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final url = Uri.parse(
        'http://192.168.1.136:8000/get_messages_between_users/${widget.currentUserID}/${widget.recipientID}/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        List<Message> fetchedMessages = (jsonData['messages'] as List)
            .map((item) => Message.fromJson(item))
            .toList();

        setState(() {
          conversationMessages = fetchedMessages;
        });
      } else {
        print('Failed to load messages: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text('Failed to load messages. Please try again later.')),
        );
      }
    } catch (e) {
      print('Error fetching messages: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
            Text('Error fetching messages. Please try again later.')),
      );
    }
  }

  Future<void> _sendMessage({
    String? content,
    Uint8List? imageBytes,
    PlatformFile? file,
  }) async {
    if (content == null && imageBytes == null && file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Please enter a message, select an image, or attach a file'),
        ),
      );
      return;
    }

    final url = Uri.parse('http://192.168.1.136:8000/send_message/');
    var request = http.MultipartRequest('POST', url);
    request.fields['sender_id'] = widget.currentUserID.toString();
    request.fields['recipient_id'] = widget.recipientID.toString();

    if (content != null) {
      request.fields['content'] = content;
    }

    if (imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'image.jpg',
      ));
      request.fields['type'] = 'image';
    }

    if (file != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
      ));
      request.fields['type'] = 'file';
    }
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message envoye')),
        );
        _messageController.clear();
        fetchMessages();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Echec d'envoye")),
        );
      }
    } catch (e) {
      print("Error lors de l'envoye: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez ressayez')),
      );
    }
  }

  Future<void> _sendImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    await _sendMessage(imageBytes: bytes);
  }

  Future<void> _attachFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      await _sendMessage(file: file);
    }
  }

  void _startVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting video call...')),
    );
  }

  void _startVoiceCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting voice call...')),
    );
  }

  Widget _buildMessageBubble(Message message) {
    String baseUrl = 'http://192.168.1.136:8000'; // Example base URL
    String imageUrl =
    message.imageUrl != null ? '$baseUrl${message.imageUrl}' : '';

    bool isSentByCurrentUser = message.sender == widget.currentUserID;

    return Align(
      alignment: isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: EdgeInsets.all(8.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isSentByCurrentUser ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSentByCurrentUser ? Colors.blue : Colors.grey,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: isSentByCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.type == 'image' && message.imageUrl != null)
              Image.network(
                imageUrl,
                width: 250,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Column(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      Text('Failed to load image'),
                    ],
                  );
                },
              ),
            if (message.type == 'file' && message.fileUrl != null)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 200),
                child: Row(
                  children: [
                    Icon(Icons.file_present, color: Colors.black, size: 20),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        message.type,
                        style: TextStyle(color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.upload, color: Colors.black, size: 20),

                  ],
                ),
              ),
            if (message.content.isNotEmpty && message.type == 'text')
              Text(
                message.content,
                style: TextStyle(color: Colors.black),
              ),
            Text(
              message.createdAt,
              style: TextStyle(color: Colors.grey, fontSize: 10),
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
        title: Text(widget.recipientUsername),
        actions: [
          IconButton(
            icon: Icon(Icons.video_call),
            onPressed: _startVideoCall,
            tooltip: 'Start Video Call',
          ),
          IconButton(
            icon: Icon(Icons.call),
            onPressed: _startVoiceCall,
            tooltip: 'Start Voice Call',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: conversationMessages.length,
              itemBuilder: (context, index) {
                Message message = conversationMessages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: _sendImage,
                  tooltip: 'Send Image',
                ),
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: _attachFile,
                  tooltip: 'Attach File',
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(content: _messageController.text.trim()),
                  tooltip: 'Send Message',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
