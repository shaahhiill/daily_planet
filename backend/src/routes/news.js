// News routes — defines the API endpoints the Flutter app calls for news data.

const express = require('express');
const router = express.Router();
const { getTopHeadlines, searchNews } = require('../services/newsService');

// GET /api/news/headlines
// Optional query param: ?category=sports
// Returns a list of top news articles.
router.get('/headlines', async (req, res) => {
  try {
    const { category } = req.query; // e.g. ?category=technology
    const articles = await getTopHeadlines(category || null);
    res.json({ articles });
  } catch (error) {
    console.error('Error fetching headlines:', error.message);
    res.status(500).json({ error: 'Failed to fetch news headlines.' });
  }
});

// GET /api/news/search?q=keyword
// Returns articles matching the search keyword.
router.get('/search', async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) return res.status(400).json({ error: 'Missing search query parameter "q".' });

    const articles = await searchNews(q);
    res.json({ articles });
  } catch (error) {
    console.error('Error searching news:', error.message);
    res.status(500).json({ error: 'Failed to search news.' });
  }
});

module.exports = router;
