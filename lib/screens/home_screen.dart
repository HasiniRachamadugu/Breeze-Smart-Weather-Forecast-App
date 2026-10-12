
import 'package:flutter/material.dart';

import '../utils/app_settings.dart';
import '../widgets/weather_card.dart';
import '../widgets/whatsapp_share_button.dart';
import 'details_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateBuilder(
      builder: (context, settings) {
        final weather = settings.weather;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Breeze',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                tooltip: 'Search city',
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Refresh weather',
                icon: const Icon(Icons.refresh),
                onPressed: settings.refreshWeather,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: settings.refreshWeather,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text(
                  'Good day!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Here is your weather update.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                if (settings.isLoading && weather == null)
                  const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (weather == null)
                  _ErrorPanel(
                    message: settings.errorMessage ??
                        'Weather unavailable.',
                    onRetry: settings.refreshWeather,
                  )
                else ...[
                  WeatherCard(
                    weather: weather,
                    city: settings.selectedCity,
                    isFavorite:
                        settings.isFavorite(settings.selectedCity),
                    onFavoritePressed: () =>
                        settings.toggleFavorite(
                          settings.selectedCity,
                        ),
                  ),
                  if (settings.errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      settings.errorMessage!,
                      style: const TextStyle(
                        color: Colors.orange,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  Text(
                    'Today’s conditions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.thermostat),
                      title: const Text(
                        'Feels like / temperature',
                      ),
                      subtitle: Text(
                        settings.temperature(
                          weather.temperatureCelsius,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.water_drop_outlined,
                      ),
                      title: const Text('Humidity'),
                      subtitle: Text('${weather.humidity}%'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.air),
                      title: const Text('Wind speed'),
                      subtitle: Text(
                        '${weather.windSpeed} km/h',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DetailsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('View weather details'),
                  ),
                  const SizedBox(height: 12),
                  WhatsAppShareButton(
                    weather: weather,
                    forecast: settings.forecast,
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Weather data provided by Open-Meteo.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
