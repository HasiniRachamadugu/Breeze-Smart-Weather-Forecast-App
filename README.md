# Breeze – Smart Weather Forecast

Breeze is a responsive Flutter weather app built with Material 3. App settings,
favorite cities, and cached weather are stored in a local MySQL database through
a small API running on the same computer. Weather forecasts come from the
configured weather service.

## Features

- Splash screen and bottom navigation for Home, Forecast, Favorites, and Settings
- City search for Hyderabad, Bhimavaram, Visakhapatnam, Bengaluru, Chennai,
  Mumbai, and Delhi
- Current conditions, detailed weather information, and a seven-day sample
  forecast
- Shared selected-city and favorites state
- Light/dark theme and Celsius/Fahrenheit settings
- App information

## Run the app

### Start the local MySQL API

1. Start MySQL Server and open MySQL Workbench.
2. In Workbench, open and execute [`server/schema.sql`](server/schema.sql) to
   create the `breeze` database and its tables.
3. Copy `server/.env.example` to `server/.env`. Set `DB_USER` and `DB_PASSWORD`
   to a MySQL account that can read and write the `breeze` database. Keep this
   file private; it is excluded from version control.
4. From the `server` folder, install the API dependencies and start the API:

```shell
cd server
npm install
npm start
```

Keep the API running while using Breeze. It listens only on this computer at
`http://127.0.0.1:3000`.

### Run Breeze

In another terminal, from the project root:

```shell
flutter pub get
flutter run -d chrome
```

The API deliberately listens only on the laptop. Run Breeze in the laptop's
browser; Android emulators and other devices cannot reach this local-only
server. To use another API address, set `BREEZE_API_BASE_URL`, for example:

```shell
flutter run -d chrome --dart-define=BREEZE_API_BASE_URL=http://127.0.0.1:3000/api
```

This is a local development setup, not a public or multi-user deployment.

## Verify

```shell
flutter analyze
flutter test
```

The widget tests use an in-memory test store; the running app uses MySQL.

## Source layout

- `lib/main.dart` – application entry point, Material 3 themes, and app colors
- `lib/models/weather_data.dart` – local city and forecast sample models
- `lib/utils/app_settings.dart` – shared app state and temperature formatting
- `lib/widgets/` – reusable weather and forecast cards
- `lib/screens/` – splash, navigation, home, search, forecast, details,
  favorites, and settings screens
