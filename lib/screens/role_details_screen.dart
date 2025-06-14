import 'package:flutter/material.dart';
import '../services/documentation_service.dart';
import '../constants/role_emojis.dart';

class RoleDetailsScreen extends StatelessWidget {
  final String roleName;

  const RoleDetailsScreen({super.key, required this.roleName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roleName),
        backgroundColor: Colors.black87,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/${(DateTime.now().millisecond % 11) + 1}.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.3),
              ],
            ),
          ),
          child: FutureBuilder<RoleInfo?>(
            future: DocumentationService.getRoleInfo(roleName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || snapshot.data == null) {
                return Center(
                  child: Text(
                    'Erreur lors du chargement des informations du rôle',
                    style: TextStyle(color: Colors.red[300]),
                  ),
                );
              }

              final roleInfo = snapshot.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec l'emoji et le nom du rôle
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.amber,
                          radius: 30,
                          child: Text(
                            RoleEmojis.getEmoji(roleName),
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            roleInfo.name,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Image du rôle (si disponible)
                    Image.asset(
                      'assets/ressources/fiche/img/${roleName.toLowerCase()}.png',
                      errorBuilder: (context, error, stackTrace) {
                        // Si l'image n'existe pas, on ne montre rien
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 24),

                    // Résumé du rôle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Text(
                        roleInfo.resume,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description détaillée
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        roleInfo.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}