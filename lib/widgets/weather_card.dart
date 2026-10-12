import 'package:flutter/material.dart';

import '../models/weather_data.dart';
import '../utils/app_settings.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
    required this.weather,
    required this.city,
    required this.isFavorite,
    required this.onFavoritePressed,
  });

  final WeatherData weather;
  final CityResult city;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF55A7FF),
            Color(0xFF2878E5),
            Color(0xFF1659B7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.white,
              ),
              Expanded(
                child: Text(
                  '${city.name}, ${city.country}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
                onPressed: onFavoritePressed,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Icon(weather.icon, size: 82, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            settings.temperature(weather.temperatureCelsius),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 54,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            weather.condition,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'High ${settings.temperature(weather.maxTemperatureCelsius)}'
            '   •   Low ${settings.temperature(weather.minTemperatureCelsius)}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _WeatherMetric(
                  icon: Icons.water_drop_outlined,
                  label: 'Humidity',
                  value: '${weather.humidity}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WeatherMetric(
                  icon: Icons.air_rounded,
                  label: 'Wind',
                  value: '${weather.windSpeed.round()} km/h',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  const _WeatherMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}