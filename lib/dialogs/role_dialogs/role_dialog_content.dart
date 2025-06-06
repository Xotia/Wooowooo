import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../models/game.dart';

mixin RoleDialogContent<T extends StatefulWidget> on State<T> {
  Game get game;
  String get currentRole;

  // Fonction utilitaire pour convertir le nom du rôle en nom de fichier
  String _getRoleImagePath(String role) {
    // Conversion en minuscules et gestion des cas spéciaux
    switch (role) {
      case "Loups":
        return "loup garou";
      case "Soeurs":
        return "soeur";
      case "Frères":
        return "frère";
      case "L'Idiot du Village":
      case "Idiot du Village":
        return "idiot du village";
      case "Mère Grand":
        return "mère grand";
      case "Chaperon Rouge":
        return "chaperon rouge";
      case "Enfant Sauvage":
        return "enfant sauvage";
      case "Grand Méchant Loup":
        return "grand méchant loup";
      case "Loup Noir":
        return "loup noir";
      case "Loup Blanc":
        return "loup blanc";
      case "Petite Fille":
        return "petite fille";
      case "Souffre-douleur":
        return "souffre-douleur";
      default:
        // Pour tous les autres rôles, conversion simple en minuscules
        // Par exemple: Voyante -> voyante, Sorcière -> sorcière
        return role.toLowerCase();
    }
  }

  List<Player> getPlayersWithRole(String role) {
    return game.players
        .where((player) => player.role == role && player.isAlive)
        .toList();
  }

  List<Player> getAlivePlayers() {
    return game.players
        .where((player) => player.isAlive)
        .toList();
  }

  Widget buildPlayerSelector({
    required String label,
    required void Function(Player?) onSelected,
    bool excludeSelected = false,
    List<Player>? selectedPlayers,
  }) {
    var availablePlayers = getAlivePlayers();
    if (excludeSelected && selectedPlayers != null) {
      availablePlayers = availablePlayers
          .where((p) => !selectedPlayers.contains(p))
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Player>(
          dropdownColor: Colors.black87,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber),
            ),
          ),
          items: availablePlayers.map((player) {
            return DropdownMenuItem(
              value: player,
              child: Text(
                player.name,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: onSelected,
        ),
      ],
    );
  }

  // Méthodes de construction des dialogues spécifiques aux rôles
  Widget buildCupidonDialog(List<Player> playersWithRole) {
    Player? firstLover;
    Player? secondLover;

    return StatefulBuilder(
      builder: (context, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (playersWithRole.isNotEmpty) ...[
            Text(
              '${playersWithRole.first.name} est Cupidon',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
          ],
          buildPlayerSelector(
            label: 'Choisissez le premier amoureux',
            onSelected: (player) {
              setState(() {
                firstLover = player;
              });
            },
          ),
          const SizedBox(height: 16),
          buildPlayerSelector(
            label: 'Choisissez le second amoureux',
            onSelected: (player) {
              setState(() {
                secondLover = player;
              });
            },
            excludeSelected: true,
            selectedPlayers: firstLover != null ? [firstLover!] : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: (firstLover != null && secondLover != null)
                ? () {
                    setState(() {
                      firstLover!.isInLove = true;
                      secondLover!.isInLove = true;
                    });
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Widget buildFratrieDialog(List<Player> playersWithRole) {
    if (playersWithRole.isEmpty) {
      return const Text('Aucun frère en vie', style: TextStyle(color: Colors.white));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Les frères en vie sont :', style: TextStyle(color: Colors.white)),
        ...playersWithRole.map((p) => Text(p.name, style: TextStyle(color: Colors.amber))),
      ],
    );
  }

  Widget buildSistersDialog(List<Player> playersWithRole) {
    if (playersWithRole.isEmpty) {
      return const Text('Aucune sœur en vie', style: TextStyle(color: Colors.white));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Les sœurs en vie sont :', style: TextStyle(color: Colors.white)),
        ...playersWithRole.map((p) => Text(p.name, style: TextStyle(color: Colors.amber))),
      ],
    );
  }

  Widget buildWildChildDialog(List<Player> playersWithRole) {
    Player? selectedIdol;

    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Text(
            '${playersWithRole.first.name} est l\'Enfant Sauvage',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          buildPlayerSelector(
            label: 'Choisir son idole',
            onSelected: (player) {
              setState(() => selectedIdol = player);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: selectedIdol != null
                ? () {
                    selectedIdol!.isWildChildIdol = true;
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Widget buildWendigoDialog(List<Player> playersWithRole) {
    String? selectedRole;
    final roles = ['Villageois', 'Loups'];

    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Text(
            '${playersWithRole.first.name} est le Wendigo',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Choisir son nouveau rôle',
              labelStyle: TextStyle(color: Colors.amber),
            ),
            dropdownColor: Colors.black87,
            items: roles.map((role) => DropdownMenuItem(
              value: role,
              child: Text(role, style: const TextStyle(color: Colors.white)),
            )).toList(),
            onChanged: (value) {
              setState(() => selectedRole = value);
            },
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: selectedRole != null
                ? () {
                    final player = playersWithRole.first;
                    player.role = selectedRole!;
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Widget buildCollectorDialog(List<Player> playersWithRole) {
    Player? selectedTarget;

    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Text(
            '${playersWithRole.first.name} est le Percepteur',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          buildPlayerSelector(
            label: 'Choisir sa cible',
            onSelected: (player) {
              setState(() => selectedTarget = player);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: selectedTarget != null
                ? () {
                    selectedTarget!.isTargetedByCollector = true;
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Widget buildServantDialog(List<Player> playersWithRole) {
    Player? selectedTarget;
    final servant = playersWithRole.first;

    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Text(
            '${servant.name} est $currentRole',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Choisissez le joueur pour qui vous voulez vous sacrifier',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          buildPlayerSelector(
            label: 'Choisir le joueur à protéger',
            onSelected: (player) {
              setState(() => selectedTarget = player);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: selectedTarget != null
                ? () {
                    selectedTarget!.isSacrified = true;
                    selectedTarget!.sacrificedBy = servant.name;
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Widget buildSbireDialog(List<Player> playersWithRole) {
    return Column(
      children: [
        Text(
          '${playersWithRole.first.name} est le Sbire',
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          'Les loups doivent lever la main pour que le sbire puisse les identifier.',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildWolfDialog(List<Player> playersWithRole) {
    Player? selectedVictim;
    final isFirstNight = game.currentDay == 0;

    return StatefulBuilder(
      builder: (context, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Les loups doivent se réveiller :',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          ...playersWithRole.map((player) => Text(
            player.name,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )),
          const SizedBox(height: 24),
          if (!isFirstNight) ...[
            const Text(
              'Les loups doivent désigner le joueur qu\'ils souhaitent dévorer',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            buildPlayerSelector(
              label: 'Choisir la victime',
              onSelected: (player) {
                setState(() => selectedVictim = player);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectedVictim != null
                  ? () {
                      // Réinitialiser les attaques précédentes
                      for (final player in getAlivePlayers()) {
                        player.wasAttackedTonight = false;
                      }
                      selectedVictim!.wasAttackedTonight = true;
                      Navigator.of(context).pop();
                    }
                  : null,
              child: const Text('Valider'),
            ),
          ] else ...[
            const Text(
              'Première nuit : Les loups se découvrent les uns les autres.',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget buildShepherdDialog(List<Player> playersWithRole) {
    return Column(
      children: [
        Text(
          '${playersWithRole.first.name} est le Berger',
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          'Si les loups sont près du berger, le maître du jeu doit faire aboyer les chiens.',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildMayorDialog(List<Player> playersWithRole) {
    Player? selectedMayor;

    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          buildPlayerSelector(
            label: 'Choisir le maire',
            onSelected: (player) {
              setState(() => selectedMayor = player);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: selectedMayor != null
                ? () {
                    // Réinitialiser l'ancien maire s'il y en a un
                    for (final player in getAlivePlayers()) {
                      player.isMayor = false;
                    }
                    selectedMayor!.isMayor = true;
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Widget buildSeerDialog(List<Player> playersWithRole) {
    Player? selectedPlayer;

    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Text(
            '${playersWithRole.first.name} est la Voyante',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Désigne un joueur pour voir son rôle.',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          buildPlayerSelector(
            label: 'Choisir un joueur',
            onSelected: (player) {
              setState(() => selectedPlayer = player);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: selectedPlayer != null
                ? () {
                    final playerToReveal = selectedPlayer!;
                    Navigator.of(context).pop();
                    
                    // Attendre un peu avant d'afficher le nouveau dialogue
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (!context.mounted) return;
                      
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.black87,
                          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.8,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'Rôle de ${playerToReveal.name}',
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Text(
                                          playerToReveal.role,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Image.asset(
                                          'assets/ressources/fiche/img/${_getRoleImagePath(playerToReveal.role)}.png',
                                          height: MediaQuery.of(context).size.height * 0.6,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            print('⚠️ Erreur lors du chargement de l\'image:');
                                            print('🔍 Chemin tenté: assets/ressources/fiche/img/${_getRoleImagePath(playerToReveal.role)}.png');
                                            print('🎭 Rôle du joueur: ${playerToReveal.role}');
                                            print('❌ Erreur: $error');
                                            print('📜 Stack trace: $stackTrace');
                                            return const Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 60,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text(
                                      'Fermer',
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
                  }
                : null,
            child: const Text('Voir le rôle'),
          ),
        ],
      ),
    );
  }

  Widget buildNecromancerDialog(List<Player> playersWithRole) {
    return Column(
      children: [
        Text(
          '${playersWithRole.first.name} est le Nécromancien',
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tour du Nécromancien',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildGuardDialog(List<Player> playersWithRole) {
    Player? selectedPlayer;

    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Text(
            '${playersWithRole.first.name} est le Garde',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          buildPlayerSelector(
            label: 'Choisir un joueur à protéger',
            onSelected: (player) {
              setState(() => selectedPlayer = player);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: selectedPlayer != null
                ? () {
                    // Réinitialiser les protections existantes
                    for (final player in getAlivePlayers()) {
                      player.isProtectedByGuard = false;
                    }
                    selectedPlayer!.isProtectedByGuard = true;
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Widget buildLawyerDialog(List<Player> playersWithRole) {
    Player? selectedPlayer;

    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Text(
            '${playersWithRole.first.name} est l\'Avocat',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          buildPlayerSelector(
            label: 'Choisir un joueur à protéger',
            onSelected: (player) {
              setState(() => selectedPlayer = player);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: selectedPlayer != null
                ? () {
                    // Réinitialiser les protections existantes
                    for (final player in getAlivePlayers()) {
                      player.isProtectedByLawyer = false;
                    }
                    selectedPlayer!.isProtectedByLawyer = true;
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Widget buildFoxDialog(List<Player> playersWithRole) {
    List<Player> selectedPlayers = [];

    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Text(
            '${playersWithRole.first.name} est le Renard',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < 3; i++) 
            Column(
              children: [
                buildPlayerSelector(
                  label: 'Choisir le joueur ${i + 1}',
                  onSelected: (player) {
                    setState(() {
                      if (player != null) {
                        if (selectedPlayers.length > i) {
                          selectedPlayers[i] = player;
                        } else {
                          selectedPlayers.add(player);
                        }
                      }
                    });
                  },
                  excludeSelected: true,
                  selectedPlayers: selectedPlayers,
                ),
                const SizedBox(height: 8),
              ],
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: selectedPlayers.length == 3
                ? () {
                    final hasWolf = selectedPlayers.any((p) => p.role == 'Loups');
                    if (hasWolf) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.black87,
                          title: const Text(
                            'Résultat du reniflement',
                            style: TextStyle(color: Colors.amber),
                          ),
                          content: const Text(
                            'Au moins un des joueurs reniflés est un loup !',
                            style: TextStyle(color: Colors.white),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Fermer', style: TextStyle(color: Colors.amber)),
                            ),
                          ],
                        ),
                      );
                    } else {
                      final foxPlayer = playersWithRole.first;
                      foxPlayer.role = 'Villageois';
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.black87,
                          title: const Text(
                            'Résultat du reniflement',
                            style: TextStyle(color: Colors.amber),
                          ),
                          content: const Text(
                            'Aucun loup parmi les joueurs reniflés. Le renard devient villageois.',
                            style: TextStyle(color: Colors.white),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Fermer', style: TextStyle(color: Colors.amber)),
                            ),
                          ],
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Widget buildBakerDialog(List<Player> playersWithRole) {
    Player? selectedPlayer;

    return StatefulBuilder(
      builder: (context, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (playersWithRole.isNotEmpty) ...[
            Text(
              '${playersWithRole.first.name} est le Boulanger',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
          ],
          buildPlayerSelector(
            label: 'Choisir un joueur à qui livrer du pain',
            onSelected: (player) {
              setState(() => selectedPlayer = player);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: selectedPlayer != null
                ? () {
                    setState(() {
                      // Réinitialiser les livraisons précédentes
                      for (final player in getAlivePlayers()) {
                        player.isChosenByBaker = false;
                      }
                      // Livrer le pain au joueur sélectionné
                      selectedPlayer!.isChosenByBaker = true;
                    });
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Livrer le pain'),
          ),
        ],
      ),
    );
  }

  Widget buildRavenDialog(List<Player> playersWithRole) {
    Player? selectedPlayer;

    return StatefulBuilder(
      builder: (context, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (playersWithRole.isNotEmpty) ...[
            Text(
              '${playersWithRole.first.name} est le Corbeau',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
          ],
          buildPlayerSelector(
            label: 'Choisir un joueur à accuser',
            onSelected: (player) {
              setState(() => selectedPlayer = player);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: selectedPlayer != null
                ? () {
                    setState(() {
                      // Réinitialiser les accusations précédentes
                      for (final player in getAlivePlayers()) {
                        player.isAccusedByRaven = false;
                      }
                      // Accuser le joueur sélectionné
                      selectedPlayer!.isAccusedByRaven = true;
                    });
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Accuser'),
          ),
        ],
      ),
    );
  }

  Widget buildWitchDialog(List<Player> playersWithRole) {
    Player? selectedPlayerToKill;
    // Trouver le joueur qui a été attaqué cette nuit
    final attackedPlayer = game.players.firstWhere(
      (player) => player.wasAttackedTonight,
      orElse: () => game.players.first,
    );

    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          if (playersWithRole.isNotEmpty) ...[
            Text(
              '${playersWithRole.first.name} est la Sorcière',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
          ],
          
          // Potion de soin
          if (!game.healPotionUsed && attackedPlayer.wasAttackedTonight) ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.healing, color: Colors.white),
              label: const Text('Utiliser la potion de soin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.black87,
                    title: const Text(
                      'Utiliser la potion de soin ?',
                      style: TextStyle(color: Colors.amber),
                    ),
                    content: Text(
                      'Voulez-vous sauver ${attackedPlayer.name} ?',
                      style: const TextStyle(color: Colors.white),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Non', style: TextStyle(color: Colors.white70)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Oui'),
                        onPressed: () {
                          setState(() {
                            attackedPlayer.wasAttackedTonight = false;
                            attackedPlayer.secondChance = true;
                            game.healPotionUsed = true;
                          });
                          Navigator.pop(context); // Ferme le dialogue de confirmation
                          Navigator.pop(context); // Ferme le dialogue de la sorcière
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],

          // Potion de mort
          if (!game.deathPotionUsed) ...[
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    backgroundColor: Colors.black87,
                    title: const Text(
                      'Choisir la cible',
                      style: TextStyle(color: Colors.amber),
                    ),
                    content: StatefulBuilder(
                      builder: (context, setDialogState) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Qui voulez-vous empoisonner ?',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.amber),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Player>(
                                value: selectedPlayerToKill,
                                dropdownColor: Colors.black87,
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
                                isExpanded: true,
                                hint: const Text(
                                  'Choisir la victime',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                items: game.players
                                    .where((p) => p.isAlive)
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
                                  setDialogState(() {
                                    selectedPlayerToKill = player;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: selectedPlayerToKill != null
                            ? () {
                                selectedPlayerToKill!.wasAttackedTonight = true;
                                selectedPlayerToKill!.tryToKillPlayer(context);
                                game.deathPotionUsed = true;
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            : null,
                        child: const Text('Empoisonner'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.dangerous, color: Colors.white),
              label: const Text('Utiliser la potion de mort'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],

          if (game.healPotionUsed && game.deathPotionUsed) ...[
            const Text(
              'Vous avez utilisé vos deux potions',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget buildForumDialog(List<Player> players) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.groups,
          color: Colors.amber,
          size: 48,
        ),
        const SizedBox(height: 16),
        const Text(
          'C\'est l\'heure du forum !',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Les habitants du village sont invités à se lever pour se concerter en petit comité avec leurs voisins de confiance.',
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const Text(
          'Joueurs en vie :',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...getAlivePlayers().map((player) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            player.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: player.isMayor ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        )),
        if (getAlivePlayers().any((p) => p.isMayor)) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Maire : ${getAlivePlayers().firstWhere((p) => p.isMayor).name}',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}