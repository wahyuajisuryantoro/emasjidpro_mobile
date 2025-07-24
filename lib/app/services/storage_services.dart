
import 'package:emasjid_pro/app/models/User.dart';
import 'package:get_storage/get_storage.dart';

class StorageService {
  final GetStorage _box = GetStorage();
  
  // Keys untuk penyimpanan
  static const String keyUser = 'user_data';
  static const String keyToken = 'auth_token';
  static const String keyUsername = 'username';

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
}