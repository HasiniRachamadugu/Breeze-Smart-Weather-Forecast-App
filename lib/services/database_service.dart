
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_data.dart';
import 'package:flutter/foundation.dart';

class DatabaseServiceException implements Exception {
  const DatabaseServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  @visibleForTesting
  void useInMemoryStoreForTesting() {
  _settings.clear();
  _favorites.clear();
  _weatherCache.clear();
  _initialized = true;
}
  static const String _settingsKey = 'breeze_settings';
  static const String _favoritesKey = 'breeze_favorites';
  static const String _weatherKey = 'breeze_weather_cache';

  final Map<String, String> _settings = {};
  final Map<String, CityResult> _favorites = {};
  final Map<String, WeatherData> _weatherCache = {};

  SharedPreferences? _preferences;
  bool _initialized = false;

  String _favoriteKey(String name, String country) =>
      '${name.trim()}|${country.trim()}';

  String _weatherCityKey(String city) => city.trim();

  Future<void> init() async {
    if (_initialized) return;

    _preferences = await SharedPreferences.getInstance();

    _settings.clear();
    _favorites.clear();
    _weatherCache.clear();

    final settingsJson = _preferences!.getString(_settingsKey);
    if (settingsJson != null) {
      final decoded = jsonDecode(settingsJson) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        if (value is String) {
          _settings[key] = value;
        }
      });
    }

    final favoritesJson = _preferences!.getString(_favoritesKey);
    if (favoritesJson != null) {
      final decoded = jsonDecode(favoritesJson) as List<dynamic>;
      for (final item in decoded) {
        final city = CityResult.fromMap(
          Map<String, dynamic>.from(item as Map),
        );
        _favorites[_favoriteKey(city.name, city.country)] = city;
      }
    }

    final weatherJson = _preferences!.getString(_weatherKey);
    if (weatherJson != null) {
      final decoded = jsonDecode(weatherJson) as List<dynamic>;
      for (final item in decoded) {
        final weather = WeatherData.fromMap(
          Map<String, dynamic>.from(item as Map),
        );
        _weatherCache[_weatherCityKey(weather.city)] = weather;
      }
    }

    _initialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }

  Future<void> _saveSettings() async {
    await _preferences!.setString(
      _settingsKey,
      jsonEncode(_settings),
    );
  }

  Future<void> _saveFavorites() async {
    await _preferences!.setString(
      _favoritesKey,
      jsonEncode(
        _favorites.values.map((city) => city.toMap()).toList(),
      ),
    );
  }

  Future<void> _saveWeatherCache() async {
    await _preferences!.setString(
      _weatherKey,
      jsonEncode(
        _weatherCache.values.map((weather) => weather.toMap()).toList(),
      ),
    );
  }

  Future<void> saveSetting(String key, String value) async {
    await _ensureInitialized();
    _settings[key] = value;
    await _saveSettings();
  }

  Future<String?> getSetting(String key) async {
    await _ensureInitialized();
    return _settings[key];
  }

  Future<void> addFavorite(CityResult city) async {
    await _ensureInitialized();
    _favorites[_favoriteKey(city.name, city.country)] = city;
    await _saveFavorites();
  }

  Future<void> removeFavorite(String name, String country) async {
    await _ensureInitialized();
    _favorites.remove(_favoriteKey(name, country));
    await _saveFavorites();
  }

  Future<List<CityResult>> getFavorites() async {
    await _ensureInitialized();
    final favorites = _favorites.values.toList();
    favorites.sort((a, b) => a.name.compareTo(b.name));
    return favorites;
  }

  Future<void> saveWeather(WeatherData weather) async {
    await _ensureInitialized();
    _weatherCache[_weatherCityKey(weather.city)] = weather;
    await _saveWeatherCache();
  }

  Future<WeatherData?> getWeather(String city) async {
    await _ensureInitialized();
    return _weatherCache[_weatherCityKey(city)];
  }

  Future<void> close() async {
    // Local preferences remain saved between app launches.
  }
}