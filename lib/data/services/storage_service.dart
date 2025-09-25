// lib/data/services/storage_service.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  late GetStorage _box;

  @override
  Future<void> onInit() async {
    super.onInit();
    await GetStorage.init();
    _box = GetStorage();
  }

  // Authentication Keys
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _studentDataKey = 'student_data';

  // Settings Keys
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _languageKey = 'selected_language';
  static const String _biometricKey = 'biometric_enabled';

  // Token Management
  Future<void> saveToken(String token) async {
    await _box.write(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return _box.read(_tokenKey);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _box.write(_refreshTokenKey, refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return _box.read(_refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _box.remove(_tokenKey);
    await _box.remove(_refreshTokenKey);
  }

  // Student Data Management
  Future<void> saveStudentData(Map<String, dynamic> studentData) async {
    await _box.write(_studentDataKey, studentData);
  }

  Future<Map<String, dynamic>?> getStudentData() async {
    return _box.read(_studentDataKey);
  }

  Future<void> clearStudentData() async {
    await _box.remove(_studentDataKey);
  }

  // Settings Management
  Future<void> setBool(String key, bool value) async {
    await _box.write(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _box.read(key);
  }

  Future<void> setString(String key, String value) async {
    await _box.write(key, value);
  }

  Future<String?> getString(String key) async {
    return _box.read(key);
  }

  Future<void> setInt(String key, int value) async {
    await _box.write(key, value);
  }

  Future<int?> getInt(String key) async {
    return _box.read(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _box.write(key, value);
  }

  Future<double?> getDouble(String key) async {
    return _box.read(key);
  }

  Future<void> setMap(String key, Map<String, dynamic> value) async {
    await _box.write(key, value);
  }

  Future<Map<String, dynamic>?> getMap(String key) async {
    return _box.read(key);
  }

  Future<void> setList(String key, List<dynamic> value) async {
    await _box.write(key, value);
  }

  Future<List<dynamic>?> getList(String key) async {
    return _box.read(key);
  }

  // Cache Management
  Future<void> setCacheWithTTL(String key, dynamic value, Duration ttl) async {
    final expiry = DateTime.now().add(ttl).millisecondsSinceEpoch;
    await _box.write(key, {'data': value, 'expiry': expiry});
  }

  Future<T?> getCacheWithTTL<T>(String key) async {
    final cached = _box.read(key);
    if (cached == null) return null;

    final expiry = cached['expiry'] as int?;
    if (expiry == null || DateTime.now().millisecondsSinceEpoch > expiry) {
      await _box.remove(key);
      return null;
    }

    return cached['data'] as T?;
  }

  // Clear Specific Data
  Future<void> clearCache() async {
    final keys = _box.getKeys().where(
      (key) =>
          key.toString().startsWith('cache_') ||
          key.toString().startsWith('temp_'),
    );

    for (final key in keys) {
      await _box.remove(key);
    }
  }

  Future<void> clearSettings() async {
    await _box.remove(_notificationsEnabledKey);
    await _box.remove(_darkModeKey);
    await _box.remove(_languageKey);
    await _box.remove(_biometricKey);
  }

  // Clear All Data
  Future<void> clearAll() async {
    await _box.erase();
  }

  // Check if data exists
  bool hasKey(String key) {
    return _box.hasData(key);
  }

  // Get all keys
  Iterable<String> getAllKeys() {
    return _box.getKeys().cast<String>();
  }

  // Get storage size (approximate)
  int getStorageSize() {
    return _box.getKeys().length;
  }

  // Backup data to JSON
  Map<String, dynamic> exportData() {
    final data = <String, dynamic>{};
    for (final key in _box.getKeys()) {
      data[key.toString()] = _box.read(key.toString());
    }
    return data;
  }

  // Import data from JSON
  Future<void> importData(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      await _box.write(entry.key, entry.value);
    }
  }

  // Listen to storage changes
  void listenKey(String key, Function(dynamic) callback) {
    _box.listenKey(key, callback);
  }

  // Remove listener
  void removeListener() {
    // GetStorage doesn't provide removeListener method
    // This is handled automatically when the service is disposed
  }
}
