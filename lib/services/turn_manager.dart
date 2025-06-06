import '../models/game.dart';
import '../constants/turn_orders.dart';

class TurnManager {
  final Game game;
  List<String> _currentTurnOrder = [];
  int _currentTurnIndex = 0;
  bool _isFirstNight = true;

  TurnManager({required this.game}) {
    _initializeTurnOrder();
  }

  void _initializeTurnOrder() {
    if (game.currentPhase == DayPhase.night) {
      _currentTurnOrder = _isFirstNight ? TurnOrders.firstNightOrder : TurnOrders.classicNightOrder;
    } else {
      _currentTurnOrder = game.currentDay == 0 ? TurnOrders.firstDayOrder : TurnOrders.classicDayOrder;
    }
    _currentTurnIndex = 0;
  }

  bool _isRoleActive(String role) {
    // Les événements spéciaux sont toujours actifs
    if (TurnOrders.isSpecialEvent(role)) {
      return true;
    }
    return game.activeRoles.contains(role);
  }

  bool _hasAlivePlayersWithRole(String role) {
    // Les événements spéciaux n'ont pas besoin de vérifier les joueurs vivants
    if (TurnOrders.isSpecialEvent(role)) {
      return true;
    }
    return game.players.any((player) => player.role == role && player.isAlive);
  }

  String? getCurrentRole() {
    if (_currentTurnIndex >= _currentTurnOrder.length) return null;

    String currentRole = _currentTurnOrder[_currentTurnIndex];
    while (_currentTurnIndex < _currentTurnOrder.length) {
      currentRole = _currentTurnOrder[_currentTurnIndex];
      
      // Vérifie si le rôle est en jeu et a des joueurs vivants
      if (_isRoleActive(currentRole) && _hasAlivePlayersWithRole(currentRole)) {
        return currentRole;
      }
      
      // Si le rôle n'est pas valide, passe au suivant
      _currentTurnIndex++;
    }
    
    return null; // Fin du tour
  }

  void nextTurn() {
    if (_currentTurnIndex < _currentTurnOrder.length) {
      _currentTurnIndex++;
    }
  }

  void previousTurn() {
    if (_currentTurnIndex > 0) {
      _currentTurnIndex--;
      // Recule jusqu'à trouver un rôle valide ou un événement spécial
      while (_currentTurnIndex > 0) {
        String currentRole = _currentTurnOrder[_currentTurnIndex];
        if (_isRoleActive(currentRole) && _hasAlivePlayersWithRole(currentRole)) {
          break;
        }
        _currentTurnIndex--;
      }
    }
  }

  void reset() {
    _isFirstNight = true;
    _initializeTurnOrder();
  }

  void onPhaseChange() {
    if (game.currentPhase == DayPhase.night) {
      if (_isFirstNight) {
        _isFirstNight = false;
      }
    } 
    _initializeTurnOrder();
  }
}