const response = await fetch('http://127.0.0.1:9222/json/list', { signal: AbortSignal.timeout(5000) });
if (!response.ok) throw new Error(`Edge CDP returned ${response.status}`);
const pages = await response.json();
const demoPages = pages.filter(page => {
  try {
    const url = new URL(page.url);
    return page.type === 'page' && ['http://localhost:8110', 'http://127.0.0.1:8110'].includes(url.origin)
      && ['/', '/index.html', '/chat', '/chat.html', '/admin', '/admin.html', '/compliance', '/compliance.html'].includes(url.pathname);
  } catch { return false; }
});
console.log(JSON.stringify({ demoPages: demoPages.map(page => ({ path: new URL(page.url).pathname })) }));
