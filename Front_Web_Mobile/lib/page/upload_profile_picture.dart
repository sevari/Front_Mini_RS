import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'home_user.dart';

class UploadProfilePictureScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  UploadProfilePictureScreen({required this.userName, required this.userEmail});

  @override
  _UploadProfilePictureScreenState createState() => _UploadProfilePictureScreenState();
}

class _UploadProfilePictureScreenState extends State<UploadProfilePictureScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = image;
    });
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    final url = 'http://192.168.1.136:8000/upload_profile_picture/';
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['email'] = widget.userEmail;
    request.files.add(await http.MultipartFile.fromPath('profile_picture', _imageFile!.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      print("Profile picture uploaded successfully.");
      // Rediriger vers la page d'accueil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userName: widget.userName, userEmail: widget.userEmail, userId: 123),
        ),
      );
    } else {
      print("Failed to upload profile picture.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du téléchargement de la photo de profil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo de profil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: _pickImage,
              child: _imageFile == null
                  ? CircleAvatar(
                radius: 60,
                child: Icon(Icons.person, size: 60),
              )
                  : CircleAvatar(
                radius: 60,
                backgroundImage: FileImage(File(_imageFile!.path)),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Nom d\'utilisateur: ${widget.userName}\nEmail: ${widget.userEmail}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _imageFile != null ? _uploadImage : null,
              child: Text('Upload Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(userName: widget.userName, userEmail: widget.userEmail, userId: 123),
                  ),
                );
              },
              child: Text('Skip'),
            ),
          ],
        ),
      ),
    );
  }
}
