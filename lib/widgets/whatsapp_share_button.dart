
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/weather_data.dart';

class WhatsAppShareButton extends StatelessWidget {
  const WhatsAppShareButton({
    super.key,
    required this.weather,
    required this.forecast,
  });

  final WeatherData weather;
  final List<ForecastDay> forecast;

  Future<void> _shareWeather(BuildContext context) async {
    final forecastText = forecast.isEmpty
        ? 'Forecast is currently unavailable.'
        : forecast.take(3).map((day) {
            return '${day.day}: ${day.condition}, '
                '${day.minCelsius.round()}°C - '
                '${day.maxCelsius.round()}°C';
          }).join('\n');

    final message = '''
 Breeze Weather Update

 ${weather.city}, ${weather.country}
 Temperature: ${weather.temperatureCelsius.round()}°C
 Condition: ${weather.condition}
 Humidity: ${weather.humidity}%
 Wind Speed: ${weather.windSpeed}

Forecast:
$forecastText

Shared using Breeze Weather App.
''';

    final uri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(message)}',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open WhatsApp. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _shareWeather(context),
        icon: const Icon(Icons.share),
        label: const Text('Share Weather on WhatsApp'),
        style: ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFF2878E5),
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(vertical: 15),
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  ),
),
      ),
    );
  }
}
