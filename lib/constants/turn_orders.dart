class TurnOrders {
  // Événements spéciaux qui doivent toujours avoir lieu
  static const String VOTE_EVENT = '[VOTE]';
  static const String FORUM_EVENT = '[FORUM]';

  static const List<String> firstNightOrder = [
    'Frères',
    'Soeurs',
    'Cupidon',
    'Sbire',
    'Percepteur',
    'Wendigo',
    'Enfant Sauvage',
    'Majordome',
    'Servante',
    'Loups',
  ];

  static const List<String> classicNightOrder = [
    'Voyante',
    'Nécromancien',
    'Garde',
    'Avocat',
    'Renard',
    'Loups',
    'Loup-Garou',
    'Loup Noir',
    'Grand Méchant Loup',
    'Loup Blanc',
    'Sorcière',
    'Boulanger',
    'Corbeau',
  ];

  static const List<String> firstDayOrder = [
    FORUM_EVENT, // Forum avant le vote
  ];

  static const List<String> classicDayOrder = [
    FORUM_EVENT, // Forum avant le vote
    VOTE_EVENT, // Vote à la fin
  ];

  // Vérifie si une étape est un événement spécial qui doit toujours avoir lieu
  static bool isSpecialEvent(String step) {
    return step == VOTE_EVENT ||
        step == FORUM_EVENT;
  }
}