# Node.js Backend for Daily Planet

## Can it be done? Yes, absolutely.

Right now the Flutter app talks **directly** to two third-party APIs:
- **NewsAPI** → fetches headlines & search results
- **OpenWeatherMap** → fetches weather by GPS coordinates

Your API keys live inside the app's `.env` file, which is a security risk (anyone who decompiles the APK can extract them). A Node.js backend sits in the middle — the app talks to *your* server, and only your server ever talks to the third-party APIs.

---

## What the Backend Would Do

| Responsibility | Details |
|---|---|
| **Proxy News requests** | Flutter asks your server for news; server calls NewsAPI and returns results |
| **Proxy Weather requests** | Flutter sends lat/lon; server calls OpenWeatherMap and returns weather |
| **Hide API keys** | Keys live on the server only, never shipped inside the app |
| **User auth (optional)** | Could replace or complement Firebase Auth |
| **Saved articles sync (optional)** | Store saved articles in a database instead of locally |
| **Caching** | Cache API responses for a few minutes to reduce API calls & speed up the app |

---

## Tech Stack

| Layer | Choice |
|---|---|
| Runtime | Node.js |
| Framework | Express.js |
| HTTP client | Axios (calls NewsAPI / OWM) |
| Caching | node-cache or Redis |
| Hosting | Railway / Render / any VPS |

---

## Folder Structure

```
daily_planet_backend/
├── src/
│   ├── routes/
│   │   ├── news.js       ← /api/news endpoints
│   │   └── weather.js    ← /api/weather endpoint
│   ├── services/
│   │   ├── newsService.js    ← calls NewsAPI
│   │   └── weatherService.js ← calls OpenWeatherMap
│   └── index.js          ← Express app entry point
├── .env                  ← API keys (server-side only)
├── package.json
└── README.md
```

---

## API Endpoints

### News
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/news/headlines` | Top headlines (optional `?category=sports`) |
| GET | `/api/news/search?q=keyword` | Search articles by keyword |

### Weather
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/weather?lat=xx&lon=yy` | Weather for a given GPS coordinate |

---

## How the Flutter App Would Change

Only [news_service.dart](file:///c:/Users/shaah/OneDrive/Desktop/daily_planet/lib/services/news_service.dart) and [weather_service.dart](file:///c:/Users/shaah/OneDrive/Desktop/daily_planet/lib/services/weather_service.dart) need to change:

```dart
// BEFORE (calls third-party API directly)
final url = 'https://newsapi.org/v2/top-headlines?apiKey=$_apikey';

// AFTER (calls your own backend)
final url = 'https://your-backend.com/api/news/headlines';
```

The API keys are **removed from the Flutter app entirely**.

---

## Phases

### Phase 1 — Core Proxy Server
- Set up Express.js project
- Add `/api/news` and `/api/weather` routes
- Move API keys out of the app and into the server `.env`
- Update Flutter services to point at the new backend

### Phase 2 — Caching
- Cache news responses for ~5 minutes
- Cache weather responses for ~10 minutes
- Reduces API quota usage significantly

### Phase 3 — Optional Extras
- Add user endpoints (login, saved articles) if moving away from Firebase
- Add rate limiting to prevent abuse
- Deploy to a hosting platform

---

> This is a **plan only** — no code has been written yet. Let me know if you'd like to proceed with building it.
