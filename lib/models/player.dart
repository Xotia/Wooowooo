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
  bool wasTransformedIntoWolf; // Nouvel attribut pour suivre la transformation en loup
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
    this.wasTransformedIntoWolf = false,
  });

  void setGame(Game gameInstance) {
    game = gameInstance;
  }

  void killPlayer([BuildContext? context]) {
    // Death message for village vote
    if (context != null && isAccusedByVote) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Verdict du Village',
            style: TextStyle(color: Colors.amber),
          ),
          content: Text(
            'Le village a décidé d\'éliminer $name.\nSon rôle était : $role',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fermer', style: TextStyle(color: Colors.amber)),
            ),
          ],
        ),
      );
    }

    // Gestion du Percepteur si le joueur qui meurt était sa cible et que le Percepteur est vivant
    if (isTargetedByCollector) {
      final collector = game.players.firstWhere(
        (p) => p.role == 'Percepteur' && p.isAlive,
        orElse: () => Player(name: '', role: ''),
      );
      if (collector.name.isNotEmpty) {
        // Gérer les attributs spéciaux selon le rôle hérité
        if (role == 'Idiot du Village') {
          collector.isDumb = true;
        } else if (role == 'Mère Grand') {
          collector.secondChance = true;
        }
        
        // Show death and inheritance message
        if (context != null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              backgroundColor: Colors.black87,
              title: const Text(
                'Héritage du Percepteur',
                style: TextStyle(color: Colors.amber),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$name est mort(e).',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Le Percepteur ${collector.name} hérite de son rôle : $role',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Fermer', style: TextStyle(color: Colors.amber)),
                ),
              ],
            ),
          );
        }
        collector.role = role;
      }
    }

    isAlive = false;
    isMayor = false;  // Le maire perd son statut à sa mort
    game.deadPlayers++; // Incrémenter le compteur de morts total
    
    // Incrémenter le compteur de loups morts si le joueur est un loup
    if (role == 'Loups' || role == 'Grand Méchant Loup' || role == 'Loup Noir' || role == 'Loup Blanc') {
      game.deadWolves++;
    }
    
    
  }

  Future<void> tryToKillPlayer(BuildContext context) async {
    // Protection de l'idiot du village lors d'un vote
    if (isAccusedByVote && isDumb) {
      await showDialog(
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

    // Vérification du rôle Ange
    if (role == 'Ange' && isAccusedByVote && game.currentDay == 1) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Victoire de l\'Ange',
            style: TextStyle(color: Colors.amber),
          ),
          content: Text(
            '$name était l\'Ange et est mort lors du premier vote du village. $name remporte la partie !',
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
    }

    // Protection du Garde
    if (isProtectedByGuard) {
      // Ne pas réinitialiser wasAttackedTonight ici
      // wasAttackedTonight reste à true pour que le message du matin indique l'attaque
      isProtectedByGuard = false;
      return;
    }

    // Protection de l'Avocat
    if (isProtectedByLawyer && isAccusedByVote) {
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text(
              'Sacrifice Héroïque',
              style: TextStyle(color: Colors.amber),
            ),
            content: Text(
              '${protector.name} s\'est sacrifié(e) pour sauver $name !',
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
        protector.tryToKillPlayer(context);
        isSacrified = false;
        sacrificedBy = '';
        return;
      }
    }

    // Protection du Chasseur pour le Chaperon Rouge
    if (role == 'Chaperon Rouge' && wasAttackedTonight == true) {
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
        barrierDismissible: false,
        builder: (dialogContext) => _HunterDialog(
          onPlayerSelected: (selectedPlayer) {
            // Fermer le dialogue de sélection
            Navigator.of(dialogContext).pop();
            
            if (dialogContext.mounted) {
              showDialog(
                context: dialogContext,
                barrierDismissible: false,
                builder: (confirmContext) => AlertDialog(
                  backgroundColor: Colors.black87,
                  title: const Text(
                    'Chasseur',
                    style: TextStyle(color: Colors.amber),
                  ),
                  content: Text(
                    'Le chasseur $name a tiré sur ${selectedPlayer.name} avant de mourir.\nSon rôle était : ${selectedPlayer.role}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Fermer le dialogue de confirmation
                        Navigator.of(confirmContext).pop();
                        // Exécuter les actions après la fermeture des dialogues
                        selectedPlayer.tryToKillPlayer(context);
                        killPlayer(context);
                      },
                      child: const Text('Fermer', style: TextStyle(color: Colors.amber)),
                    ),
                  ],
                ),
              );
            }
          },
          getPlayers: () => getOtherPlayers().where((player) => player.isAlive).toList(),
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
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text(
              'Amoureux Tragiques',
              style: TextStyle(color: Colors.red),
            ),
            content: Text(
              '$name est mort(e). Son amoureux(se) ${lover.name} ne peut vivre sans l\'élu(e) de son cœur...',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Fermer', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        
        killPlayer(context);
        // Small delay before lover's death
        await Future.delayed(const Duration(milliseconds: 800));
        if (context.mounted) {
          lover.tryToKillPlayer(context);
        }
        return;
      }
    }

    // Idole de l'Enfant Sauvage
    if (isWildChildIdol) {
      final wildChild = getOtherPlayers()
          .firstWhere((p) => p.role == 'Enfant Sauvage' && p.isAlive,
              orElse: () => Player(name: '', role: ''));
      if (wildChild.name.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text(
              'Transformation de l\'Enfant Sauvage',
              style: TextStyle(color: Colors.amber),
            ),
            content: Text(
              'L\'idole de ${wildChild.name} ($name) est mort(e). Dans sa rage et son désespoir, l\'Enfant Sauvage rejoint les Loups-Garous !',
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
        killPlayer(context);
        wildChild.role = 'Loups';
        return;
      }
    }

    // Si aucune protection n'a fonctionné, le joueur meurt
    killPlayer(context);  // Passage du contexte ici pour afficher les messages de mort
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
      'wasTransformedIntoWolf': wasTransformedIntoWolf,
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
      wasTransformedIntoWolf: json['wasTransformedIntoWolf'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player && other.name == name && other.role == role;
  }

  @override
  int get hashCode => Object.hash(name, role);
}

class _HunterDialog extends StatefulWidget {
  final Function(Player) onPlayerSelected;
  final List<Player> Function() getPlayers;

  const _HunterDialog({
    required this.onPlayerSelected,
    required this.getPlayers,
  });

  @override
  __HunterDialogState createState() => __HunterDialogState();
}

class __HunterDialogState extends State<_HunterDialog> {
  Player? selectedTarget;

  @override
  Widget build(BuildContext context) {
    final players = widget.getPlayers();
    return AlertDialog(
      backgroundColor: Colors.black87,
      title: const Text(
        'Pouvoir du Chasseur',
        style: TextStyle(color: Colors.amber),
      ),
      content: Column(
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
              child: DropdownButton<String>(
                dropdownColor: Colors.black87,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                hint: Text(
                  selectedTarget?.name ?? 'Sélectionnez un joueur',
                  style: TextStyle(
                    color: selectedTarget != null ? Colors.white : Colors.white70,
                  ),
                ),
                value: selectedTarget?.name,
                items: players.map((Player player) {
                  return DropdownMenuItem<String>(
                    value: player.name,
                    child: Text(
                      player.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (String? name) {
                  if (name != null) {
                    final selected = players.firstWhere((p) => p.name == name);
                    setState(() {
                      selectedTarget = selected;
                    });
                  }
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
                ? () => widget.onPlayerSelected(selectedTarget!)
                : null,
            child: const Text('Tirer'),
          ),
        ],
      ),
    );
  }
}