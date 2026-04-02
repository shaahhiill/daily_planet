// Weather routes — the Flutter app sends its GPS coordinates here,
// and the server fetches weather from OpenWeatherMap on its behalf.

const express = require('express');
const router = express.Router();
const { getWeather } = require('../services/weatherService');

// GET /api/weather?lat=12.34&lon=56.78
// Returns current weather for the given GPS coordinates.
router.get('/', async (req, res) => {
  try {
    const { lat, lon } = req.query;

    // Both lat and lon are required.
    if (!lat || !lon) {
      return res.status(400).json({ error: 'Missing required query params: lat and lon.' });
    }

    const weather = await getWeather(lat, lon);
    res.json(weather); // Pass the OWM response directly to the app.
  } catch (error) {
    console.error('Error fetching weather:', error.message);
    res.status(500).json({ error: 'Failed to fetch weather data.' });
  }
});

module.exports = router;
