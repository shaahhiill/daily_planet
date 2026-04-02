// Entry point for the Daily Planet backend server.
// Loads environment variables, sets up Express, and registers all routes.

require('dotenv').config(); // Load .env file (API keys, PORT, etc.)

const express = require('express');
const cors = require('cors');
const newsRoutes = require('./routes/news');
const weatherRoutes = require('./routes/weather');

const app = express();
const PORT = process.env.PORT || 3000;

// Allow requests from any origin (needed so the Flutter app can reach the server).
app.use(cors());

// Parse incoming JSON request bodies.
app.use(express.json());

// Register route groups.
app.use('/api/news', newsRoutes);       // e.g. GET /api/news/headlines
app.use('/api/weather', weatherRoutes); // e.g. GET /api/weather?lat=xx&lon=yy

// Simple health check — useful to confirm the server is running.
app.get('/', (req, res) => {
  res.json({ status: 'Daily Planet backend is running!' });
});

// Start listening for requests.
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
