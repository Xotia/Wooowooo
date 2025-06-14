import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class Speech {
  final String title;
  final List<String> variants;
  final Random _random = Random();

  Speech({
    required this.title,
    required this.variants,
  });

  factory Speech.fromJson(Map<String, dynamic> json) {
    return Speech(
      title: json['title'] as String,
      variants: List<String>.from(json['variants'] as List),
    );
  }

  String getRandomText() {
    if (variants.isEmpty) return '';
    return variants[_random.nextInt(variants.length)];
  }
}

class SpeechService {
  static Map<String, Speech> speeches = {};

  static Future<void> initialize() async {
    final String jsonString = await rootBundle.loadString('assets/ressources/speech.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    
    speeches = jsonData.map((key, value) => MapEntry(
      key,
      Speech.fromJson(value as Map<String, dynamic>),
    ));
  }

  static List<Speech> getAllSpeeches() {
    return speeches.values.toList();
  }

  static Speech? getSpeech(String key) {
    return speeches[key];
  }
}