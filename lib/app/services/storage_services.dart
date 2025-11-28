import 'package:emasjid_pro/app/models/User.dart';
import 'package:get_storage/get_storage.dart';

class StorageService {
  final GetStorage _box = GetStorage();

  // Keys untuk penyimpanan
  static const String keyUser = 'user_data';
  static const String keyToken = 'auth_token';
  static const String keyUsername = 'username';
  static const String keyUsernameHistory = 'username_history';

  // Menyimpan data user
  Future<void> saveUserData(User user) async {
    await _box.write(keyUser, user.toJson());
    await _box.write(keyUsername, user.username);
  }

  // Mendapatkan data user
  User? getUserData() {
    final userData = _box.read(keyUser);
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }

  // Menyimpan token
  Future<void> saveToken(String token) async {
    await _box.write(keyToken, token);
  }

  // Mendapatkan token
  String? getToken() {
    return _box.read(keyToken);
  }

  // Mendapatkan username
  String? getUsername() {
    return _box.read(keyUsername);
  }

  // Menghapus semua data (untuk logout)
  Future<void> clearStorage() async {
    await _box.erase();
  }

  // Cek apakah user sudah login
  bool isLoggedIn() {
    return getToken() != null && getUserData() != null;
  }

  Future<void> saveUsernameToHistory(String username) async {
    if (username.trim().isEmpty) return;

    try {
      List<String> history = getUsernameHistory();
      history
          .removeWhere((item) => item.toLowerCase() == username.toLowerCase());
      history.insert(0, username.trim());
      if (history.length > 10) {
        history = history.take(10).toList();
      }

      await _box.write(keyUsernameHistory, history);
    } catch (e) {
      print('Error saving username to history: $e');
    }
  }

  List<String> getUsernameHistory() {
    try {
      final history = _box.read(keyUsernameHistory);
      if (history is List) {
        return List<String>.from(history);
      }
      return [];
    } catch (e) {
      print('Error getting username history: $e');
      return [];
    }
  }

  Future<void> clearUsernameHistory() async {
    try {
      await _box.remove(keyUsernameHistory);
    } catch (e) {
      print('Error clearing username history: $e');
    }
  }
}
