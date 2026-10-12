import 'package:flutter/material.dart';

import '../models/weather_data.dart';
import '../utils/app_settings.dart';

class ForecastCard extends StatelessWidget {
  const ForecastCard({
    super.key,
    required this.forecast,
  });

  final ForecastDay forecast;

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                forecast.day,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              forecast.icon,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(forecast.condition)),
            Text(
              settings.temperature(forecast.maxCelsius),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            Text(
              settings.temperature(forecast.minCelsius),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}