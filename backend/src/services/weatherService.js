// Weather service — calls OpenWeatherMap using coordinates from the Flutter app.
// Caches results for 10 minutes to avoid excessive API usage.

const axios = require('axios');
const NodeCache = require('node-cache');

const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';

// Cache weather responses for 10 minutes.
const cache = new NodeCache({ stdTTL: 600 });

/**
 * Fetches current weather for a given GPS location.
 * @param {number} lat - Latitude from the device.
 * @param {number} lon - Longitude from the device.
 * @returns {Promise<Object>} Raw weather data from OpenWeatherMap.
 */
async function getWeather(lat, lon) {
  // Round coordinates to 2 decimal places so nearby locations share a cache entry.
  const cacheKey = `weather_${parseFloat(lat).toFixed(2)}_${parseFloat(lon).toFixed(2)}`;
  const cached = cache.get(cacheKey);
  if (cached) return cached; // Return cached result if still fresh.

  const url = `${BASE_URL}?lat=${lat}&lon=${lon}&units=metric&appid=${process.env.WEATHER_API_KEY}`;
  const response = await axios.get(url);

  cache.set(cacheKey, response.data); // Cache the result.
  return response.data;
}

module.exports = { getWeather };
