module.exports = {
  "cacheId": "icidasset/quotes",
  "clientsClaim": true,
  "globDirectory": "build/",
  "globPatterns": [ "**/*" ],
  "inlineWorkboxRuntime": true,
  "runtimeCaching": [
    { urlPattern: /^https:\/\/cdnjs\./, handler: "StaleWhileRevalidate" },
    { urlPattern: /^https:\/\/fonts\./, handler: "StaleWhileRevalidate" }
  ],
  "skipWaiting": true,
  "swDest": "build/service-worker.js",
};
