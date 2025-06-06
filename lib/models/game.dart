import 'player.dart';

enum DayPhase { night, day }

class Game {
  final List<Player> players;
  final List<String> activeRoles; // Nouvelle liste des rôles en jeu
  int alivePlayers;
  int deadPlayers;
  int currentDay;
  DayPhase currentPhase;
  bool healPotionUsed;
  bool deathPotionUsed;

  Game({
    required this.players,
    List<String>? activeRoles,
  })  : activeRoles = activeRoles ?? [],
        alivePlayers = players.length,
        deadPlayers = 0,
        currentDay = 0, // On commence au jour 0
        currentPhase = DayPhase.night,
        healPotionUsed = false,
        deathPotionUsed = false;

  Map<String, dynamic> toJson() {
    return {
      'players': players.map((p) => p.toJson()).toList(),
      'activeRoles': activeRoles,
      'alivePlayers': alivePlayers,
      'deadPlayers': deadPlayers,
      'currentDay': currentDay,
      'currentPhase': currentPhase.toString(),
      'healPotionUsed': healPotionUsed,
      'deathPotionUsed': deathPotionUsed,
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      players: (json['players'] as List)
          .map((p) => Player.fromJson(p))
          .toList(),
      activeRoles: List<String>.from(json['activeRoles'] ?? []),
    )
      ..alivePlayers = json['alivePlayers']
      ..deadPlayers = json['deadPlayers']
      ..currentDay = json['currentDay']
      ..currentPhase = DayPhase.values.firstWhere(
          (e) => e.toString() == json['currentPhase']);
  }
}