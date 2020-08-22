module.exports = {
  "cacheId": "icidasset/quotes",
  "clientsClaim": true,
  "globDirectory": "build/",
  "globPatterns": [ "**/*.*" ],
  "runtimeCaching": [
    { urlPattern: /^https:\/\/cdnjs\./, handler: "StaleWhileRevalidate" },
    { urlPattern: /^.*$/, handler: "NetworkFirst" }
  ],
  "skipWaiting": true,
  "swDest": "build/service-worker.js",
};
