class RoleEmojis {
  static const Map<String, String> roleToEmoji = {
    'Villageois': '👥',
    'Loups': '🐺',
    'Voyante': '🔮',
    'Sorcière': '⚗️',
    'Chasseur': '🎯',
    'Cupidon': '💘',
    'Petite Fille': '👧',
    'Garde': '🛡️',
    'Avocat': '⚖️',
    'Idiot du Village': '🤪',
    'Sbire': '😈',
    'Souffre-douleur': '😢',
    'Boulanger': '🥖',
    'Mère Grand': '👵',
    'Berger': '🐑',
    'Renard': '🦊',
    'Percepteur': '💰',
    'Corbeau': '🦅',
    'Chaperon Rouge': '🔴',
    'Enfant Sauvage': '🌳',
    'Wendigo': '🐶',
    'Majordome': '🎩',
    'Servante': '🧹',
    'Frères': '👬',
    'Loup Noir': '🌑',
    'Grand Méchant Loup': '⚫',
    'Loup Blanc': '⚪',
    'Nécromancien': '💀',
    'Ange': '👼',
    'Soeurs': '👭',
  };

  static String getEmoji(String role) {
    return roleToEmoji[role] ?? '❓';
  }
}