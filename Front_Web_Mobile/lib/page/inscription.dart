import 'package:flutter/material.dart';
import 'upload_profile_picture.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Inscription extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inscription',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.white, // Couleur du texte de l'AppBar en blanc
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF178582), // Début de gradient
              Color(0xFF0A1828), // Fin de gradient
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.2, 0.8],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 100), // Espace ajouté au-dessus des champs de texte
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Champ Nom de famille
                  TextField(
                    controller: _lastNameController,
                    style: TextStyle(color: Colors.white), // Couleur du texte
                    decoration: InputDecoration(
                      labelText: 'Nom de famille',
                      labelStyle: TextStyle(color: Colors.white70), // Couleur du label
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Couleur de bordure
                      ),
                      prefixIcon: Icon(Icons.person, color: Colors.white), // Couleur de l'icône
                    ),
                  ),
                  SizedBox(height: 20), // Espace entre les champs de texte

                  // Champ Prénom
                  TextField(
                    controller: _firstNameController,
                    style: TextStyle(color: Colors.white), // Couleur du texte
                    decoration: InputDecoration(
                      labelText: 'Prénom',
                      labelStyle: TextStyle(color: Colors.white70), // Couleur du label
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Couleur de bordure
                      ),
                      prefixIcon: Icon(Icons.person, color: Colors.white), // Couleur de l'icône
                    ),
                  ),
                  SizedBox(height: 20), // Espace entre les champs de texte

                  // Champ Nom d'utilisateur
                  TextField(
                    controller: _usernameController,
                    style: TextStyle(color: Colors.white), // Couleur du texte
                    decoration: InputDecoration(
                      labelText: "Nom d'utilisateur",
                      labelStyle: TextStyle(color: Colors.white70), // Couleur du label
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Couleur de bordure
                      ),
                      prefixIcon: Icon(Icons.person, color: Colors.white), // Couleur de l'icône
                    ),
                  ),
                  SizedBox(height: 20), // Espace entre les champs de texte

                  // Champ Email
                  TextField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.white), // Couleur du texte
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white70), // Couleur du label
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Couleur de bordure
                      ),
                      prefixIcon: Icon(Icons.email, color: Colors.white), // Couleur de l'icône
                    ),
                  ),
                  SizedBox(height: 20), // Espace entre les champs de texte

                  // Champ Mot de passe
                  TextField(
                    controller: _passwordController,
                    style: TextStyle(color: Colors.white), // Couleur du texte
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      labelStyle: TextStyle(color: Colors.white70), // Couleur du label
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Couleur de bordure
                      ),
                      prefixIcon: Icon(Icons.lock, color: Colors.white), // Couleur de l'icône
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20), // Espace entre les champs de texte

                  // Champ Confirmer le Mot de passe
                  TextField(
                    controller: _confirmPasswordController,
                    style: TextStyle(color: Colors.white), // Couleur du texte
                    decoration: InputDecoration(
                      labelText: 'Confirmer votre Mot de passe',
                      labelStyle: TextStyle(color: Colors.white70), // Couleur du label
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Couleur de bordure
                      ),
                      prefixIcon: Icon(Icons.lock, color: Colors.white), // Couleur de l'icône
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20), // Espace avant le bouton

                  // Bouton S'inscrire
                  ElevatedButton(
                    onPressed: () async {
                      if (_passwordController.text ==
                          _confirmPasswordController.text) {
                        final url = 'http://192.168.1.136:8000/inscription/';
                        final response = await http.post(
                          Uri.parse(url),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode({
                            'username': _usernameController.text,
                            'email': _emailController.text,
                            'password': _passwordController.text,
                            'password2': _confirmPasswordController.text,
                            'first_name': _firstNameController.text,
                            'last_name': _lastNameController.text,
                          }),
                        );
                        if (response.statusCode == 201) {
                          print("Inscription Réussie!");
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UploadProfilePictureScreen(
                                userName: _usernameController.text,
                                userEmail: _emailController.text,
                              ),
                            ),
                          );
                        } else {
                          print(response.body);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                Text('Erreur lors de l\'inscription: ${response.body}')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Votre Mot de passe ne correspond pas!')),
                        );
                      }
                    },
                    child: Text("S'inscrire"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, backgroundColor: Color(0xFFFFCC00), padding:
                      EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: TextStyle(fontSize: 16), // Texte en noir
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}




