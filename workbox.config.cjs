module.exports = {
  "cacheId": "icidasset/quotes",
  "clientsClaim": true,
  "globDirectory": "build/",
  "globPatterns": [ "**/*.*" ],
  "runtimeCaching": [
    { urlPattern: /^https:\/\/cdnjs\./, handler: "StaleWhileRevalidate" }
  ],
  "skipWaiting": true,
  "swDest": "build/service-worker.js",
};
