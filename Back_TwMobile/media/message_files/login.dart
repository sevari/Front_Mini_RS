import 'package:flutter/material.dart';
import 'home_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Connexion',
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
                  // Champ Email
                  TextField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.white), // Couleur du texte
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white70), // Couleur du label
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70), // Couleur de bordure
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
                        borderSide: BorderSide(color: Colors.white70), // Couleur de bordure
                      ),
                      prefixIcon: Icon(Icons.lock, color: Colors.white), // Couleur de l'icône
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20), // Espace avant le bouton

                  // Bouton Se connecter
                  ElevatedButton(
                    onPressed: () async {
                      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Veuillez remplir tous les champs')),
                        );
                        return;
                      }

                      final url = 'http://192.168.1.136:8000/login/';
                      try {
                        final response = await http.post(
                          Uri.parse(url),
                          headers: {
                            'Content-Type': 'application/json',
                          },
                          body: jsonEncode({
                            'email': _emailController.text,
                            'password': _passwordController.text,
                          }),
                        );

                        if (response.statusCode == 200) {
                          final data = jsonDecode(response.body);
                          final accessToken = data['access'];
                          final refreshToken = data['refresh'];
                          final userId = data['user_id'];  // Récupère l'ID de l'utilisateur

                          print("Connexion réussie!");
                          print("Access Token: $accessToken");
                          print("Refresh Token: $refreshToken");

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                userName: _emailController.text, // Adapté selon votre besoin
                                userEmail: _emailController.text,
                                userId: userId,  // Utilisation de l'ID de l'utilisateur récupéré
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur lors de la connexion: ${response.statusCode}')),
                          );
                        }
                      } catch (e) {
                        print('Error during login: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur lors de la connexion')),
                        );
                      }
                    },
                    child: Text("Se connecter"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, backgroundColor: Color(0xFFFFCC00), padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
