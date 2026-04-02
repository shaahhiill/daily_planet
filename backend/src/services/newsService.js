// News service — responsible for calling NewsAPI and returning results.
// All API keys stay here on the server; the Flutter app never sees them.

const axios = require('axios');
const NodeCache = require('node-cache');

const BASE_URL = 'https://newsapi.org/v2';

// Cache news responses for 5 minutes to avoid hitting the API too often.
const cache = new NodeCache({ stdTTL: 300 });

/**
 * Fetches top headlines from NewsAPI.
 * @param {string|null} category - Optional category filter (e.g. "sports", "technology").
 * @returns {Promise<Array>} List of article objects.
 */
async function getTopHeadlines(category = null) {
  // Build a unique cache key based on the category.
  const cacheKey = `headlines_${category || 'all'}`;
  const cached = cache.get(cacheKey);
  if (cached) return cached; // Return cached data if it's still fresh.

  // Build the NewsAPI URL.
  let url = `${BASE_URL}/top-headlines?country=us&apiKey=${process.env.NEWS_API_KEY}`;
  if (category) url += `&category=${category}`;

  const response = await axios.get(url);
  const articles = response.data.articles;

  cache.set(cacheKey, articles); // Save result to cache.
  return articles;
}

/**
 * Searches for news articles matching a keyword.
 * @param {string} query - The search keyword.
 * @returns {Promise<Array>} List of matching article objects.
 */
async function searchNews(query) {
  const cacheKey = `search_${query}`;
  const cached = cache.get(cacheKey);
  if (cached) return cached;

  const url = `${BASE_URL}/everything?q=${query}&sortBy=publishedAt&apiKey=${process.env.NEWS_API_KEY}`;
  const response = await axios.get(url);
  const articles = response.data.articles;

  cache.set(cacheKey, articles);
  return articles;
}

module.exports = { getTopHeadlines, searchNews };
