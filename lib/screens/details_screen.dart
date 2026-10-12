import 'package:flutter/material.dart';

import '../utils/app_settings.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateBuilder(
      builder: (context, settings) {
        final weather = settings.weather;

        return Scaffold(
          appBar: AppBar(title: const Text('Weather Details')),
          body: weather == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Weather details are not available.'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: settings.refreshWeather,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      settings.selectedCity.label,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              weather.icon,
                              size: 72,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              settings.temperature(
                                weather.temperatureCelsius,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium,
                            ),
                            Text(
                              weather.condition,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _DetailTile(
                      icon: Icons.arrow_upward,
                      title: 'Maximum temperature',
                      value: settings.temperature(
                        weather.maxTemperatureCelsius,
                      ),
                    ),
                    _DetailTile(
                      icon: Icons.arrow_downward,
                      title: 'Minimum temperature',
                      value: settings.temperature(
                        weather.minTemperatureCelsius,
                      ),
                    ),
                    _DetailTile(
                      icon: Icons.water_drop_outlined,
                      title: 'Humidity',
                      value: '${weather.humidity}%',
                    ),
                    _DetailTile(
                      icon: Icons.air,
                      title: 'Wind speed',
                      value: '${weather.windSpeed} km/h',
                    ),
                    _DetailTile(
                      icon: Icons.update,
                      title: 'Last fetched',
                      value: weather.updatedAt == null
                          ? 'Unknown'
                          : weather.updatedAt!.toLocal().toString(),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Forecast information is provided by Open-Meteo.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}