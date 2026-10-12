import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_data.dart';

class WeatherApiService {
  WeatherApiService._();

  static final WeatherApiService instance = WeatherApiService._();

  static const List<CityResult> _sampleCities = [
    CityResult(
      name: 'Hyderabad',
      country: 'India',
      latitude: 17.3850,
      longitude: 78.4867,
      admin1: 'Telangana',
    ),
    CityResult(
      name: 'Bhimavaram',
      country: 'India',
      latitude: 16.5449,
      longitude: 81.5212,
      admin1: 'Andhra Pradesh',
    ),
    CityResult(
      name: 'Visakhapatnam',
      country: 'India',
      latitude: 17.6868,
      longitude: 83.2185,
      admin1: 'Andhra Pradesh',
    ),
    CityResult(
      name: 'Bengaluru',
      country: 'India',
      latitude: 12.9716,
      longitude: 77.5946,
      admin1: 'Karnataka',
    ),
    CityResult(
      name: 'Chennai',
      country: 'India',
      latitude: 13.0827,
      longitude: 80.2707,
      admin1: 'Tamil Nadu',
    ),
    CityResult(
      name: 'Mumbai',
      country: 'India',
      latitude: 19.0760,
      longitude: 72.8777,
      admin1: 'Maharashtra',
    ),
    CityResult(
      name: 'Delhi',
      country: 'India',
      latitude: 28.6139,
      longitude: 77.2090,
      admin1: 'Delhi',
    ),
  ];

  static const String _geocodingBase =
      'https://geocoding-api.open-meteo.com/v1/search';

  static const String _forecastBase =
      'https://api.open-meteo.com/v1/forecast';

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static final Map<String, Map<String, dynamic>> _sampleWeatherMap = {
    'Hyderabad': {'temperature': 31.0, 'condition': 'Clear sky', 'humidity': 48, 'wind': 11.0},
    'Bhimavaram': {'temperature': 33.0, 'condition': 'Partly cloudy', 'humidity': 54, 'wind': 14.5},
    'Visakhapatnam': {'temperature': 28.0, 'condition': 'Cloudy', 'humidity': 69, 'wind': 18.0},
    'Bengaluru': {'temperature': 27.0, 'condition': 'Mainly clear', 'humidity': 62, 'wind': 10.0},
    'Chennai': {'temperature': 30.0, 'condition': 'Clear sky', 'humidity': 58, 'wind': 15.0},
    'Mumbai': {'temperature': 29.0, 'condition': 'Rain', 'humidity': 77, 'wind': 19.0},
    'Delhi': {'temperature': 35.0, 'condition': 'Sunny', 'humidity': 36, 'wind': 9.0},
  };

  List<CityResult> _sampleSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final normalized = trimmed.toLowerCase();
    return _sampleCities
        .where((city) => city.name.toLowerCase().contains(normalized))
        .toList();
  }

  WeatherData _sampleWeather(CityResult city) {
    final sample = _sampleWeatherMap[city.name] ??
        {'temperature': 28.0, 'condition': 'Cloudy', 'humidity': 60, 'wind': 12.0};
    final condition = sample['condition'] as String;
    final temp = (sample['temperature'] as num).toDouble();

    return WeatherData(
      city: city.name,
      country: city.country,
      latitude: city.latitude,
      longitude: city.longitude,
      temperatureCelsius: temp,
      maxTemperatureCelsius: temp + 4,
      minTemperatureCelsius: temp - 4,
      humidity: (sample['humidity'] as num).toInt(),
      windSpeed: (sample['wind'] as num).toDouble(),
      condition: condition,
      icon: weatherIcon(condition),
      updatedAt: DateTime.now(),
    );
  }

  List<ForecastDay> _sampleForecast(CityResult city) {
    final base = (_sampleWeatherMap[city.name]?['temperature'] as num? ?? 28).toDouble();
    final today = DateTime.now();
    final conditions = [
      'Clear sky',
      'Partly cloudy',
      'Cloudy',
      'Rain',
      'Mainly clear',
      'Rain',
      'Sunny',
    ];

    return List.generate(7, (index) {
      final date = today.add(Duration(days: index));
      final high = base + (index % 3) + 2;
      final low = base - (index % 4) - 2;
      final condition = conditions[index];
      final day = index == 0
          ? 'Today'
          : _weekdays[date.weekday - 1];

      return ForecastDay(
        day: day,
        condition: condition,
        icon: weatherIcon(condition),
        maxCelsius: high,
        minCelsius: low,
      );
    });
  }

  Future<List<CityResult>> searchCities(String query) async {
    final localResults = _sampleSearch(query);
    if (localResults.isNotEmpty) {
      return localResults;
    }

    final uri = Uri.parse(_geocodingBase).replace(
      queryParameters: {
        'name': query,
        'count': '10',
        'language': 'en',
        'format': 'json',
      },
    );

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('City search failed: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final results = json['results'] as List<dynamic>? ?? [];

    return results
        .map(
          (item) => CityResult.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<Map<String, dynamic>> _fetchForecastJson(
    CityResult city,
  ) async {
    final uri = Uri.parse(_forecastBase).replace(
      queryParameters: {
        'latitude': city.latitude.toString(),
        'longitude': city.longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min',
        'timezone': 'auto',
        'forecast_days': '7',
      },
    );

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Weather request failed: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<WeatherData> fetchWeather(CityResult city) async {
    if (_sampleSearch(city.name).isNotEmpty) {
      return _sampleWeather(city);
    }

    final json = await _fetchForecastJson(city);

    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    final code = (current['weather_code'] as num).toInt();
    final condition = weatherCondition(code);

    final maximums = daily['temperature_2m_max'] as List<dynamic>;
    final minimums = daily['temperature_2m_min'] as List<dynamic>;

    return WeatherData(
      city: city.name,
      country: city.country,
      latitude: city.latitude,
      longitude: city.longitude,
      temperatureCelsius:
          (current['temperature_2m'] as num).toDouble(),
      maxTemperatureCelsius: (maximums.first as num).toDouble(),
      minTemperatureCelsius: (minimums.first as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      condition: condition,
      icon: weatherIcon(condition),
      updatedAt: DateTime.now(),
    );
  }

  Future<List<ForecastDay>> fetchForecast(CityResult city) async {
    if (_sampleSearch(city.name).isNotEmpty) {
      return _sampleForecast(city);
    }

    final json = await _fetchForecastJson(city);
    final daily = json['daily'] as Map<String, dynamic>;

    final dates = daily['time'] as List<dynamic>;
    final codes = daily['weather_code'] as List<dynamic>;
    final maximums = daily['temperature_2m_max'] as List<dynamic>;
    final minimums = daily['temperature_2m_min'] as List<dynamic>;

    return List.generate(dates.length, (index) {
      final date = DateTime.parse(dates[index] as String);
      final condition =
          weatherCondition((codes[index] as num).toInt());

      final day = index == 0
          ? 'Today'
          : _weekdays[date.weekday - 1];

      return ForecastDay(
        day: day,
        condition: condition,
        icon: weatherIcon(condition),
        maxCelsius: (maximums[index] as num).toDouble(),
        minCelsius: (minimums[index] as num).toDouble(),
      );
    });
  }
}