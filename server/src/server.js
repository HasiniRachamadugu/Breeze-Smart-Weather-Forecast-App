import 'dotenv/config';
import express from 'express';
import mysql from 'mysql2/promise';

const requiredEnvironment = ['DB_HOST', 'DB_USER', 'DB_NAME'];
const missingEnvironment = requiredEnvironment.filter(
  (name) => !process.env[name],
);

if (missingEnvironment.length > 0) {
  throw new Error(
    `Missing required server/.env values: ${missingEnvironment.join(', ')}`,
  );
}

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT ?? 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD ?? '',
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
});

const app = express();
app.use(express.json({ limit: '32kb' }));
app.use((request, response, next) => {
  const origin = request.get('origin');
  if (
    origin &&
    !/^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin)
  ) {
    response.status(403).json({ error: 'Origin is not allowed.' });
    return;
  }

  if (origin) {
    response.setHeader('Access-Control-Allow-Origin', origin);
    response.setHeader('Vary', 'Origin');
    response.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    response.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
  }

  if (request.method === 'OPTIONS') {
    response.sendStatus(204);
    return;
  }

  next();
});

app.get('/api/health', async (_request, response, next) => {
  try {
    await pool.query('SELECT 1');
    response.json({ status: 'ok' });
  } catch (error) {
    next(error);
  }
});

app.get('/api/settings/:key', async (request, response, next) => {
  try {
    const [rows] = await pool.execute(
      'SELECT setting_value FROM settings WHERE setting_key = ?',
      [request.params.key],
    );
    response.json({ value: rows[0]?.setting_value ?? null });
  } catch (error) {
    next(error);
  }
});

app.put('/api/settings/:key', async (request, response, next) => {
  const { value } = request.body ?? {};
  if (
    !['city', 'fahrenheit', 'dark'].includes(request.params.key) ||
    typeof value !== 'string'
  ) {
    response.status(400).json({ error: 'Invalid setting.' });
    return;
  }

  try {
    await pool.execute(
      `INSERT INTO settings (setting_key, setting_value) VALUES (?, ?)
       ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)`,
      [request.params.key, value],
    );
    response.sendStatus(204);
  } catch (error) {
    next(error);
  }
});

app.get('/api/favorites', async (_request, response, next) => {
  try {
    const [favorites] = await pool.execute(
      'SELECT name, country, latitude, longitude, admin1 FROM favorites ORDER BY name',
    );
    response.json({ favorites });
  } catch (error) {
    next(error);
  }
});

app.post('/api/favorites', async (request, response, next) => {
  const { name, country, latitude, longitude, admin1 } = request.body ?? {};
  if (
    typeof name !== 'string' ||
    !name.trim() ||
    typeof country !== 'string' ||
    !country.trim() ||
    !Number.isFinite(latitude) ||
    !Number.isFinite(longitude) ||
    (admin1 != null && typeof admin1 !== 'string')
  ) {
    response.status(400).json({ error: 'Invalid favorite city.' });
    return;
  }

  try {
    await pool.execute(
      `INSERT INTO favorites (name, country, latitude, longitude, admin1)
       VALUES (?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         latitude = VALUES(latitude),
         longitude = VALUES(longitude),
         admin1 = VALUES(admin1)`,
      [name, country, latitude, longitude, admin1 ?? null],
    );
    response.sendStatus(204);
  } catch (error) {
    next(error);
  }
});

app.delete('/api/favorites', async (request, response, next) => {
  const { name, country } = request.body ?? {};
  if (typeof name !== 'string' || typeof country !== 'string') {
    response.status(400).json({ error: 'Invalid favorite city.' });
    return;
  }

  try {
    await pool.execute(
      'DELETE FROM favorites WHERE name = ? AND country = ?',
      [name, country],
    );
    response.sendStatus(204);
  } catch (error) {
    next(error);
  }
});

app.get('/api/weather/:city', async (request, response, next) => {
  try {
    const [rows] = await pool.execute(
      `SELECT city, country, latitude, longitude, temperature,
              max_temperature, min_temperature, humidity, wind_speed,
              condition_text, updated_at
       FROM weather_cache WHERE city = ?`,
      [request.params.city],
    );
    const row = rows[0];
    response.json({
      weather: row
        ? {
            city: row.city,
            country: row.country,
            latitude: row.latitude,
            longitude: row.longitude,
            temperature: row.temperature,
            max_temperature: row.max_temperature,
            min_temperature: row.min_temperature,
            humidity: row.humidity,
            wind_speed: row.wind_speed,
            condition: row.condition_text,
            updated_at: row.updated_at,
          }
        : null,
    });
  } catch (error) {
    next(error);
  }
});

app.put('/api/weather/:city', async (request, response, next) => {
  const {
    city,
    country,
    latitude,
    longitude,
    temperature,
    max_temperature: maxTemperature,
    min_temperature: minTemperature,
    humidity,
    wind_speed: windSpeed,
    condition,
    updated_at: updatedAt,
  } = request.body ?? {};
  if (
    city !== request.params.city ||
    typeof country !== 'string' ||
    typeof condition !== 'string' ||
    !Number.isFinite(latitude) ||
    !Number.isFinite(longitude) ||
    !Number.isFinite(temperature) ||
    !Number.isFinite(maxTemperature) ||
    !Number.isFinite(minTemperature) ||
    !Number.isInteger(humidity) ||
    !Number.isFinite(windSpeed) ||
    (updatedAt != null && typeof updatedAt !== 'string')
  ) {
    response.status(400).json({ error: 'Invalid weather cache entry.' });
    return;
  }

  try {
    await pool.execute(
      `INSERT INTO weather_cache
         (city, country, latitude, longitude, temperature, max_temperature,
          min_temperature, humidity, wind_speed, condition_text, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         country = VALUES(country),
         latitude = VALUES(latitude),
         longitude = VALUES(longitude),
         temperature = VALUES(temperature),
         max_temperature = VALUES(max_temperature),
         min_temperature = VALUES(min_temperature),
         humidity = VALUES(humidity),
         wind_speed = VALUES(wind_speed),
         condition_text = VALUES(condition_text),
         updated_at = VALUES(updated_at)`,
      [
        city,
        country,
        latitude,
        longitude,
        temperature,
        maxTemperature,
        minTemperature,
        humidity,
        windSpeed,
        condition,
        updatedAt ?? null,
      ],
    );
    response.sendStatus(204);
  } catch (error) {
    next(error);
  }
});

app.use((error, _request, response, _next) => {
  console.error('Breeze API error:', error);
  if (response.headersSent) return;
  response.status(500).json({ error: 'The local database request failed.' });
});


const port = Number(process.env.API_PORT ?? 3000);

const server = app.listen(port, '0.0.0.0', () => {
  console.log(`Breeze API listening on port ${port}`);
});

async function shutdown() {
  server.close();
  await pool.end();
}

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
