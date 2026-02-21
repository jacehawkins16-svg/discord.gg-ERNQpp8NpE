self.addEventListener('install', function(event) {
  event.waitUntil(self.skipWaiting());
});

self.addEventListener('activate', function(event) {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', function(event) {
  const blockedUrl = 'jacehawkins16-svg.github.io/discord.gg-ERNQpp8NpE/vantahood.lua';
  const requestUrl = new URL(event.request.url);

  // Auto-detect if the requested URL matches the blocked one (case-insensitive, ignores protocol/host if same origin)
  if (requestUrl.pathname.toLowerCase().endsWith('/discord.gg-ernqpp8npe/vantahood.lua')) {
    event.respondWith(
      new Response('Access denied: This file is protected.', {
        status: 403,
        statusText: 'Forbidden'
      })
    );
  }
  // Otherwise, let the request proceed normally
});
