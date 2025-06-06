import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/role_manager.dart';

class GameInfoDialog extends StatelessWidget {
  final Game game;

  const GameInfoDialog({super.key, required this.game});

  static Future<void> show(BuildContext context, Game game) {
    return showDialog(
      context: context,
      builder: (context) => GameInfoDialog(game: game),
    );
  }

  Map<String, int> _countRoles() {
    final roleCounts = <String, int>{};
    for (final player in game.players) {
      roleCounts[player.role] = (roleCounts[player.role] ?? 0) + 1;
    }
    return roleCounts;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.amber),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleCounts = _countRoles();

    return AlertDialog(
      backgroundColor: Colors.black87,
      title: const Text(
        'Informations de la partie',
        style: TextStyle(color: Colors.amber),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rôles en jeu :',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...game.activeRoles.map((role) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    RoleManager.getRoleEmoji(role),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$role (${roleCounts[role] ?? 0})',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            const Text(
              'État des potions :',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.healing, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Potion de soin : ${game.healPotionUsed ? "Utilisée" : "Disponible"}',
                  style: TextStyle(
                    color: game.healPotionUsed ? Colors.grey : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.dangerous, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Potion de mort : ${game.deathPotionUsed ? "Utilisée" : "Disponible"}',
                  style: TextStyle(
                    color: game.deathPotionUsed ? Colors.grey : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Fermer', style: TextStyle(color: Colors.amber)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}