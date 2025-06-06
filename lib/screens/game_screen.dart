import 'package:flutter/material.dart';
import 'dart:math';
import '../models/game.dart';
import '../models/player.dart';
import '../services/role_manager.dart';
import '../services/turn_manager.dart';
import '../dialogs/game_info_dialog.dart';
import '../constants/turn_orders.dart';
import '../dialogs/role_dialog.dart';

class GameScreen extends StatefulWidget {
  final Game game;

  const GameScreen({super.key, required this.game});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late int _currentBackgroundImage;
  final Random _random = Random();
  late TurnManager _turnManager;

  @override
  void initState() {
    super.initState();
    _updateBackgroundForPhase(widget.game.currentPhase);
    _turnManager = TurnManager(game: widget.game);
  }

  void _updateBackgroundForPhase(DayPhase phase) {
    setState(() {
      if (phase == DayPhase.day) {
        // Images de jour (1-6)
        _currentBackgroundImage = _random.nextInt(6) + 1;
      } else {
        // Images de nuit (7-11)
        _currentBackgroundImage = _random.nextInt(5) + 7;
      }
    });
  }

  void _toggleDayPhase() {
    setState(() {
      if (widget.game.currentPhase == DayPhase.night) {
        widget.game.currentPhase = DayPhase.day;
        _showSunriseDialog();
      } else {
        widget.game.currentPhase = DayPhase.night;
        widget.game.currentDay++; // On incrémente le jour quand on passe au jour à la nuit
      }
      _updateBackgroundForPhase(widget.game.currentPhase);
      _turnManager.onPhaseChange();
    });
  }

  void _showRestartConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          'Confirmer le redémarrage',
          style: TextStyle(color: Colors.amber),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir redémarrer la partie ? Cela va :\n\n'
          '- Redistribuer tous les rôles\n'
          '- Réinitialiser le jour à 1\n'
          '- Remettre tous les joueurs en vie\n'
          '- Recommencer à la première nuit\n\n'
          'Cette action ne peut pas être annulée.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Redémarrer'),
            onPressed: () {
              _restartGame();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    final numberOfPlayers = widget.game.players.length;
    final newRoles = RoleManager.distributeRoles(numberOfPlayers);

    setState(() {
      // Réinitialisation des paramètres de la partie
      widget.game.currentDay = 0;
      widget.game.currentPhase = DayPhase.night;
      widget.game.alivePlayers = numberOfPlayers;
      widget.game.deadPlayers = 0;
      widget.game.healPotionUsed = false;
      widget.game.deathPotionUsed = false;

      // Mise à jour des joueurs
      for (int i = 0; i < numberOfPlayers; i++) {
        final player = widget.game.players[i];
        final role = newRoles[i];
        
        // Gestion de l'attribut isDumb pour l'Idiot du Village
        if (role.endsWith('[isDumb]')) {
          player.role = role.replaceAll('[isDumb]', '');
          player.isDumb = true;
        } else {
          player.role = role;
          player.isDumb = false;
        }
        
        player.isAlive = true;
        player.isProtectedByGuard = false;
        player.isProtectedByLawyer = false;
        player.isTargetedByCollector = false;
        player.isInLove = false;
        player.isMayor = false;
        player.isWildChildIdol = false;
        player.wasAttackedTonight = false;
        player.isChosenByBaker = false;
        player.isAccusedByRaven = false;
        player.isAccusedByVote = false;
        player.secondChance = player.role == 'Mère Grand';
        player.setGame(widget.game); // Réinitialiser la référence au jeu
      }

      // Mise à jour de la liste des rôles actifs
      widget.game.activeRoles
        ..clear()
        ..addAll(newRoles.toSet().toList()..sort());

      // Réinitialisation du TurnManager
      _turnManager.reset();
      
      // Mise à jour du fond d'écran pour la nuit
      _updateBackgroundForPhase(DayPhase.night);
    });
  }

  void _showVoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          'Vote du Village',
          style: TextStyle(color: Colors.amber),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "C'est l'heure du vote, le village désigne le joueur qu'il souhaite éliminer",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Player>(
                  dropdownColor: Colors.black87,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  hint: const Text(
                    'Sélectionnez un joueur',
                    style: TextStyle(color: Colors.white70),
                  ),
                  items: widget.game.players
                      .where((player) => player.isAlive)
                      .map((Player player) {
                    return DropdownMenuItem<Player>(
                      value: player,
                      child: Text(
                        player.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (Player? selectedPlayer) {
                    if (selectedPlayer != null) {
                      setState(() {
                        // Réinitialise tous les votes
                        for (var p in widget.game.players) {
                          p.isAccusedByVote = false;
                        }
                        // Applique le nouveau vote
                        selectedPlayer.isAccusedByVote = true;
                      });
                      Navigator.pop(context);
                      
                      // Tentative d'exécution
                      selectedPlayer.tryToKillPlayer(context);

                      // Affichage du résultat
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.black87,
                          title: const Text(
                            'Résultat du Vote',
                            style: TextStyle(color: Colors.amber),
                          ),
                          content: Text(
                            selectedPlayer.isAlive
                                ? '${selectedPlayer.name} a survécu à l\'exécution du village'
                                : '${selectedPlayer.name} a été exécuté par le village, son rôle était ${selectedPlayer.role}',
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                // Réinitialisation des attributs
                                for (var player in widget.game.players) {
                                  player.isProtectedByLawyer = false;
                                  player.isChosenByBaker = false;
                                  player.isAccusedByRaven = false;
                                  player.isAccusedByVote = false;
                                }
                                Navigator.pop(context);
                              },
                              child: const Text('Fermer', style: TextStyle(color: Colors.amber)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSunriseDialog() {
    // Récupération des informations nécessaires
    final bakedPlayer = widget.game.players.firstWhere(
      (p) => p.isChosenByBaker,
      orElse: () => Player(name: '', role: ''),
    );
    
    final accusedPlayer = widget.game.players.firstWhere(
      (p) => p.isAccusedByRaven,
      orElse: () => Player(name: '', role: ''),
    );
    
    final hasShepherd = widget.game.activeRoles.contains('Berger') &&
        widget.game.players.any((p) => p.role == 'Berger' && p.isAlive);

    // Tenter de tuer tous les joueurs attaqués
    for (final player in widget.game.players) {
      if (player.wasAttackedTonight) {
        player.tryToKillPlayer(context);
      }
    }

    // Construction du message
    final List<Widget> messages = [
      Text(
        'Le soleil se lève, c\'est le jour ${widget.game.currentDay}',
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
    ];

    if (bakedPlayer.name.isNotEmpty) {
      messages.add(
        Text(
          'Le boulanger a livré une baguette de pain chez ${bakedPlayer.name}.',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
      messages.add(const SizedBox(height: 8));
    }

    if (accusedPlayer.name.isNotEmpty) {
      messages.add(
        Text(
          'Des corbeaux se sont posés sur le toit de ${accusedPlayer.name}.',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
      messages.add(const SizedBox(height: 8));
    }

    if (hasShepherd) {
      messages.add(
        const Text(
          'Les chiens de berger reniflent, si des loups sont près du Berger, ils aboieront.',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
      messages.add(const SizedBox(height: 8));
    }

    // Liste des joueurs attaqués pendant la nuit
    final attackedPlayers = widget.game.players.where((p) => p.wasAttackedTonight).toList();
    
    if (attackedPlayers.isEmpty) {
      messages.add(
        const Text(
          'Aucun joueur n\'a été attaqué cette nuit.',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      messages.add(
        const Text(
          'Les joueurs suivants ont été attaqués cette nuit :',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      );
      messages.add(const SizedBox(height: 8));
      
      for (final player in attackedPlayers) {
        messages.add(
          Text(
            '${player.name} (${player.role})',
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }
      messages.add(const SizedBox(height: 16));
    }

    // Liste des joueurs tués pendant la nuit
    final killedPlayers = widget.game.players
        .where((p) => p.wasAttackedTonight && !p.isAlive)
        .toList();
    
    if (killedPlayers.isNotEmpty) {
      messages.add(
        const Text(
          'Les joueurs suivants ont été tués cette nuit :',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      );
      messages.add(const SizedBox(height: 8));
      
      for (final player in killedPlayers) {
        messages.add(
          Text(
            '${player.name} (${player.role})',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          'Lever du soleil',
          style: TextStyle(color: Colors.amber),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: messages,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Réinitialisation des attributs pour tous les joueurs
              for (var player in widget.game.players) {
                player.isProtectedByGuard = false;
                player.wasAttackedTonight = false;
              }
              Navigator.pop(context);
              // On vérifie s'il y a un maire vivant après avoir affiché les morts de la nuit
              final hasMayor = widget.game.players.any((p) => p.isMayor && p.isAlive);
              if (!hasMayor) {
                _showMayorElectionDialog();
              }
            },
            child: const Text('Fermer', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  void _showMayorElectionDialog() {
    // Vérifier si un maire existe déjà
    final existingMayor = widget.game.players.firstWhere(
      (p) => p.isMayor && p.isAlive,
      orElse: () => Player(name: '', role: ''),
    );

    if (existingMayor.name.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Maire déjà élu',
            style: TextStyle(color: Colors.amber),
          ),
          content: Text(
            'Le maire a déjà été élu : ${existingMayor.name}',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer', style: TextStyle(color: Colors.amber)),
            ),
          ],
        ),
      );
      return;
    }

    Player? selectedMayor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Élection du Maire',
            style: TextStyle(color: Colors.amber),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Le village doit élire un maire',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Player>(
                    dropdownColor: Colors.black87,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
                    isExpanded: true,
                    value: selectedMayor,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    hint: const Text(
                      'Sélectionnez le maire',
                      style: TextStyle(color: Colors.white70),
                    ),
                    items: widget.game.players
                        .where((player) => player.isAlive)
                        .map((Player player) {
                      return DropdownMenuItem<Player>(
                        value: player,
                        child: Text(
                          player.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (Player? player) {
                      setState(() {
                        selectedMayor = player;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: selectedMayor != null
                  ? () {
                      this.setState(() {
                        selectedMayor!.isMayor = true;
                      });
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('Élire'),
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
        backgroundColor: Colors.black54,
        elevation: 0,
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: Colors.amber),
          onSelected: (value) {
            switch (value) {
              case 'restart':
                _showRestartConfirmation();
                break;
              case 'info':
                GameInfoDialog.show(context, widget.game);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restart',
              child: Row(
                children: [
                  Icon(Icons.refresh, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Redémarrer la partie', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber),
                  SizedBox(width: 8),
                  Text('Informations', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        title: Text(
          'Jour ${widget.game.currentDay}',
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 20,
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
        actions: [
          // État de la partie
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Text(
                  widget.game.currentPhase == DayPhase.day ? '☀️ Jour' : '🌙 Nuit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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
                const SizedBox(width: 16),
                Text(
                  '👥 ${widget.game.alivePlayers}/${widget.game.players.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Image de fond
          Image.asset(
            'assets/images/$_currentBackgroundImage.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Contenu
          SafeArea(
            child: Column(
              children: [
                // Affichage du rôle actuel
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.amber,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.amber),
                        onPressed: () {
                          setState(() {
                            _turnManager.previousTurn();
                          });
                        },
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Tour actuel',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Builder(
                              builder: (context) {
                                final currentRole = _turnManager.getCurrentRole();
                                if (currentRole == null) {
                                  return const Text('Fin du tour');
                                }

                                final isEvent = TurnOrders.isSpecialEvent(currentRole);
                                final displayText = isEvent 
                                  ? currentRole.replaceAll('[', '').replaceAll(']', '') 
                                  : currentRole;

                                return GestureDetector(
                                  onTap: () {
                                    if (currentRole == TurnOrders.VOTE_EVENT) {
                                      _showVoteDialog();
                                    } else {
                                      RoleDialog.show(context, widget.game, currentRole);
                                    }
                                  },
                                  child: Text(
                                    displayText,
                                    style: TextStyle(
                                      color: isEvent ? Colors.red : Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.amber),
                        onPressed: () {
                          setState(() {
                            _turnManager.nextTurn();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // Liste des joueurs
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.game.players.length,
                    itemBuilder: (context, index) {
                      final player = widget.game.players[index];
                      return Card(
                        color: Colors.black54,
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: player.isAlive ? Colors.green : Colors.red,
                            child: Text(
                              (index + 1).toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                RoleManager.getRoleEmoji(player.role),
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  player.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    decoration: player.isAlive ? null : TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (player.isProtectedByGuard) 
                                const Icon(Icons.security, color: Colors.blue),
                              if (player.isProtectedByLawyer) 
                                const Icon(Icons.gavel, color: Colors.blue),
                              if (player.isTargetedByCollector) 
                                const Icon(Icons.monetization_on, color: Colors.amber),
                              if (player.isChosenByBaker)
                                const Icon(Icons.bakery_dining, color: Colors.brown),
                              if (player.isInLove) 
                                const Icon(Icons.favorite, color: Colors.red),
                              if (player.isMayor) 
                                const Icon(Icons.star, color: Colors.amber),
                              if (player.isWildChildIdol) 
                                const Icon(Icons.child_care, color: Colors.green),
                              if (player.isSacrified) 
                                const Icon(Icons.local_fire_department, color: Colors.red),
                              if (player.wasAttackedTonight) 
                                const Icon(Icons.warning, color: Colors.orange),
                              if (player.isAccusedByVote)
                                const Icon(Icons.how_to_vote, color: Colors.orange),
                            ],
                          ),
                          onTap: () => _showPlayerDetails(player),
                        ),
                      );
                    },
                  ),
                ),
                // Boutons en bas de l'écran
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _toggleDayPhase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.game.currentPhase == DayPhase.night
                          ? Colors.amber // couleur soleil
                          : Colors.indigo, // couleur nuit
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: Icon(
                      widget.game.currentPhase == DayPhase.night
                          ? Icons.wb_sunny
                          : Icons.nightlight_round,
                      color: Colors.white,
                    ),
                    label: Text(
                      widget.game.currentPhase == DayPhase.night
                          ? 'Lever du soleil'
                          : 'Coucher du soleil',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPlayerDetails(Player player) {
    final nameController = TextEditingController(text: player.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          'Détails du Joueur',
          style: TextStyle(color: Colors.amber),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  labelStyle: TextStyle(color: Colors.amber),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    player.name = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Sélection du rôle
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: player.role,
                    dropdownColor: Colors.black87,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    items: RoleManager.getAllRoles().map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(
                          role,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newRole) {
                      if (newRole != null) {
                        setState(() {
                          // Mettre à jour le rôle du joueur
                          String oldRole = player.role;
                          player.role = newRole;
                          
                          // Mettre à jour la liste des rôles actifs
                          if (!widget.game.players.any((p) => p.role == oldRole)) {
                            widget.game.activeRoles.remove(oldRole);
                          }
                          if (!widget.game.activeRoles.contains(newRole)) {
                            widget.game.activeRoles.add(newRole);
                          }
                        });
                        // Forcer la reconstruction du dialogue
                        Navigator.pop(context);
                        _showPlayerDetails(player);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Statut vivant/mort
              SwitchListTile(
                title: const Text(
                  'En vie',
                  style: TextStyle(color: Colors.white),
                ),
                value: player.isAlive,
                onChanged: (bool value) {
                  setState(() {
                    player.isAlive = value;
                    widget.game.alivePlayers = value
                        ? widget.game.alivePlayers + 1
                        : widget.game.alivePlayers - 1;
                    widget.game.deadPlayers = value
                        ? widget.game.deadPlayers - 1 
                        : widget.game.deadPlayers + 1;
                  });
                },
                activeColor: Colors.green,
              ),
              const Divider(color: Colors.amber),
              // Protection du Garde
              SwitchListTile(
                title: const Text(
                  'Protégé par le Garde',
                  style: TextStyle(color: Colors.white),
                ),
                secondary: const Icon(Icons.security, color: Colors.blue),
                value: player.isProtectedByGuard,
                onChanged: (bool value) {
                  setState(() {
                    player.isProtectedByGuard = value;
                  });
                },
                activeColor: Colors.blue,
              ),
              // Protection de l'Avocat
              SwitchListTile(
                title: const Text(
                  'Protégé par l\'Avocat',
                  style: TextStyle(color: Colors.white),
                ),
                secondary: const Icon(Icons.gavel, color: Colors.blue),
                value: player.isProtectedByLawyer,
                onChanged: (bool value) {
                  setState(() {
                    player.isProtectedByLawyer = value;
                  });
                },
                activeColor: Colors.blue,
              ),
              // Percepteur
              SwitchListTile(
                title: const Text(
                  'Ciblé par le Percepteur',
                  style: TextStyle(color: Colors.white),
                ),
                secondary: const Icon(Icons.monetization_on, color: Colors.amber),
                value: player.isTargetedByCollector,
                onChanged: (bool value) {
                  setState(() {
                    player.isTargetedByCollector = value;
                  });
                },
                activeColor: Colors.amber,
              ),
              // Amoureux
              SwitchListTile(
                title: const Text(
                  'Amoureux',
                  style: TextStyle(color: Colors.white),
                ),
                secondary: const Icon(Icons.favorite, color: Colors.red),
                value: player.isInLove,
                onChanged: (bool value) {
                  setState(() {
                    player.isInLove = value;
                  });
                },
                activeColor: Colors.red,
              ),
              // Maire
              SwitchListTile(
                title: const Text(
                  'Maire',
                  style: TextStyle(color: Colors.white),
                ),
                secondary: const Icon(Icons.star, color: Colors.amber),
                value: player.isMayor,
                onChanged: (bool value) {
                  setState(() {
                    player.isMayor = value;
                  });
                },
                activeColor: Colors.amber,
              ),
              // Sacrifié
              SwitchListTile(
                title: const Text(
                  'Sacrifié',
                  style: TextStyle(color: Colors.white),
                ),
                secondary: const Icon(Icons.local_fire_department, color: Colors.red),
                value: player.isSacrified,
                onChanged: (bool value) {
                  setState(() {
                    player.isSacrified = value;
                  });
                },
                activeColor: Colors.red,
              ),
              // Idole de l'Enfant Sauvage
              SwitchListTile(
                title: const Text(
                  'Idole de l\'Enfant Sauvage',
                  style: TextStyle(color: Colors.white),
                ),
                secondary: const Icon(Icons.child_care, color: Colors.green),
                value: player.isWildChildIdol,
                onChanged: (bool value) {
                  setState(() {
                    player.isWildChildIdol = value;
                  });
                },
                activeColor: Colors.green,
              ),
              // Attaqué cette nuit
              SwitchListTile(
                title: const Text(
                  'Attaqué cette nuit',
                  style: TextStyle(color: Colors.white),
                ),
                secondary: const Icon(Icons.warning, color: Colors.orange),
                value: player.wasAttackedTonight,
                onChanged: (bool value) {
                  setState(() {
                    player.wasAttackedTonight = value;
                  });
                },
                activeColor: Colors.orange,
              ),
              // Choisi par le boulanger
              SwitchListTile(
                title: const Text(
                  'Choisi par le boulanger',
                  style: TextStyle(color: Colors.white),
                ),
                secondary: const Icon(Icons.bakery_dining, color: Colors.brown),
                value: player.isChosenByBaker,
                onChanged: (bool value) {
                  setState(() {
                    player.isChosenByBaker = value;
                  });
                },
                activeColor: Colors.brown,
              ),
              // Choisi par le corbeau
              SwitchListTile(
                title: const Text(
                  'Choisi par le corbeau',
                  style: TextStyle(color: Colors.white),
                ),
                secondary: const Icon(Icons.flutter_dash, color: Colors.grey),
                value: player.isAccusedByRaven,
                onChanged: (bool value) {
                  setState(() {
                    player.isAccusedByRaven = value;
                  });
                },
                activeColor: Colors.grey,
              ),
              // Accusé par vote
              SwitchListTile(
                title: const Text(
                  'Accusé par vote',
                  style: TextStyle(color: Colors.white),
                ),
                secondary: const Icon(Icons.how_to_vote, color: Colors.orange),
                value: player.isAccusedByVote,
                onChanged: (bool value) {
                  setState(() {
                    player.isAccusedByVote = value;
                  });
                },
                activeColor: Colors.orange,
              ),
              // Seconde chance
              SwitchListTile(
                title: const Text(
                  'Seconde chance',
                  style: TextStyle(color: Colors.white),
                ),
                secondary: const Icon(Icons.replay_circle_filled, color: Colors.green),
                value: player.secondChance,
                onChanged: (bool value) {
                  setState(() {
                    player.secondChance = value;
                  });
                },
                activeColor: Colors.green,
              ),
              const Divider(color: Colors.amber),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Fermer', style: TextStyle(color: Colors.amber)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}