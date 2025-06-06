import 'package:flutter/material.dart';
import 'game.dart';

class Player {
  String name;
  String role;
  bool isAlive;
  bool isProtectedByGuard;
  bool isProtectedByLawyer;
  bool isTargetedByCollector;
  bool isInLove;
  bool isMayor;
  bool isWildChildIdol;
  bool isSacrified;
  String sacrificedBy; // Nom du joueur qui se sacrifie
  bool wasAttackedTonight;
  bool isChosenByBaker;
  bool isAccusedByRaven;
  bool isAccusedByVote;
  bool secondChance;
  bool isDumb;  // Nouvel attribut pour l'idiot du village
  late Game game;

  Player({
    required this.name,
    required this.role,
    this.isAlive = true,
    this.isProtectedByGuard = false,
    this.isProtectedByLawyer = false,
    this.isTargetedByCollector = false,
    this.isInLove = false,
    this.isMayor = false,
    this.isWildChildIdol = false,
    this.isSacrified = false,
    this.sacrificedBy = '',
    this.wasAttackedTonight = false,
    this.isChosenByBaker = false,
    this.isAccusedByRaven = false,
    this.isAccusedByVote = false,
    this.secondChance = false,
    this.isDumb = false,  // Initialisation par défaut
  });

  void setGame(Game gameInstance) {
    game = gameInstance;
  }

  void killPlayer() {
    isAlive = false;
    isMayor = false;  // Le maire perd son statut à sa mort
  }

  void tryToKillPlayer(BuildContext context) {
    // Protection de l'idiot du village lors d'un vote
    if (isAccusedByVote && isDumb) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Idiot du Village',
            style: TextStyle(color: Colors.amber),
          ),
          content: Text(
            '$name est l\'idiot du village, il a finalement été épargné après le vote.',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer', style: TextStyle(color: Colors.amber)),
            ),
          ],
        ),
      );
      isAccusedByVote = false;
      isDumb = false;
      return;
    }

    // Protection du Garde
    if (isProtectedByGuard) {
      // Ne pas réinitialiser wasAttackedTonight ici
      // wasAttackedTonight reste à true pour que le message du matin indique l'attaque
      isProtectedByGuard = false;
      return;
    }

    // Protection de l'Avocat
    if (isProtectedByLawyer) {
      isProtectedByLawyer = false;
      isAccusedByVote = false;
      return;
    }

    // Seconde chance (Mère Grand ou Sorcière)
    if (secondChance) {
      secondChance = false;
      wasAttackedTonight = false;
      return;
    }

    // Si le joueur a un protecteur (majordome/servante)
    if (isSacrified && sacrificedBy.isNotEmpty) {
      final protector = game.players.firstWhere(
        (p) => p.name == sacrificedBy && p.isAlive,
        orElse: () => Player(name: '', role: ''),
      );
      if (protector.name.isNotEmpty) {
        protector.tryToKillPlayer(context);
        isSacrified = false;
        sacrificedBy = '';
        return;
      }
    }

    // Protection du Chasseur pour le Chaperon Rouge
    if (role == 'Chaperon Rouge') {
      final hunter = getOtherPlayers()
          .firstWhere((p) => p.role == 'Chasseur' && p.isAlive,
              orElse: () => Player(name: '', role: ''));
      if (hunter.name.isNotEmpty) {
        wasAttackedTonight = false;
        return;
      }
    }

    // Chasseur
    if (role == 'Chasseur') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Pouvoir du Chasseur',
            style: TextStyle(color: Colors.amber),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              Player? selectedTarget;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Le chasseur doit désigner un autre joueur à tuer avant de mourir',
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
                        items: getOtherPlayers()
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
                        onChanged: (Player? selected) {
                          setState(() => selectedTarget = selected);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: selectedTarget != null
                        ? () {
                            selectedTarget!.tryToKillPlayer(context);
                            killPlayer(); // Le chasseur meurt après
                            Navigator.pop(context);
                          }
                        : null,
                    child: const Text('Tirer'),
                  ),
                ],
              );
            },
          ),
        ),
      );
      return;
    }

    // Les amoureux meurent ensemble
    if (isInLove) {
      final lover = getOtherPlayers()
          .firstWhere((p) => p.isInLove,
              orElse: () => Player(name: '', role: ''));
      if (lover.name.isNotEmpty) {
        killPlayer();
        lover.killPlayer();
        return;
      }
    }

    // Idole de l'Enfant Sauvage
    if (isWildChildIdol) {
      final wildChild = getOtherPlayers()
          .firstWhere((p) => p.role == 'Enfant Sauvage' && p.isAlive,
              orElse: () => Player(name: '', role: ''));
      if (wildChild.name.isNotEmpty) {
        killPlayer();
        wildChild.role = 'Loups';
        return;
      }
    }

    // Si aucune protection n'a fonctionné, le joueur meurt
    killPlayer();
  }

  List<Player> getOtherPlayers() {
    // Cette méthode doit être implémentée pour retourner la liste des autres joueurs
    // On peut l'obtenir depuis l'instance de Game
    return game.players.where((p) => p != this).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'isAlive': isAlive,
      'isProtectedByGuard': isProtectedByGuard,
      'isProtectedByLawyer': isProtectedByLawyer,
      'isTargetedByCollector': isTargetedByCollector,
      'isInLove': isInLove,
      'isMayor': isMayor,
      'isWildChildIdol': isWildChildIdol,
      'wasAttackedTonight': wasAttackedTonight,
      'isSacrified': isSacrified,
      'sacrificedBy': sacrificedBy,
      'isChosenByBaker': isChosenByBaker,
      'isAccusedByRaven': isAccusedByRaven,
      'isAccusedByVote': isAccusedByVote,
      'secondChance': secondChance,
      'isDumb': isDumb,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'],
      role: json['role'],
      isAlive: json['isAlive'],
      isProtectedByGuard: json['isProtectedByGuard'],
      isProtectedByLawyer: json['isProtectedByLawyer'],
      isTargetedByCollector: json['isTargetedByCollector'],
      isInLove: json['isInLove'],
      isMayor: json['isMayor'],
      isWildChildIdol: json['isWildChildIdol'],
      wasAttackedTonight: json['wasAttackedTonight'],
      isSacrified: json['isSacrified'],
      sacrificedBy: json['sacrificedBy'] ?? '',
      isChosenByBaker: json['isChosenByBaker'] ?? false,
      isAccusedByRaven: json['isAccusedByRaven'] ?? false,
      isAccusedByVote: json['isAccusedByVote'] ?? false,
      secondChance: json['secondChance'] ?? false,
      isDumb: json['isDumb'] ?? false,
    );
  }
}