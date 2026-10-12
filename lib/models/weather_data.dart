import 'package:flutter/material.dart';

class CityResult {
  const CityResult({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1,
  });

  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String? admin1;

  String get label => [
        name,
        if (admin1 != null && admin1!.isNotEmpty) admin1!,
        country,
      ].join(', ');

  factory CityResult.fromJson(Map<String, dynamic> json) {
    return CityResult(
      name: json['name'] as String? ?? 'Unknown',
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      admin1: json['admin1'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'admin1': admin1,
      };

  factory CityResult.fromMap(Map<String, dynamic> map) {
    return CityResult(
      name: map['name'] as String,
      country: map['country'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      admin1: map['admin1'] as String?,
    );
  }
}

class WeatherData {
  const WeatherData({
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.temperatureCelsius,
    required this.maxTemperatureCelsius,
    required this.minTemperatureCelsius,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.icon,
    this.updatedAt,
  });

  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final double temperatureCelsius;
  final double maxTemperatureCelsius;
  final double minTemperatureCelsius;
  final int humidity;
  final double windSpeed;
  final String condition;
  final IconData icon;
  final DateTime? updatedAt;

  Map<String, dynamic> toMap() => {
        'city': city,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'temperature': temperatureCelsius,
        'max_temperature': maxTemperatureCelsius,
        'min_temperature': minTemperatureCelsius,
        'humidity': humidity,
        'wind_speed': windSpeed,
        'condition': condition,
        'updated_at': updatedAt?.toIso8601String(),
      };

  factory WeatherData.fromMap(Map<String, dynamic> map) {
    final condition = map['condition'] as String? ?? 'Cloudy';

    return WeatherData(
      city: map['city'] as String,
      country: map['country'] as String? ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      temperatureCelsius: (map['temperature'] as num).toDouble(),
      maxTemperatureCelsius:
          (map['max_temperature'] as num).toDouble(),
      minTemperatureCelsius:
          (map['min_temperature'] as num).toDouble(),
      humidity: (map['humidity'] as num).toInt(),
      windSpeed: (map['wind_speed'] as num).toDouble(),
      condition: condition,
      icon: weatherIcon(condition),
      updatedAt: DateTime.tryParse(
        map['updated_at'] as String? ?? '',
      ),
    );
  }
}

class ForecastDay {
  const ForecastDay({
    required this.day,
    required this.condition,
    required this.icon,
    required this.maxCelsius,
    required this.minCelsius,
  });

  final String day;
  final String condition;
  final IconData icon;
  final double maxCelsius;
  final double minCelsius;
}

String weatherCondition(int code) {
  if (code == 0) return 'Clear sky';
  if (code == 1) return 'Mainly clear';
  if (code == 2) return 'Partly cloudy';
  if (code == 3) return 'Overcast';
  if (code == 45 || code == 48) return 'Fog';
  if (code >= 51 && code <= 57) return 'Drizzle';
  if (code >= 61 && code <= 67) return 'Rain';
  if (code >= 71 && code <= 77) return 'Snow';
  if (code >= 80 && code <= 82) return 'Rain showers';
  if (code >= 85 && code <= 86) return 'Snow showers';
  if (code >= 95) return 'Thunderstorm';
  return 'Cloudy';
}

IconData weatherIcon(String condition) {
  final text = condition.toLowerCase();

  if (text.contains('thunder')) {
    return Icons.thunderstorm_rounded;
  }
  if (text.contains('snow')) {
    return Icons.ac_unit_rounded;
  }
  if (text.contains('rain') || text.contains('drizzle')) {
    return Icons.grain_rounded;
  }
  if (text.contains('fog')) {
    return Icons.cloud_rounded;
  }
  if (text.contains('cloud') || text.contains('overcast')) {
    return Icons.cloud_rounded;
  }

  return Icons.wb_sunny_rounded;
}