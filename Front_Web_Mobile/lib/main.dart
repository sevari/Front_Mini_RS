import 'package:flutter/material.dart';
import 'package:tech_web_mobile/page/actualite.dart';
import 'package:tech_web_mobile/page/create_post_screen.dart';
import 'package:tech_web_mobile/page/acceuil.dart';
import 'package:tech_web_mobile/page/login.dart';
import 'package:tech_web_mobile/page/inscription.dart';
import 'package:tech_web_mobile/page/home_user.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User currentUser = User(
      username: 'username',
      email: 'user@example.com',
      id: 1,

    );

    return MaterialApp(
      title: 'Mini Réseau Social',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Acceuil(),
        '/login': (context) => Login(),
        '/inscription': (context) => Inscription(),
        '/home': (context) => HomeScreen(
          userName: currentUser.username,
          userEmail: currentUser.email,
          userId: currentUser.id,
        ),
        '/create_post': (context) => CreatePostScreen(
          userName: 'DemoUser',
          userEmail: 'demo@example.com',
        ),
        '/actualites': (context) => Actualite(currentUser),
      },
    );
  }
}
