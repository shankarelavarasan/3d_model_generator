const TEMP = "flutter-app-cache";
const CACHE_NAME = "flutter-app-cache-v2";
const TEMP = "temp-cache";
const MANIFEST = "flutter-app-manifest";
const TIMEOUT_DURATION = 10000; // 10 seconds timeout
const RETRY_ATTEMPTS = 3;

const RESOURCES = {
  "version.json": "009c9e65172e010890f7f65fde438006",
  "index.html": "f679521fb5f22b18874de9a161e38532",
  "main.dart.js": "3816dcc41c9c9c104c352702ca4b647c",
  "flutter.js": "f393d3c16b631f36852323de8e583132",
  "favicon.png": "5dcef449791fa27946b3d35ad8803796",
  "icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
  "icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
  "icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
  "icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
  "manifest.json": "b58fcfa7628c9205cb11a1b2c3e8f99a",
  "assets/AssetManifest.json": "2efbb41d7877d10aac9d091f58ccd7b9",
  "assets/NOTICES": "d59dce0aa2c226b0e7b5b8b5b5b5b5b5",
  "assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
  "assets/AssetManifest.bin.json": "69a99f98c8b1fb8111c5fb961769fcd8",
  "assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
  "assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
  "assets/AssetManifest.bin": "693635b5258fe5f1cda720cf224f158c",
  "assets/fonts/MaterialIcons-Regular.otf": "0db35ae7a415370b89e807027510caf0",
  "canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
  "canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
  "canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
  "canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
  "canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
  "canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f",
  "canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d6",
  "canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
  "canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
  "canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03"
};

// Utility function for timeout handling
function fetchWithTimeout(request, timeout = TIMEOUT_DURATION) {
  return Promise.race([
    fetch(request),
    new Promise((_, reject) => 
      setTimeout(() => reject(new Error('Request timeout')), timeout)
    )
  ]);
}

// Retry mechanism for failed requests
async function fetchWithRetry(request, retries = RETRY_ATTEMPTS) {
  for (let i = 0; i < retries; i++) {
    try {
      return await fetchWithTimeout(request);
    } catch (error) {
      console.warn(`Fetch attempt ${i + 1} failed:`, error.message);
      if (i === retries - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1))); // Exponential backoff
    }
  }
}

// The application shell files that are downloaded before a user can
// use your application. For performance reasons, it is a good practice
// to cache these files (to create a PWA). See https://developers.google.com/web/fundamentals/primers/service-workers/
const CORE = [
  "main.dart.js",
  "index.html",
  "flutter_bootstrap.js",
  "assets/AssetManifest.bin.json",
  "assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {cache: 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// Enhanced fetch handler with timeout and retry mechanisms
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  
  // Enhanced handling for non-resource requests
  if (!RESOURCES[key]) {
    return event.respondWith(
      fetchWithRetry(event.request)
        .catch(error => {
          console.error('Failed to fetch non-resource:', error);
          // Return offline fallback if available
          return caches.match('/index.html');
        })
    );
  }
  
  // Enhanced caching strategy for resource requests
  event.respondWith(
    caches.open(CACHE_NAME)
      .then(cache => {
        return cache.match(event.request).then(response => {
          if (response) {
            // Return cached response immediately
            return response;
          }
          
          // Fetch with timeout and retry for cache miss
          return fetchWithRetry(event.request)
            .then(networkResponse => {
              if (networkResponse && networkResponse.ok) {
                // Clone and cache the response
                cache.put(event.request, networkResponse.clone());
              }
              return networkResponse;
            })
            .catch(error => {
              console.error('Failed to fetch resource:', key, error);
              // Return a basic error response
              return new Response('Resource unavailable', {
                status: 503,
                statusText: 'Service Unavailable'
              });
            });
        });
      })
      .catch(error => {
        console.error('Cache operation failed:', error);
        return fetchWithRetry(event.request);
      })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentCacheNames = await contentCache.keys();
  for (var request of currentCacheNames) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    resources.push(key);
  }
  return contentCache.addAll(resources);
}

const MANIFEST = 'flutter-app-manifest';