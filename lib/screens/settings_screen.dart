import 'package:flutter/material.dart';

import '../utils/app_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateBuilder(
      builder: (context, settings) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            children: [
              const ListTile(
                title: Text(
                  'Appearance',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark mode'),
                subtitle: const Text('Use a darker app theme'),
                value: settings.isDarkMode,
                onChanged: settings.setDarkMode,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Breeze'),
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('About Breeze'),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Smart Weather Forecast'),
                            SizedBox(height: 12),
                            Text('Version 1.0.0'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const Divider(),
              const ListTile(
                title: Text(
                  'Temperature',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.thermostat),
                title: const Text('Fahrenheit'),
                subtitle: Text(
                  settings.isFahrenheit
                      ? 'Temperatures are shown in °F'
                      : 'Temperatures are shown in °C',
                ),
                value: settings.isFahrenheit,
                onChanged: settings.setFahrenheit,
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.cloud_outlined),
                title: Text('Weather provider'),
                subtitle: Text('Open-Meteo'),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  onPressed: settings.refreshWeather,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh weather data'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}