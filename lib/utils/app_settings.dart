import 'package:flutter/material.dart';

import '../models/weather_data.dart';
import '../services/database_service.dart';
import '../services/weather_api_service.dart';

class BreezeColors {
  static const Color primary = Color(0xFF2878E5);
  static const Color accent = Color(0xFF55A7FF);
  static const Color background = Color(0xFFF5F8FF);
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF172B4D);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color darkBackground = Color(0xFF101828);
}

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  CityResult selectedCity = const CityResult(
    name: 'Hyderabad',
    country: 'India',
    latitude: 17.3850,
    longitude: 78.4867,
  );

  WeatherData? weather;
  List<ForecastDay> forecast = [];
  List<CityResult> favorites = [];

  bool isDarkMode = false;
  bool isFahrenheit = false;
  bool isLoading = false;
  bool isInitialized = false;

  String? errorMessage;

  bool _isInitializing = false;

  String temperature(double celsius) {
    final value = isFahrenheit ? celsius * 9 / 5 + 32 : celsius;
    return '${value.round()}°${isFahrenheit ? 'F' : 'C'}';
  }

  Future<void> initialize() async {
    if (isInitialized || _isInitializing) return;

    _isInitializing = true;

    try {
      // Confirm the local API and MySQL connection before reading settings.
      await DatabaseService.instance.init();

      final db = DatabaseService.instance;

      final savedCity = await db.getSetting('city');

      if (savedCity != null) {
        final parts = savedCity.split('|');

        if (parts.length >= 4) {
          selectedCity = CityResult(
            name: parts[0],
            country: parts[1],
            latitude:
                double.tryParse(parts[2]) ?? selectedCity.latitude,
            longitude:
                double.tryParse(parts[3]) ?? selectedCity.longitude,
            admin1: parts.length > 4 && parts[4].isNotEmpty
                ? parts[4]
                : null,
          );
        }
      }

      isFahrenheit =
          await db.getSetting('fahrenheit') == 'true';

      isDarkMode = await db.getSetting('dark') == 'true';

      favorites = await db.getFavorites();

      isInitialized = true;
      notifyListeners();

      // Weather errors are handled inside refreshWeather().
      await refreshWeather();
    } catch (e, stackTrace) {
      debugPrint('BREEZE INITIALIZATION ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      errorMessage =
          'Unable to connect to the local database. Check that MySQL Server '
          'and the Breeze API are running, then retry.';
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> loadFavorites() async {
    favorites = await DatabaseService.instance.getFavorites();
    notifyListeners();
  }

  Future<void> selectCity(CityResult city) async {
    selectedCity = city;
    weather = null;
    forecast = [];
    errorMessage = null;

    await DatabaseService.instance.saveSetting(
      'city',
      '${city.name}|${city.country}|'
          '${city.latitude}|${city.longitude}|${city.admin1 ?? ''}',
    );

    notifyListeners();
    await refreshWeather();
  }

  Future<void> refreshWeather() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        WeatherApiService.instance.fetchWeather(selectedCity),
        WeatherApiService.instance.fetchForecast(selectedCity),
      ]);

      final latestWeather = results[0] as WeatherData;
      final latestForecast = results[1] as List<ForecastDay>;

      await DatabaseService.instance.saveWeather(latestWeather);

      weather = latestWeather;
      forecast = latestForecast;
    } catch (e, stackTrace) {
      debugPrint('BREEZE WEATHER ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      try {
        weather = await DatabaseService.instance.getWeather(
          selectedCity.name,
        );

        errorMessage = weather == null
            ? 'Could not load weather. Check your internet and retry.'
            : 'Offline mode: showing saved weather.';
      } catch (dbError) {
        debugPrint('BREEZE WEATHER CACHE ERROR: $dbError');

        errorMessage =
            'Could not load weather. Check your connection and retry.';
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<CityResult>> searchCities(String query) {
    return WeatherApiService.instance.searchCities(query);
  }

  bool isFavorite(CityResult city) {
    return favorites.any(
      (item) =>
          item.name == city.name &&
          item.country == city.country,
    );
  }

  Future<void> toggleFavorite(CityResult city) async {
    final db = DatabaseService.instance;

    if (isFavorite(city)) {
      await db.removeFavorite(city.name, city.country);
    } else {
      await db.addFavorite(city);
    }

    favorites = await db.getFavorites();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    await DatabaseService.instance.saveSetting('dark', '$value');
    notifyListeners();
  }

  Future<void> setFahrenheit(bool value) async {
    isFahrenheit = value;
    await DatabaseService.instance.saveSetting(
      'fahrenheit',
      '$value',
    );
    notifyListeners();
  }

}

/// Rebuilds a widget whenever shared app settings change.
class AppStateBuilder extends StatelessWidget {
  const AppStateBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, AppSettings settings)
      builder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) => builder(
        context,
        AppSettings.instance,
      ),
    );
  }
}