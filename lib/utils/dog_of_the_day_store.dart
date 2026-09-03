import 'package:shared_preferences/shared_preferences.dart';

const _keyDate = 'dogOfTheDayDate';
const _keyImageUrl = 'dogOfTheDayImageUrl';

class DogOfTheDayStore {
  /// Returns today's cached image URL, or null if nothing is cached yet
  /// for today's date.
  static Future<String?> getTodaysImage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedDate = prefs.getString(_keyDate);

    if (storedDate != _todayKey()) return null;

    return prefs.getString(_keyImageUrl);
  }

  static Future<void> saveTodaysImage(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDate, _todayKey());
    await prefs.setString(_keyImageUrl, imageUrl);
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
