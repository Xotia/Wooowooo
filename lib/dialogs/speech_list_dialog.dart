import 'package:flutter/material.dart';
import '../services/speech_service.dart';

class SpeechListDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          'Discours disponibles',
          style: TextStyle(color: Colors.amber),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: SpeechService.getAllSpeeches().length,
            itemBuilder: (context, index) {
              final speech = SpeechService.getAllSpeeches()[index];
              return ListTile(
                title: Text(
                  speech.title,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showSpeechContent(context, speech);
                },
              );
            },
          ),
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

  static void _showSpeechContent(BuildContext context, Speech speech) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          speech.title,
          style: const TextStyle(color: Colors.amber),
        ),
        content: SingleChildScrollView(
          child: Text(
            speech.getRandomText(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
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
}