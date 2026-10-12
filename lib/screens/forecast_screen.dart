import 'package:flutter/material.dart';

import '../utils/app_settings.dart';
import '../widgets/forecast_card.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateBuilder(
      builder: (context, settings) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('7-Day Forecast'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: settings.refreshWeather,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: settings.refreshWeather,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  settings.selectedCity.label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (settings.isLoading)
                  const LinearProgressIndicator(),
                if (settings.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      settings.errorMessage!,
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                if (settings.forecast.isEmpty && !settings.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No forecast available. Check your connection and refresh.',
                    ),
                  ),
                ...settings.forecast.map(
                  (day) => ForecastCard(forecast: day),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}