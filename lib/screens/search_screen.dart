import 'dart:async';

import 'package:flutter/material.dart';

import '../models/weather_data.dart';
import '../utils/app_settings.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  Timer? _debounce;
  List<CityResult> _results = [];
  bool _loading = false;
  bool _isSelecting = false;
  String? _error;
  int _searchSequence = 0;

  Future<void> _search(String query, int sequence) async {
    if (query.trim().length < 2) {
      setState(() {
        _results = [];
        _error = null;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await AppSettings.instance.searchCities(query.trim());

      if (!mounted ||
          sequence != _searchSequence ||
          query.trim() != _controller.text.trim()) {
        return;
      }

      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (_) {
      if (!mounted ||
          sequence != _searchSequence ||
          query.trim() != _controller.text.trim()) {
        return;
      }

      setState(() {
        _error = 'Unable to search. Check your internet connection.';
        _loading = false;
      });
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final sequence = ++_searchSequence;
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _search(value, sequence),
    );
  }

  Future<void> _selectCity(CityResult city) async {
    if (_isSelecting) return;

    _debounce?.cancel();
    _searchSequence++;
    setState(() => _isSelecting = true);
    final selection = AppSettings.instance.selectCity(city);

    if (mounted) {
      Navigator.pop(context);
    }
    await selection;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search city')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: 'Enter a city name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    _onChanged('');
                  },
                ),
              ),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          if (_isSelecting) const LinearProgressIndicator(),
          if (_error != null)
            Padding(padding: const EdgeInsets.all(16), child: Text(_error!)),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Text(
                      _loading
                          ? 'Searching...'
                          : 'Search for a city to see results.',
                    ),
                  )
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final city = _results[index];

                      return ListTile(
                        leading: const Icon(Icons.location_city),
                        title: Text(city.name),
                        subtitle: Text(
                          city.admin1 == null || city.admin1!.isEmpty
                              ? city.country
                              : '${city.admin1}, ${city.country}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        enabled: !_isSelecting,
                        onTap: () => _selectCity(city),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
