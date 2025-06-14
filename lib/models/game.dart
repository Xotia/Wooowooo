import 'player.dart';

enum DayPhase { night, day }

class Game {
  final List<Player> players;
  final List<String> activeRoles; // Nouvelle liste des rôles en jeu
  int alivePlayers;
  int deadPlayers;
  int deadWolves; // Nouveau compteur pour les loups morts
  int currentDay;
  DayPhase currentPhase;
  bool healPotionUsed;
  bool deathPotionUsed;
  bool isWhiteWolfNight; // Pour suivre si c'est une nuit où le Loup Blanc peut agir
  bool blackWolfTransformation;  // Pour suivre si le Loup Noir a déjà utilisé son pouvoir

  Game({
    required this.players,
    List<String>? activeRoles,
  })  : activeRoles = activeRoles ?? [],
        alivePlayers = players.length,
        deadPlayers = 0,
        deadWolves = 0, // Initialisation à 0
        currentDay = 0, // On commence au jour 0
        currentPhase = DayPhase.night,
        healPotionUsed = false,
        deathPotionUsed = false,
        isWhiteWolfNight = false,
        blackWolfTransformation = false;

  Map<String, dynamic> toJson() {
    return {
      'players': players.map((p) => p.toJson()).toList(),
      'activeRoles': activeRoles,
      'alivePlayers': alivePlayers,
      'deadPlayers': deadPlayers,
      'deadWolves': deadWolves, // Ajout dans le JSON
      'currentDay': currentDay,
      'currentPhase': currentPhase.toString(),
      'healPotionUsed': healPotionUsed,
      'deathPotionUsed': deathPotionUsed,
      'isWhiteWolfNight': isWhiteWolfNight, // Ajout dans le JSON
      'blackWolfTransformation': blackWolfTransformation,
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
      ..deadWolves = json['deadWolves'] ?? 0 // Récupération depuis le JSON
      ..currentDay = json['currentDay']
      ..currentPhase = DayPhase.values.firstWhere(
          (e) => e.toString() == json['currentPhase'])
      ..isWhiteWolfNight = json['isWhiteWolfNight'] ?? false // Récupération depuis le JSON
      ..blackWolfTransformation = json['blackWolfTransformation'] ?? false; // Récupération depuis le JSON
  }

  void reset() {
    alivePlayers = players.length;
    deadPlayers = 0;
    deadWolves = 0;
    currentDay = 0;
    currentPhase = DayPhase.night;
    healPotionUsed = false;
    deathPotionUsed = false;
    isWhiteWolfNight = false;
    blackWolfTransformation = false; // Réinitialisation du pouvoir du Loup Noir
  }
}