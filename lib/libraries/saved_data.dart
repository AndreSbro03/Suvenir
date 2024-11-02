import 'package:shared_preferences/shared_preferences.dart';

class SavedDataFields {
  static final List<String> values = [
    /// Add all fields
    savedSpace, invalidPaths
  ];

  static const String savedSpace = 'savedSpace';
  /// We saved the invalidPath beacouse if is the firts time that a user is using the app the list of validPath would be empty and
  /// I cannot be sure if is empty becouse it was never set or becouse it is the first time using the app. If I use the invalid path
  /// the problem does not exist.
  static const String invalidPaths= 'invalidPaths';

}

class SavedData {
  static final SavedData instance = SavedData._init();

  static SharedPreferences? _prefs;

  SavedData._init();

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;

    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> addSavedSpace(int size) async {
    int oldSpace = await getSavedSpace();
    await prefs.then((p) => p.setInt(SavedDataFields.savedSpace, oldSpace + size));
  }

  Future<void> setSavedSpace(int size) async {
    await prefs.then((p) => p.setInt(SavedDataFields.savedSpace, size));
  }

  Future<int> getSavedSpace() async {
    int space = await prefs.then((p) => p.getInt(SavedDataFields.savedSpace) ?? 0);
    print("[INFO] Total space found: $space");
    return space;
  }

  Future<void> addInvalidPaths(List<String> invalidPaths) async {
    List<String> paths = await getInvalidPaths();
    paths.addAll(invalidPaths);
    await prefs.then((p) => p.setStringList(SavedDataFields.invalidPaths, paths));
  }

  Future<void> setValidPaths(List<String> invalidPaths) async {
    await prefs.then((p) => p.setStringList(SavedDataFields.invalidPaths, invalidPaths));
  }

  Future<List<String>> getInvalidPaths() async {
    List<String> paths = await prefs.then((p) => p.getStringList(SavedDataFields.invalidPaths) ?? []);
    return paths;
  }

}