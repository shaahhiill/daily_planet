const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

// API key stored securely in Firebase Secret Manager — never shipped in the app.
const NEWS_API_KEY = defineSecret("NEWS_API_KEY");

// Categories to fetch and cache.
const CATEGORIES = ["general", "technology", "sports", "science", "health", "business", "entertainment"];

// ─── Scheduled Function ────────────────────────────────────────────────────────
// Runs every 30 minutes automatically on Firebase's servers.
// Fetches headlines for every category and stores them in Firestore.
// The Flutter app reads from Firestore — no API call needed on app open.
exports.cacheNews = onSchedule(
  { schedule: "every 30 minutes", secrets: [NEWS_API_KEY] },
  async () => {
    const apiKey = NEWS_API_KEY.value();
    const batch = db.batch(); // Batch write — saves all categories in one go.

    for (const category of CATEGORIES) {
      try {
        const url = `https://newsapi.org/v2/top-headlines?country=us&category=${category}&apiKey=${apiKey}`;
        const response = await axios.get(url);
        const articles = response.data.articles;

        // Store articles in Firestore: newsCache/{category}
        const ref = db.collection("newsCache").doc(category);
        batch.set(ref, {
          articles,
          cachedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(`Cached ${articles.length} articles for: ${category}`);
      } catch (err) {
        console.error(`Failed to cache ${category}:`, err.message);
      }
    }

    await batch.commit();
    console.log("News cache updated successfully.");
  }
);

// ─── HTTP Function ─────────────────────────────────────────────────────────────
// Called once manually (or on first app open) to trigger an immediate cache fill
// without waiting for the 30-minute schedule.
// URL: https://us-central1-dailyplanet-72e33.cloudfunctions.net/refreshNewsNow
exports.refreshNewsNow = onRequest(
  { secrets: [NEWS_API_KEY] },
  async (req, res) => {
    const apiKey = NEWS_API_KEY.value();
    const batch = db.batch();

    for (const category of CATEGORIES) {
      try {
        const url = `https://newsapi.org/v2/top-headlines?country=us&category=${category}&apiKey=${apiKey}`;
        const response = await axios.get(url);
        const ref = db.collection("newsCache").doc(category);
        batch.set(ref, {
          articles: response.data.articles,
          cachedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (err) {
        console.error(`Failed for ${category}:`, err.message);
      }
    }

    await batch.commit();
    res.json({ success: true, message: "News cache refreshed." });
  }
);
