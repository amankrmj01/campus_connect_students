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

  // Cache Keys
  static const String _cachePrefix = 'cache_';
  static const String _cacheTimestampSuffix = '_timestamp';

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
    final data = _box.read(_studentDataKey);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  Future<void> clearStudentData() async {
    await _box.remove(_studentDataKey);
  }

  // Cache Management with TTL
  Future<void> setCacheWithTTL<T>(String key, T data, Duration ttl) async {
    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$cacheKey$_cacheTimestampSuffix';
    final expirationTime = DateTime.now().add(ttl).millisecondsSinceEpoch;

    await _box.write(cacheKey, data);
    await _box.write(timestampKey, expirationTime);
  }

  Future<T?> getCacheWithTTL<T>(String key) async {
    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$cacheKey$_cacheTimestampSuffix';

    final expirationTime = _box.read<int>(timestampKey);
    if (expirationTime == null) {
      return null;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now > expirationTime) {
      // Cache expired, remove it
      await _box.remove(cacheKey);
      await _box.remove(timestampKey);
      return null;
    }

    final cachedData = _box.read<T>(cacheKey);
    return cachedData;
  }

  Future<void> removeCache(String key) async {
    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$cacheKey$_cacheTimestampSuffix';

    await _box.remove(cacheKey);
    await _box.remove(timestampKey);
  }

  Future<void> clearAllCache() async {
    final keys = _box.getKeys();
    for (final key in keys) {
      if (key.toString().startsWith(_cachePrefix)) {
        await _box.remove(key);
      }
    }
  }

  // Settings Management
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _box.write(_notificationsEnabledKey, enabled);
  }

  bool getNotificationsEnabled() {
    return _box.read(_notificationsEnabledKey) ?? true;
  }

  Future<void> setDarkModeEnabled(bool enabled) async {
    await _box.write(_darkModeKey, enabled);
  }

  bool getDarkModeEnabled() {
    return _box.read(_darkModeKey) ?? false;
  }

  Future<void> setLanguage(String language) async {
    await _box.write(_languageKey, language);
  }

  String getLanguage() {
    return _box.read(_languageKey) ?? 'en';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _box.write(_biometricKey, enabled);
  }

  bool getBiometricEnabled() {
    return _box.read(_biometricKey) ?? false;
  }

  // Generic boolean methods
  Future<void> setBool(String key, bool value) async {
    await _box.write(key, value);
  }

  bool? getBool(String key) {
    return _box.read<bool>(key);
  }

  // Generic string methods
  Future<void> setString(String key, String value) async {
    await _box.write(key, value);
  }

  String? getString(String key) {
    return _box.read<String>(key);
  }

  // Generic int methods
  Future<void> setInt(String key, int value) async {
    await _box.write(key, value);
  }

  int? getInt(String key) {
    return _box.read<int>(key);
  }

  // Generic double methods
  Future<void> setDouble(String key, double value) async {
    await _box.write(key, value);
  }

  double? getDouble(String key) {
    return _box.read<double>(key);
  }

  // Generic list methods
  Future<void> setStringList(String key, List<String> value) async {
    await _box.write(key, value);
  }

  List<String>? getStringList(String key) {
    final list = _box.read<List>(key);
    return list?.cast<String>();
  }

  // Generic storage methods
  Future<void> write<T>(String key, T value) async {
    await _box.write(key, value);
  }

  T? read<T>(String key) {
    return _box.read<T>(key);
  }

  Future<void> remove(String key) async {
    await _box.remove(key);
  }

  Future<void> clearAll() async {
    await _box.erase();
  }

  // Check if key exists
  bool hasData(String key) {
    return _box.hasData(key);
  }

  // Get all keys
  Iterable<dynamic> getKeys() {
    return _box.getKeys();
  }
}
