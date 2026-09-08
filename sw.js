/* Service Worker — cache do app para funcionar offline.
   Com o servidor local (server.js no Termux) o app já roda sem
   internet; o cache serve para abrir rápido e sobreviver a quedas
   momentâneas do servidor. */
const CACHE = 'tvweb-prompter-v5';
const ASSETS = [
  './',
  './index.html',
  './manifest.json'
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
  // Não intercepta os endpoints do servidor local (sincronização SSE/POST).
  const u = new URL(req.url);
  if (u.pathname === '/events' || u.pathname === '/update') return;

  // Navegação / HTML: REDE PRIMEIRO (sempre pega a versão fresca quando
  // online; só cai para o cache se estiver offline). Evita que o app
  // fique "preso" numa versão antiga e quebrada após uma atualização.
  const ehHTML = req.mode === 'navigate' ||
    (req.headers.get('accept') || '').includes('text/html');
  if (ehHTML) {
    e.respondWith(
      fetch(req).then((resp) => {
        if (resp && resp.status === 200 && resp.type === 'basic') {
          const copia = resp.clone();
          caches.open(CACHE).then((c) => c.put(req, copia));
        }
        return resp;
      }).catch(() => caches.match(req).then((c) => c || caches.match('./index.html')))
    );
    return;
  }

  // Demais recursos (libs, manifest, ícones): cache primeiro, rede como
  // fallback (e atualiza o cache quando online).
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
