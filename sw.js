/* Service Worker — cache do app para funcionar offline.
   Mantém o app servido pela origem HTTPS mesmo sem internet,
   o que é necessário para a câmera (leitura de QR) e o WebRTC. */
const CACHE = 'tvweb-prompter-v1';
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './libs/lz-string.min.js',
  './libs/qrcode.min.js',
  './libs/jsQR.min.js'
];

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys().then((nomes) =>
      Promise.all(nomes.filter((n) => n !== CACHE).map((n) => caches.delete(n)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET') return;
  // Cache-first para o app; rede como fallback (e atualiza cache quando online).
  e.respondWith(
    caches.match(req).then((cacheado) => {
      const rede = fetch(req).then((resp) => {
        if (resp && resp.status === 200 && resp.type === 'basic') {
          const copia = resp.clone();
          caches.open(CACHE).then((c) => c.put(req, copia));
        }
        return resp;
      }).catch(() => cacheado);
      return cacheado || rede;
    })
  );
});
