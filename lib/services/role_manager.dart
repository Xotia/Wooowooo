import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';
import '../constants/role_emojis.dart';

class RoleManager {
  static Map<String, dynamic> characterList = {};
  static Map<String, dynamic> roleList = {};
  static Map<String, String> translations = {};

  static Future<void> initialize() async {
    final characterListString = await rootBundle.loadString(
        'assets/ressources/character_list_by_player_number_hard.json');
    final roleListString =
        await rootBundle.loadString('assets/ressources/role_list_fr.json');
    final translationString =
        await rootBundle.loadString('assets/ressources/translation_FR.json');

    characterList = jsonDecode(characterListString);
    roleList = jsonDecode(roleListString);
    translations = Map<String, String>.from(jsonDecode(translationString));
  }

  static List<String> distributeRoles(int numberOfPlayers) {
    List<String> roles = [];
    final random = Random();

    void addRole(String role, int count) {
      for (int i = 0; i < count; i++) {
        roles.add(role);
      }
    }

    String getRandomRole(String key) {
      List<String> availableRoles = List<String>.from(roleList[key]);
      availableRoles.shuffle(random);
      
      for (String role in availableRoles) {
        if (role == 'Chaperon Rouge' && !roles.contains('Chasseur')) {
          continue;
        }
        if (!roles.contains(role)) {
          return role;
        }
      }
      throw Exception('No available role found for category $key');
    }

    // Ajout des rôles fixes
    final playerConfig = characterList[numberOfPlayers.toString()];
    addRole('Loups', playerConfig['Loups']);
    addRole('Villageois', playerConfig['Villageois']);
    addRole('Nécromancien', playerConfig['Necromancien']);
    addRole('Ange', playerConfig['Ange']);
    addRole('Sbire', playerConfig['Sbire']);
    addRole('Enfant Sauvage', playerConfig['Enfant Sauvage']);

    // Ajout des rôles aléatoires
    for (int i = 0; i < playerConfig['Random']; i++) {
      roles.add(getRandomRole('Random'));
    }
    for (int i = 0; i < playerConfig['Ecarte']; i++) {
      roles.add(getRandomRole('Ecarte'));
    }
    for (int i = 0; i < playerConfig['Info']; i++) {
      roles.add(getRandomRole('Info'));
    }
    for (int i = 0; i < playerConfig['Protecteur']; i++) {
      roles.add(getRandomRole('Protecteur'));
    }

    // Mélanger la liste des rôles disponibles
    roles.shuffle(random);
    
    // Si "Idiot du Village" est dans la liste, on met isDumb à true pour ce joueur
    final assignedRoles = roles.sublist(0, numberOfPlayers);
    for (var i = 0; i < assignedRoles.length; i++) {
      if (assignedRoles[i] == 'Idiot du Village') {
        // Le joueur correspondant recevra isDumb = true lors de l'attribution
        assignedRoles[i] = 'Idiot du Village';
      }
    }
    
    return assignedRoles;
  }

  static List<String> getAllRoles() {
    return List<String>.from(roleList['All'] ?? []);
  }

  static String getRoleEmoji(String role) {
    return RoleEmojis.getEmoji(role);
  }

  static String getTranslation(String key) {
    return translations[key] ?? key;
  }
}