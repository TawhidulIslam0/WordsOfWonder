import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const _levelKey = 'wordbound.level';
  static const _gemsKey = 'wordbound.gems';
  static const _bonusKey = 'wordbound.bonus';

  static Future<int> currentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_levelKey) ?? 1;
  }

  static Future<int> gems() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_gemsKey) ?? 250;
  }

  static Future<int> bonusCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bonusKey) ?? 0;
  }

  static Future<void> saveLevel(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_levelKey, value.clamp(1, 1000));
  }

  static Future<void> addGems(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_gemsKey, (prefs.getInt(_gemsKey) ?? 250) + value);
  }

  static Future<bool> spendGems(int value) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_gemsKey) ?? 250;
    if (current < value) return false;
    await prefs.setInt(_gemsKey, current - value);
    return true;
  }

  static Future<void> addBonus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bonusKey, (prefs.getInt(_bonusKey) ?? 0) + 1);
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_levelKey);
    await prefs.remove(_gemsKey);
    await prefs.remove(_bonusKey);
  }
}