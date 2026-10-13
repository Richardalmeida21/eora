const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const zlib = require('node:zlib');
const {chromium} = require('playwright');
const Twig = require('twig');
require('./bolsas-eora-harness.cjs');
const root = path.resolve(__dirname, '../..');
const read = file => fs.readFileSync(path.join(root, file), 'utf8');
const source = read('static/js/product-description-image-links.js.tpl');
const executablePath = process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe';
const errors = [];
const requests = [];
const markup = version => '<div id="single-product"><div class="js-product-description-base" hidden><table><tbody><tr><td>clientes_eora</td></tr><tr>' + Array.from({length: 20}, (_, i) => `<td><a href="/destination-${version}-${i}/"><img src="/image-${i}.png" loading="lazy"></a></td>`).join('') + '</tr></tbody></table></div></div>';
const rendered = '<section class="eora-clientes-section"><div>' + Array.from({length: 20}, (_, i) => `<img src="/image-${i}.png" loading="lazy" width="30" height="30">`).join('') + '</div></section>';
const instrumentation = `
    window.fixtureMetrics = {callbacks: 0, callbackMs: 0, maxCallbackMs: 0, blockScans: 0, bodySubtree: false};
    const NativeObserver = MutationObserver;
    window.MutationObserver = class extends NativeObserver {
        constructor(callback) { super((records, observer) => { const start = performance.now(); fixtureMetrics.callbacks++; callback(records, observer); const time = performance.now()-start; fixtureMetrics.callbackMs += time; fixtureMetrics.maxCallbackMs = Math.max(fixtureMetrics.maxCallbackMs, time); }); }
        observe(node, options) { if(node === document.body && options.subtree) fixtureMetrics.bodySubtree = true; return super.observe(node, options); }
    };
    const nativeQuery = Element.prototype.querySelectorAll;
    Element.prototype.querySelectorAll = function(selector) { if(this.matches('.eora-clientes-section') && selector === 'img') fixtureMetrics.blockScans++; return nativeQuery.call(this,selector); };
`;
const tick = page => page.evaluate(() => new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve))));

// Render the actual layout, keeping unrelated platform components as fixtures.
Twig.extendFilter('static_inline', () => '');
Twig.extendFilter('script_tag', value => '<script src="' + value + '"></script>');
Twig.extendFilter('add_param', value => value);
const rawLayout = read('layouts/layout.tpl');
const ids = new Set([...rawLayout.matchAll(/(?:include|snipplet)\s+["']([^"']+)["']/g)].map(match => /^(static|snipplets)\//.test(match[1]) ? match[1] : 'snipplets/' + match[1]));
for (const id of ids) Twig.twig({id, data: id === 'static/js/product-description-image-links.js.tpl' ? source : '', allowInlineIncludes: true});
const layout = Twig.twig({data: rawLayout.replace(/{%\s*snipplet\s+(["'])(.*?)\1\s*%}/g, '{% include "snipplets/$2" %}').replace(/{%\s*head_content\s*%}/g, '{{ fixture_head }}').replace(/{%\s*template_content\s*%}/g, '{{ fixture_content }}'), allowInlineIncludes: true, rethrow: true});
const renderLayout = template => layout.render({template, params: {preview: true}, settings: {}, page: {}, page_title: 'Eora fixture', languages: [{active: true, lang: 'pt'}], cart: {}, customer: {}, store: {}, fixture_head: '<base href="https://fixture.eora.test/"><script>window.LS={ready:Promise.resolve()};</script>', fixture_content: markup(1) + rendered});

(async () => {
    const browser = await chromium.launch({headless: true, executablePath});
    const report = {scriptBytes: Buffer.byteLength(source), gzipBytes: zlib.gzipSync(source).length};
    try {
        const page = await browser.newPage();
        page.on('pageerror', error => errors.push(error.message));
        await page.route('**/*', route => { requests.push(route.request().url()); return route.abort(); });
        const initialTimes = [];
        for (let i = 0; i < 25; i++) {
            await page.setContent('<base href="https://fixture.eora.test/">' + markup(1) + rendered);
            await page.addScriptTag({content: 'var fixtureStart=performance.now();\n' + source + '\nwindow.fixtureInitTime=performance.now()-fixtureStart;'});
            await tick(page);
            initialTimes.push(await page.evaluate(() => fixtureInitTime));
            assert.equal(await page.locator('.eora-clientes-section a').count(), 20);
        }
        report.initializationMedianMs = initialTimes.sort((a, b) => a-b)[12];
        report.initializationMaxMs = Math.max(...initialTimes);
        assert(report.initializationMedianMs < 25, 'inicializacao pequena e pontual');
        await page.close();

        const measured = await browser.newPage();
        measured.on('pageerror', error => errors.push(error.message));
        await measured.route('**/*', route => { requests.push(route.request().url()); return route.abort(); });
        await measured.setContent('<base href="https://fixture.eora.test/">' + markup(1) + rendered);
        await measured.addScriptTag({content: instrumentation});
        await measured.addScriptTag({content: source});
        await tick(measured);
        const before = await measured.evaluate(() => ({...fixtureMetrics}));
        await measured.evaluate(() => {
            const fragment = document.createDocumentFragment();
            for (let i = 0; i < 5000; i++) { const div = document.createElement('div'); div.className='unrelated-widget'; div.textContent='Update'; fragment.appendChild(div); }
            document.body.appendChild(fragment);
        });
        await tick(measured);
        const after = await measured.evaluate(() => ({...fixtureMetrics}));
        assert.equal(after.blockScans, before.blockScans, '5000 mudancas alheias nao reexaminam as fotos');
        assert.equal(after.bodySubtree, false, 'nenhum observer acompanha a arvore completa da pagina');
        const idle = await measured.evaluate(() => fixtureMetrics.callbacks);
        await measured.waitForTimeout(300);
        assert.equal(await measured.evaluate(() => fixtureMetrics.callbacks), idle, 'nenhum polling ou trabalho continuo em repouso');
        report.unrelatedBatchCallbackMs = after.callbackMs - before.callbackMs;
        report.unrelatedBatchCallbacks = after.callbacks - before.callbacks;
        report.bodySubtreeObserved = after.bodySubtree;
        assert(report.unrelatedBatchCallbackMs < 100, 'batch de 5000 mudancas sem trabalho longo');

        const session = await measured.context().newCDPSession(measured);
        await session.send('HeapProfiler.collectGarbage');
        const heapBefore = (await session.send('Runtime.getHeapUsage')).usedSize;
        for (let i = 2; i <= 31; i++) {
            await measured.evaluate(({html, rendered}) => { document.querySelector('#single-product').outerHTML = html; document.querySelector('.eora-clientes-section').outerHTML = rendered; }, {html: markup(i), rendered});
            await tick(measured);
        }
        await session.send('HeapProfiler.collectGarbage');
        report.heapGrowthBytesAfter30Products = (await session.send('Runtime.getHeapUsage')).usedSize - heapBefore;
        assert(report.heapGrowthBytesAfter30Products < 2 * 1024 * 1024, 'trocas nao retêm documentos completos anteriores');
        await session.detach();
        await measured.close();

        for (const template of ['home', 'page', 'category', 'search', 'cart', 'product']) {
            const html = renderLayout(template);
            assert.equal(html.includes('data-eora-description-image-links-ready'), template === 'product', 'script incluido apenas no detalhe do produto');
            if (template !== 'product') continue;
            const integration = await browser.newPage();
            integration.on('pageerror', error => errors.push(error.message));
            await integration.route('**/*', route => route.abort());
            await integration.setContent(html);
            assert.equal(await integration.locator('.eora-clientes-section a').count(), 20);
            await integration.close();
        }
        assert.deepEqual(errors, []);
        report.pageErrors = errors;
        report.externalScriptRequests = requests.filter(url => !/\/image-\d+\.png$/.test(url));
        assert.deepEqual(report.externalScriptRequests, []);
        const output = process.env.IMAGE_LINK_VALIDATION_DIR || 'C:/Temp/eora-image-links-validation';
        fs.mkdirSync(output, {recursive: true});
        fs.writeFileSync(path.join(output, 'performance.json'), JSON.stringify(report, null, 2));
        console.log('PASS performance/layout: ' + JSON.stringify(report));
    } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
