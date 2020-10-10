module.exports = {
  "cacheId": "icidasset/quotes",
  "clientsClaim": true,
  "globDirectory": "build/",
  "globPatterns": [ "**/*.*" ],
  "inlineWorkboxRuntime": true,
  "runtimeCaching": [
    { urlPattern: /^https:\/\/cdnjs\./, handler: "StaleWhileRevalidate" },
    { urlPattern: /^http/, handler: "NetworkFirst" },
    { urlPattern: /(.*)/, handler: "NetworkFirst" }
  ],
  "skipWaiting": true,
  "swDest": "build/service-worker.js",
};
