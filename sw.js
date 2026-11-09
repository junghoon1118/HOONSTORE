// HOONSTORE 오프라인 캐시.
// 스토어는 사이트 최상위(/)에 있어서 /SQLD/ 같은 다른 앱 경로까지 범위에 들어온다.
// 다른 앱은 각자 서비스 워커가 따로 있으므로, 스토어 파일 경로만 처리한다.
const CACHE = 'hoonstore-v1';
const ASSETS = ['./', './index.html', './manifest.webmanifest', './icons/icon-192.png', './icons/icon-512.png'];
const MINE = (path) => {
  const base = new URL('./', self.registration.scope).pathname;
  const rest = path.startsWith(base) ? path.slice(base.length) : null;
  if (rest === null) return false;
  return rest === '' || rest === 'index.html' || rest === 'manifest.webmanifest' || rest.startsWith('icons/') || rest.startsWith('assets/');
};

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(ASSETS)));
  self.skipWaiting();
});

self.addEventListener('activate', (e) => {
  e.waitUntil(caches.keys().then((keys) => Promise.all(keys.filter((k) => k.startsWith('hoonstore-') && k !== CACHE).map((k) => caches.delete(k)))));
  self.clients.claim();
});

self.addEventListener('fetch', (e) => {
  if (e.request.method !== 'GET') return;
  const url = new URL(e.request.url);

  if (url.origin === location.origin) {
    if (!MINE(url.pathname)) return; // 다른 앱 경로는 건드리지 않음
    e.respondWith(
      fetch(e.request)
        .then((res) => {
          const copy = res.clone();
          caches.open(CACHE).then((c) => c.put(e.request, copy));
          return res;
        })
        .catch(() => caches.match(e.request).then((r) => r || caches.match('./index.html')))
    );
    return;
  }

  if (url.hostname === 'fonts.googleapis.com' || url.hostname === 'fonts.gstatic.com') {
    e.respondWith(
      caches.match(e.request).then((hit) =>
        hit ||
        fetch(e.request).then((res) => {
          const copy = res.clone();
          caches.open(CACHE).then((c) => c.put(e.request, copy));
          return res;
        })
      )
    );
  }
});
