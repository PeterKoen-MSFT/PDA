const { chromium } = require("C:/Program Files (x86)/Microsoft Scout/resources/app.asar.unpacked/node_modules/playwright-core");
(async () => {
  const browser = await chromium.connectOverCDP("http://127.0.0.1:9222");
  const pages = browser.contexts().flatMap(c => c.pages());
  console.log("PAGE_COUNT=" + pages.length);
  for (let i = 0; i < pages.length; i++) {
    const p = pages[i];
    const url = p.url();
    const title = await p.title();
    console.log("PAGE[" + i + "] URL=" + url);
    console.log("PAGE[" + i + "] TITLE=" + title);
    const body = await p.evaluate(() => document.body ? document.body.innerText : "");
    const lower = (body + "\n" + url).toLowerCase();
    const hits = ["api key","access token","dashboard","account","settings","developer","request access","token","api-key","access-token"];
    const matched = hits.filter(h => lower.includes(h.toLowerCase()));
    if (matched.length) console.log("PAGE[" + i + "] MATCHES=" + matched.join(" | "));
    const visible = await p.evaluate(() => Array.from(document.querySelectorAll("a,button,[role='button'],[role='link'],summary,div,p,span,li")).map(el => {
      const text = (el.textContent || "").replace(/\s+/g, " ").trim();
      const href = (el.href || el.getAttribute("href") || "").trim();
      const aria = (el.getAttribute("aria-label") || "").trim();
      return { text: text.slice(0, 200), href: href.slice(0, 200), aria: aria.slice(0, 200) };
    }).filter(x => x.text || x.href || x.aria).slice(0, 80));
    console.log("PAGE[" + i + "] VISIBLE=" + JSON.stringify(visible));
    console.log("PAGE[" + i + "] BODY_SNIPPET=" + (body || "").replace(/\s+/g, " ").trim().slice(0, 1500));
  }
  await browser.close();
})();
