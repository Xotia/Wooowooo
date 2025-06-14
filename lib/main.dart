import 'package:flutter/material.dart';
import 'dart:async';
import 'screens/new_game_screen.dart';
import 'screens/documentation_screen.dart';
import 'services/role_manager.dart';
import 'services/speech_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser les services
  try {
    await RoleManager.initialize();
    await SpeechService.initialize();
  } catch (e) {
    print('Erreur lors de l\'initialisation des services: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wooowooo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        fontFamily: 'MedievalSharp',  // Police par défaut pour toute l'application
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            color: Colors.amber,
          ),
          displayMedium: TextStyle(
            fontSize: 36,
            color: Colors.amber,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            color: Colors.amber,
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _currentImageIndex = 1;
  late AnimationController _fadeController;
  late Timer _slideShowTimer;
  final int _totalImages = 11; // Nombre total d'images dans le dossier

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _startSlideShow();
  }

  void _startSlideShow() {
    _slideShowTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fadeController.reverse().then((_) {
        setState(() {
          _currentImageIndex = (_currentImageIndex % _totalImages) + 1;
        });
        _fadeController.forward();
      });
    });
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideShowTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond d'écran avec diaporama
          FadeTransition(
            opacity: _fadeController,
            child: Image.asset(
              'assets/images/$_currentImageIndex.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Contenu
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(179), // équivalent à 0.7 * 255
                  Colors.black.withAlpha(77),  // équivalent à 0.3 * 255
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Wooowooo',
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      shadows: [
                        const Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewGameScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Nouvelle Partie',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DocumentationScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Documentation',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
