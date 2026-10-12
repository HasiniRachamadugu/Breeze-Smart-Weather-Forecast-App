import 'package:flutter/material.dart';

import '../utils/app_settings.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.onCitySelected});

  final VoidCallback onCitySelected;

  @override
  Widget build(BuildContext context) {
    return AppStateBuilder(
      builder: (context, settings) {
        return Scaffold(
          appBar: AppBar(title: const Text('Favorite Cities')),
          body: settings.favorites.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_border, size: 60),
                        SizedBox(height: 12),
                        Text('No favorite cities yet.'),
                        SizedBox(height: 6),
                        Text(
                          'Search for a city and add it to your favorites.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: settings.favorites.length,
                  itemBuilder: (context, index) {
                    final city = settings.favorites[index];
                    final selected =
                        city.name == settings.selectedCity.name &&
                        city.country == settings.selectedCity.country;

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_city),
                        title: Text(city.name),
                        subtitle: Text(
                          city.admin1 == null || city.admin1!.isEmpty
                              ? city.country
                              : '${city.admin1}, ${city.country}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Remove favorite',
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () => settings.toggleFavorite(city),
                        ),
                        onTap: () async {
                          final selection = settings.selectCity(city);
                          onCitySelected();
                          await selection;
                        },
                        selected: selected,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
