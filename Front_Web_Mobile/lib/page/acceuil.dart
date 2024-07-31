import 'package:flutter/material.dart';
import 'login.dart';
import 'inscription.dart';

class Acceuil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.menu, color: Colors.white), // Exemple d'icône de menu à gauche
            SizedBox(width: 10),
            Text(
              'TafaResaka',
              style: TextStyle(
                fontSize: 28,
                fontStyle: FontStyle.italic, // Texte en italique
                color: Colors.white,
                fontFamily: 'Roboto',
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black.withOpacity(0.5), // Ombre noire avec opacité
                    offset: Offset(2.0, 2.0), // Décalage de l'ombre
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      extendBodyBehindAppBar: true,
      body: Theme(
        // Utiliser le thème sombre pour le corps de l'écran d'accueil
        data: Theme.of(context).copyWith(
          brightness: Brightness.dark,
          // Définir d'autres couleurs et styles pour le mode sombre
          scaffoldBackgroundColor: Color(0xFF0A1828), // Bleu foncé classique
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF178582), // Turquoise
                    Color(0xFF0A1828), // Bleu foncé classique
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Bienvenue sur TafaResaka',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Texte en blanc
                        fontFamily: 'Roboto', // Utilisation d'une police similaire à Instagram
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Login()),
                            );
                          },
                          child: Text('Connexion'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            textStyle: TextStyle(fontSize: 18),
                            backgroundColor: Color(0xFFFFCC00), // Jaune tangerine
                            foregroundColor: Colors.black, // Texte en noir
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Inscription()),
                            );
                          },
                          child: Text('Inscription'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            textStyle: TextStyle(fontSize: 18),
                            backgroundColor: Color(0xFF96C2DB), // Bleu-gris
                            foregroundColor: Colors.white, // Texte en blanc
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
