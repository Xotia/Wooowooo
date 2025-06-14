import 'package:flutter/material.dart';
import '../services/documentation_service.dart';
import '../constants/role_emojis.dart';
import 'role_details_screen.dart';

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentation des Rôles'),
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
          child: FutureBuilder<List<String>>(
            future: DocumentationService.getAllRoles(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erreur lors du chargement des rôles',
                    style: TextStyle(color: Colors.red[300]),
                  ),
                );
              }

              final roles = snapshot.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: roles.length,
                itemBuilder: (context, index) {
                  final role = roles[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    color: Colors.black87,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Text(
                          RoleEmojis.getEmoji(role),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        role,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoleDetailsScreen(roleName: role),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}