import 'package:shared_preferences/shared_preferences.dart';

class StatisticsFileds {
  static final List<String> values = [
    /// Add all fields
    savedSpace
  ];

  static const String savedSpace = 'savedSpace';
}

class Statistics {
  static final Statistics instance = Statistics._init();

  static SharedPreferences? _prefs;

  Statistics._init();

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;

    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> addSavedSpace(int size) async {
    int oldSpace = await getSavedSpace();
    await prefs.then((p) => p.setInt(StatisticsFileds.savedSpace, oldSpace + size));
  }

  Future<void> setSavedSpace(int size) async {
    await prefs.then((p) => p.setInt(StatisticsFileds.savedSpace, size));
  }

  Future<int> getSavedSpace() async {
    int space = await prefs.then((p) => p.getInt(StatisticsFileds.savedSpace) ?? 0);
    print("[INFO] Total space found: $space");
    return space;
  }

}