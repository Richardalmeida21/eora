const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const Twig = require('twig');
const {chromium} = require('playwright');
const root = path.resolve(__dirname, '../..');
const read = name => fs.readFileSync(path.join(root, name), 'utf8');
const compile = (id, data) => Twig.twig({id, data, allowInlineIncludes: true, rethrow: true});
for (const file of ['snipplets/product-name-pt.tpl', 'snipplets/social/product-share-meta.tpl']) {
    if (fs.existsSync(path.join(root, file))) compile(file, read(file));
}
compile('snipplets/preload-images.tpl', '');
Twig.extendFilter('static_url', value => '/static/' + value);
const layoutSource = read('layouts/layout.tpl');
const headSource = layoutSource.slice(layoutSource.indexOf('        <title>'), layoutSource.indexOf('        {#/*============================================================================'))
    .replace(/{% snipplet 'preload-images.tpl' %}/g, '{% include "snipplets/preload-images.tpl" %}');
const head = compile('share-head', headSource);
let platformMeta = '';
Twig.extendFunction('component', () => platformMeta);
const polluted = "' : '') + 'Sobre a EORA'; wrapper.innerHTML = contentHTML;";
const escape = text => text.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
function nativeMeta(description) {
    return '<meta property="og:title" content="VÉRTICE" />\n' +
        '<meta property="og:description" content="' + escape(description) + '" />\n' +
        '<meta property="og:url" content="https://eora.test/produtos/vertice/" />\n' +
        '<meta property="og:image" content="https://cdn.test/bag.webp" />\n' +
        '<meta property="product:price:amount" content="2749.90" />\n' +
        '<meta property="product:price:currency" content="BRL" />\n' +
        '<meta name="twitter:card" content="summary_large_image">\n' +
        '<meta name="twitter:description" content="' + escape(description) + '">';
}
const custom = '<script>var contentHTML="WRONG";wrapper.innerHTML=contentHTML;</script><table><tr><td>descricao_curta</td><td>Vértice</td></tr></table>';
function render({template = 'product', description = custom, seo = '', pageDescription = polluted, name = 'VÉRTICE', native} = {}) {
    platformMeta = native || nativeMeta(pageDescription);
    return head.render({template, page_title: name, page_description: pageDescription, store: {name: 'EORA'}, product: {id: 1, name, description, seo_description: seo}});
}

(async () => {
    const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
    try {
        const page = await browser.newPage({javaScriptEnabled: false});
        const inspect = async html => {
            await page.setContent('<!doctype html><html><head>' + html + '</head><body></body></html>');
            return page.evaluate(() => ({description: Array.from(document.querySelectorAll('meta[name="description"]')).map(n => n.content), og: Array.from(document.querySelectorAll('meta[property="og:description"]')).map(n => n.content), twitter: Array.from(document.querySelectorAll('meta[name="twitter:description"]')).map(n => n.content), image: document.querySelector('meta[property="og:image"]')?.content, url: document.querySelector('meta[property="og:url"]')?.content, price: document.querySelector('meta[property="product:price:amount"]')?.content, currency: document.querySelector('meta[property="product:price:currency"]')?.content}));
        };
        for (const description of [custom, '<SCRIPT>alert(1)</SCRIPT>', '<table><tr><td>video_link</td><td>https://vimeo.com/123</td></tr></table>', '<style>.x{color:red}</style>']) {
            const meta = await inspect(render({description}));
            assert.equal(meta.description.length, 1);
            assert.equal(meta.og.length, 1);
            assert.equal(meta.twitter.length, 1);
            assert.match(meta.og[0], /VÉRTICE/);
            assert.doesNotMatch(meta.og[0], /wrapper|innerHTML|contentHTML|video_link|alert\(|color:red/);
            assert.equal(meta.description[0], meta.og[0]);
            assert.equal(meta.twitter[0], meta.og[0]);
            assert.equal(meta.image, 'https://cdn.test/bag.webp');
            assert.equal(meta.url, 'https://eora.test/produtos/vertice/');
            assert.equal(meta.price, '2749.90');
            assert.equal(meta.currency, 'BRL');
        }
        const seo = 'Bolsa "Vértice" em couro & metais.';
        assert.deepEqual((await inspect(render({seo}))).og, [seo], 'SEO editado no cadastro tem prioridade e preserva aspas/acentos');
        assert.doesNotMatch((await inspect(render({seo: '<script>bad()</script>'}))).og[0], /bad\(/);
        const compact = nativeMeta(polluted).replace(/\n/g, '');
        assert.equal((await inspect(render({native: compact}))).og.length, 1, 'Metas sem quebras de linha também não duplicam descrições');
        for (const template of ['home', 'category', 'page']) {
            const ordinary = await inspect(render({template, pageDescription: 'Descrição original da página'}));
            assert.deepEqual(ordinary.og, ['Descrição original da página']);
        }
        assert.deepEqual((await inspect(render({description: '<p>Descrição simples.</p>', pageDescription: 'Descrição simples.'}))).og, ['Descrição simples.']);
        console.log('PASS compartilhamento: metadados no HTML sem JS, scripts/tabelas, SEO, escape, ausência de duplicatas e preservação de imagem/URL/preço e outras páginas.');
    } finally { await browser.close(); }
})().catch(error => {console.error(error); process.exitCode = 1;});
