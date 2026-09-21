const assert = require('node:assert/strict');
const {chromium, expect} = require('@playwright/test');
const {context, render, product} = require('./bolsas-eora-harness.cjs');
const base = 'http://127.0.0.1:4175';
const executablePath = process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe';
const initial = context();
const data = {...initial, settings: {...initial.settings,
    bolsas_eora_models: [{image:'/fixtures/image-0.webp', link:'maxivertice'}],
    bolsas_eora_best_enabled:false, bolsas_eora_community_enabled:false, bolsas_eora_categories_enabled:false,
}};

(async () => {
    const browser = await chromium.launch({headless:true, executablePath});
    try {
        for (const largeFeed of [false, true]) {
            const page = await browser.newPage();
            const errors = [];
            page.on('pageerror', error => errors.push(error.message));
            let requests = 0;
            let shellImages = 0;
            await page.addInitScript(() => {
                window.searchDocumentsParsed = 0;
                const parse = DOMParser.prototype.parseFromString;
                DOMParser.prototype.parseFromString = function (...args) {
                    window.searchDocumentsParsed++;
                    return parse.apply(this, args);
                };
            });
            await page.route(base + '/**', async route => {
                const url = new URL(route.request().url());
                if (url.pathname === '/') return route.fulfill({contentType:'text/html; charset=utf-8', body:'<!doctype html><meta charset="utf-8">' + render('snipplets/bolsas-eora/index.tpl', data)});
                if (url.pathname === '/unused-search-image.jpg') {shellImages++; return route.fulfill({status:204});}
                if (url.pathname !== '/search/') return route.continue();
                requests++;
                const index = Number(url.searchParams.get('page') || 1);
                url.searchParams.set('page', index + 1);
                let feed = render('snipplets/bolsas-eora/search-feed.tpl', {...data, query:'"maxivertice"', products:[product(index, 'maxivertice')], pages:{current:index, is_last:index === 6, next:url.pathname + url.search}});
                if (largeFeed) feed = feed.replace('</article>', '<span hidden>' + 'x'.repeat(240000) + '</span></article>');
                const shell = '<main>' + '<section><p>Conteudo da busca normal</p></section>'.repeat(2500) + '<img src="/unused-search-image.jpg"><script>window.searchScriptRan=true;</script></main>';
                await route.fulfill({contentType:'text/html; charset=utf-8', body:'<!doctype html><html><body>' + shell + feed + '</body></html>'});
            });
            await page.goto(base);
            const idle = () => expect(page.locator('[data-be-results]')).toHaveAttribute('aria-busy', 'false');
            const cards = page.locator('[data-be-results-grid] [data-be-product]');
            await idle();
            await expect(cards).toHaveCount(6);
            assert.equal(requests, 6);
            assert.equal(await page.evaluate(() => window.searchDocumentsParsed), 0, 'nao transforma a busca inteira em documentos DOM');
            assert.equal(await page.evaluate(() => Boolean(window.searchScriptRan)), false);
            assert.equal(shellImages, 0, 'imagens fora do feed nao carregam');
            const cdp = await page.context().newCDPSession(page);
            await cdp.send('HeapProfiler.collectGarbage');
            const counters = await cdp.send('Memory.getDOMCounters');
            assert(counters.nodes < 2000, 'nao retem os 30 mil elementos das seis paginas de busca: ' + JSON.stringify(counters));
            await page.locator('[data-be-reset]').click(); await idle();
            if (largeFeed) {
                assert(requests > 6, 'cache descarta paginas para respeitar o limite de tamanho, mesmo abaixo de 40 paginas');
            } else {
                assert.equal(requests, 6, 'cache compacto ainda reutiliza paginas normais');
                await page.evaluate(() => {const now = Date.now; Date.now = () => now() + 300001;});
                await page.locator('[data-be-reset]').click(); await idle();
                assert.equal(requests, 12, 'respostas expiradas sao descartadas');
            }
            assert.deepEqual(errors, []);
            console.log('PASS memoria (' + (largeFeed ? 'feed grande' : 'feed normal') + '): ' + counters.nodes + ' nos DOM apos coleta; sem parse/imagens/scripts da busca inteira, cache limitado e expiracao.');
            await page.close();
        }
    } finally { await browser.close(); }
})().catch(error => {console.error(error); process.exitCode=1;});
