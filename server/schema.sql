CREATE DATABASE IF NOT EXISTS breeze
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE breeze;

CREATE TABLE IF NOT EXISTS settings (
  setting_key VARCHAR(64) NOT NULL PRIMARY KEY,
  setting_value TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS favorites (
  name VARCHAR(191) NOT NULL,
  country VARCHAR(191) NOT NULL,
  latitude DOUBLE NOT NULL,
  longitude DOUBLE NOT NULL,
  admin1 VARCHAR(191) NULL,
  PRIMARY KEY (name, country)
);

CREATE TABLE IF NOT EXISTS weather_cache (
  city VARCHAR(191) NOT NULL PRIMARY KEY,
  country VARCHAR(191) NOT NULL,
  latitude DOUBLE NOT NULL,
  longitude DOUBLE NOT NULL,
  temperature DOUBLE NOT NULL,
  max_temperature DOUBLE NOT NULL,
  min_temperature DOUBLE NOT NULL,
  humidity INT NOT NULL,
  wind_speed DOUBLE NOT NULL,
  condition_text VARCHAR(191) NOT NULL,
  updated_at VARCHAR(40) NULL
);
