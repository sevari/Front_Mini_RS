import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'home_user.dart';

class CreatePostScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  CreatePostScreen({required this.userName, required this.userEmail});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageName;
  String? _imageUrl;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        _imageBytes = result.files.first.bytes;
        _imageName = result.files.first.name;
      });
    }
  }

  Future<void> _submitPost() async {
    final url = 'http://192.168.1.136:8000/api/create_post/';
    final request = http.MultipartRequest('POST', Uri.parse(url));

    request.fields['author'] = widget.userEmail;
    request.fields['content'] = _contentController.text;

    if (_imageBytes != null && _imageName != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        _imageBytes!,
        filename: _imageName!,
      ));
    }

    final response = await request.send();

    if (response.statusCode == 201) {
      final responseBody = await http.Response.fromStream(response);
      final responseData = json.decode(responseBody.body);

      print("Post created successfully!");
      print("Image URL: ${responseData['image_url']}");

      // Stocker l'URL de l'image pour l'afficher
      setState(() {
        _imageUrl = responseData['image_url'];
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userName: widget.userName, userEmail: widget.userEmail, userId: 123),
        ),
      );
    } else {
      print("Failed to create post.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création de la publication')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder image for user
                  radius: 20,
                ),
                SizedBox(width: 10),
                Text(widget.userName, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Say something about this post...',
              ),
              maxLines: 5,
            ),
            if (_imageBytes != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Image.memory(_imageBytes!),
              ),
            Divider(),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: _pickImage,
                ),
                Text('Photo/Video'),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _submitPost,
              child: Text('Publish'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Make button full width
              ),
            ),
          ],
        ),
      ),
    );
  }
}
