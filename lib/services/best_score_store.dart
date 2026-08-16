import 'package:shared_preferences/shared_preferences.dart';

class BestScoreStore {
  static const _key = 'best_score';

  Future<int> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  Future<void> save(int best) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, best);
  }
}
