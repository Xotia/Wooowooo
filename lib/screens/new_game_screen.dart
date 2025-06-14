import 'package:flutter/material.dart';
import 'dart:math';
import '../models/game.dart';
import '../models/player.dart';
import '../services/role_manager.dart';
import 'game_screen.dart';

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final TextEditingController _playersController = TextEditingController();
  List<String> _players = [];
  final Random _random = Random();
  late int _backgroundImageIndex;

  @override
  void initState() {
    super.initState();
    _backgroundImageIndex = _random.nextInt(11) + 1; // Images de 1 à 11
    _playersController.addListener(_updatePlayersList);
    _initializeRoleManager();
  }

  Future<void> _initializeRoleManager() async {
    await RoleManager.initialize();
  }

  void _updatePlayersList() {
    setState(() {
      _players = _playersController.text
          .split(',')
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty)
          .toList();
    });
  }

  Future<void> _startGame() async {
    if (_players.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins un joueur'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Distribution des rôles
      final roles = RoleManager.distributeRoles(_players.length);
      
      // Création des objets Player
      final players = List.generate(
        _players.length,
        (index) => Player(
          name: _players[index],
          role: roles[index],
        ),
      );

      // Créer une liste unique des rôles distribués
      final activeRoles = roles.toSet().toList()..sort();

      // Création de l'objet Game
      final game = Game(
        players: players,
        activeRoles: activeRoles,
      );

      // Initialiser la référence game pour chaque joueur
      for (final player in players) {
        player.setGame(game);
      }

      // Navigation vers l'écran de jeu
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(game: game),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la création de la partie: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _playersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image de fond
          Image.asset(
            'assets/images/$_backgroundImageIndex.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Contenu
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bouton retour
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  // Champ de saisie des joueurs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _playersController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Entrez les noms des joueurs, séparés par des virgules',
                        hintStyle: TextStyle(
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        labelText: 'Joueurs',
                        labelStyle: TextStyle(
                          color: Colors.amber,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Nombre de joueurs
                  Text(
                    'Nombre de joueurs : ${_players.length}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 3.0,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Liste des joueurs
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: _players.isEmpty
                          ? const Center(
                              child: Text(
                                'Aucun joueur ajouté',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _players.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    _players[index],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.amber,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Commencer la partie',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}