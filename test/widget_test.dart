import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:breeze/main.dart';
import 'package:breeze/models/weather_data.dart';
import 'package:breeze/services/database_service.dart';
import 'package:breeze/services/weather_api_service.dart';

void main() {
  setUp(() {
    DatabaseService.instance.useInMemoryStoreForTesting();
  });

  test(
    'sample forecast uses the correct weekdays for the current date',
    () async {
      final today = DateTime.now();
      const city = CityResult(
        name: 'Hyderabad',
        country: 'India',
        latitude: 17.3850,
        longitude: 78.4867,
      );

      final forecast = await WeatherApiService.instance.fetchForecast(city);
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      expect(forecast, hasLength(7));
      expect(forecast.first.day, 'Today');
      for (var index = 1; index < forecast.length; index++) {
        final date = today.add(Duration(days: index));
        expect(forecast[index].day, weekdays[date.weekday - 1]);
      }
    },
  );

  testWidgets('Breeze opens the forecast and supports city search', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BreezeApp());

    expect(find.text('Breeze'), findsOneWidget);
    expect(find.text('Smart Weather Forecast'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Hyderabad, India'), findsOneWidget);

    await tester.tap(find.byTooltip('Search city'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Visakhapatnam');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Search city'), findsOneWidget);
    expect(find.text('Andhra Pradesh, India'), findsOneWidget);

    await tester.tap(find.byType(ListTile).last);
    await tester.pumpAndSettle();

    expect(find.text('Visakhapatnam, India'), findsOneWidget);
    expect(find.text('28°C'), findsOneWidget);
  });

  testWidgets('Selecting a favorite opens its weather on Home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BreezeApp());
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add to favorites'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('Visakhapatnam'), findsOneWidget);
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    expect(find.text('Breeze'), findsOneWidget);
    expect(find.text('Visakhapatnam, India'), findsOneWidget);
    expect(find.text('28°C'), findsOneWidget);
  });

  testWidgets('About Breeze does not show a licenses action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BreezeApp());
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Notifications'), findsNothing);
    expect(find.text('Weather notifications'), findsNothing);
    expect(find.text('Local storage'), findsNothing);
    expect(find.text('SQLite database'), findsNothing);
    await tester.tap(find.text('About Breeze'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Version 1.0.0'), findsOneWidget);
    expect(find.text('View licenses'), findsNothing);
    expect(find.text('Close'), findsOneWidget);
  });
}
