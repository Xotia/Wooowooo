import 'package:flutter/material.dart';
import '../models/game.dart';
import 'role_dialogs/role_dialog_content.dart';

class RoleDialog extends StatefulWidget {
  final Game game;
  final String currentRole;

  const RoleDialog({
    super.key,
    required this.game,
    required this.currentRole,
  });

  static Future<void> show(BuildContext context, Game game, String role) {
    return showDialog(
      context: context,
      builder: (context) => RoleDialog(
        game: game,
        currentRole: role,
      ),
    );
  }

  @override
  State<RoleDialog> createState() => _RoleDialogState();
}

class _RoleDialogState extends State<RoleDialog> with RoleDialogContent<RoleDialog> {
  @override
  Game get game => widget.game;

  @override
  String get currentRole => widget.currentRole;

  @override
  Widget build(BuildContext context) {
    final playersWithRole = getPlayersWithRole(currentRole);

    return AlertDialog(
      backgroundColor: Colors.black87,
      title: Text(
        currentRole,
        style: const TextStyle(color: Colors.amber),
      ),
      content: SingleChildScrollView(
        child: Builder(
          builder: (context) {
            switch (currentRole) {
              case '[FORUM]':
                return buildForumDialog(game.players);
              case 'Cupidon':
                return buildCupidonDialog(playersWithRole);
              case 'Fratrie':
                return buildFratrieDialog(playersWithRole);
              case 'Soeurs':
                return buildSistersDialog(playersWithRole);
              case 'Enfant Sauvage':
                return buildWildChildDialog(playersWithRole);
              case 'Wendigo':
                return buildWendigoDialog(playersWithRole);
              case 'Percepteur':
                return buildCollectorDialog(playersWithRole);
              case 'Servante':
                return buildServantDialog(playersWithRole);
              case 'Majordome':
                return buildServantDialog(playersWithRole);
              case 'Sbire':
                return buildSbireDialog(playersWithRole);
              case 'Loups':
                return buildWolfDialog(playersWithRole);
              case 'Grand Méchant Loup':
                return buildGrandWolfDialog(playersWithRole);
              case 'Loup Blanc':
                return buildWhiteWolfDialog(playersWithRole);
              case 'Berger':
                return buildShepherdDialog(playersWithRole);
              case 'Maire':
                return buildMayorDialog(playersWithRole);
              case 'Voyante':
                return buildSeerDialog(playersWithRole);
              case 'Nécromancien':
                return buildNecromancerDialog(playersWithRole);
              case 'Garde':
                return buildGuardDialog(playersWithRole);
              case 'Avocat':
                return buildLawyerDialog(playersWithRole);
              case 'Renard':
                return buildFoxDialog(playersWithRole);
              case 'Sorcière':
                return buildWitchDialog(playersWithRole);
              case 'Boulanger':
                return buildBakerDialog(playersWithRole);
              case 'Corbeau':
                return buildRavenDialog(playersWithRole);
              case 'Loup Noir':
                return buildBlackWolfDialog(playersWithRole);
              default:
                return Text(
                  'Dialogue non implémenté pour le rôle $currentRole',
                  style: const TextStyle(color: Colors.white),
                );
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer', style: TextStyle(color: Colors.amber)),
        ),
      ],
    );
  }
}