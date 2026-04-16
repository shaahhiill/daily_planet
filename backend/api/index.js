const express = require('express');
const axios = require('axios');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Enable CORS so your Flutter app can talk to this server
app.use(cors({
    origin: process.env.ALLOWED_ORIGIN || '*'
}));

app.use(express.json());

// ─── Simple In-Memory Cache ──────────────────────────────────────────────
// This keeps data for a limited time to avoid hitting API rate limits.
const cache = {
    news: {},
    weather: {},
};

const CACHE_DURATION = 10 * 60 * 1000; // 10 minutes in milliseconds

// ─── News Endpoints ──────────────────────────────────────────────────────

app.get('/api/news', async (req, res) => {
    const { category, country = 'us', q } = req.query;
    const apiKey = process.env.NEWS_API_KEY;
    
    // Create a unique key for this specific request
    const cacheKey = `news_${category || 'all'}_${country}_${q || 'none'}`;
    const now = Date.now();

    // Check if we have a fresh cached version
    if (cache.news[cacheKey] && (now - cache.news[cacheKey].timestamp) < CACHE_DURATION) {
        console.log(`[Cache] Serving ${cacheKey}`);
        return res.json(cache.news[cacheKey].data);
    }

    try {
        console.log(`[API] Fetching news for ${cacheKey}`);
        let url = `https://newsapi.org/v2/top-headlines?apiKey=${apiKey}&country=${country}`;
        if (category) url += `&category=${category}`;
        if (q) url += `&q=${q}`;

        const response = await axios.get(url);
        
        // Cache the result
        cache.news[cacheKey] = {
            timestamp: now,
            data: response.data
        };

        res.json(response.data);
    } catch (error) {
        console.error('[Error] News API:', error.message);
        res.status(error.response?.status || 500).json({
            error: 'Failed to fetch news',
            message: error.message
        });
    }
});

// ─── Weather Endpoints ───────────────────────────────────────────────────

app.get('/api/weather', async (req, res) => {
    const { lat, lon, units = 'metric' } = req.query;
    const apiKey = process.env.WEATHER_API_KEY;

    if (!lat || !lon) {
        return res.status(400).json({ error: 'Latitude and longitude are required' });
    }

    try {
        const url = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&units=${units}&appid=${apiKey}`;
        const response = await axios.get(url);
        res.json(response.data);
    } catch (error) {
        console.error('[Error] Weather API:', error.message);
        res.status(error.response?.status || 500).json({
            error: 'Failed to fetch weather',
            message: error.message
        });
    }
});

app.get('/api/forecast', async (req, res) => {
    const { lat, lon, units = 'metric' } = req.query;
    const apiKey = process.env.WEATHER_API_KEY;

    if (!lat || !lon) {
        return res.status(400).json({ error: 'Latitude and longitude are required' });
    }

    try {
        const url = `https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&units=${units}&appid=${apiKey}`;
        const response = await axios.get(url);
        res.json(response.data);
    } catch (error) {
        console.error('[Error] Forecast API:', error.message);
        res.status(error.response?.status || 500).json({
            error: 'Failed to fetch forecast',
            message: error.message
        });
    }
});

// ─── Base Route ──────────────────────────────────────────────────────────

app.get('/', (req, res) => {
    res.json({
        message: 'Daily Planet API is running!',
        endpoints: ['/api/news', '/api/weather', '/api/forecast']
    });
});

// Start server (only if running locally, Vercel ignores this)
if (process.env.NODE_ENV !== 'production') {
    app.listen(PORT, () => {
        console.log(`Server running at http://localhost:${PORT}`);
    });
}

module.exports = app;
