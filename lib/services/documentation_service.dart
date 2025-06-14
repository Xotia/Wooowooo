import 'dart:convert';
import 'package:flutter/services.dart';

class RoleInfo {
  final String name;
  final String description;
  final String resume;

  RoleInfo({
    required this.name,
    required this.description,
    required this.resume,
  });

  factory RoleInfo.fromJson(Map<String, dynamic> json) {
    return RoleInfo(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      resume: json['resume'] ?? '',
    );
  }
}

class DocumentationService {
  static Future<List<String>> getAllRoles() async {
    try {
      final String roleListString = await rootBundle.loadString('assets/ressources/role_list_fr.json');
      final Map<String, dynamic> roleList = json.decode(roleListString);
      final List<String> allRoles = List<String>.from(roleList['All'] ?? []);
      return allRoles..sort(); // Trier les rôles par ordre alphabétique
    } catch (e) {
      print('Erreur lors du chargement des rôles: $e');
      return [];
    }
  }

  static Future<RoleInfo?> getRoleInfo(String roleName) async {
    try {
      // Convertir le nom du rôle pour correspondre au format du fichier
      String fileName = roleName.toLowerCase();
      final String jsonString = await rootBundle.loadString('assets/ressources/fiche/$fileName.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return RoleInfo.fromJson(jsonData);
    } catch (e) {
      print('Erreur lors du chargement des informations du rôle $roleName: $e');
      return null;
    }
  }
}