const {chromium, expect} = require('@playwright/test');
const assert = require('node:assert/strict');
const path = require('node:path');
const {render, context, product} = require('./bolsas-eora-harness.cjs');
const base = 'http://127.0.0.1:4175';
const output = process.env.BE_VALIDATION_DIR || 'C:/Temp/eora-bolsas-validation';
const executablePath = process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe';
const tags = ['maxivertice', 'minivertice', 'hobovertice', 'clutch', ' MAXIVERTICE '];
const initial = context();
const data = {...initial, settings: {...initial.settings,
    bolsas_eora_models: tags.map((link, index) => ({link, image: '/fixtures/image-' + index + '.webp'})),
    bolsas_eora_1_catalog_enabled: false, bolsas_eora_1_split_enabled: false,
    bolsas_eora_best_enabled: false, bolsas_eora_community_enabled: false, bolsas_eora_categories_enabled: false,
}};
const shared = product(700, 'maxivertice', {tags: ['maxivertice', 'minivertice']});
const sharedClutch = product(201, 'hobovertice', {tags: ['hobovertice', 'clutch']});
const products = {
    maxivertice: [shared, ...Array.from({length: 18}, (_, index) => product(index + 1, index === 0 ? 'MAXIVERTICE' : 'maxivertice')),
        product(998, 'maxivertice-extra'), product(999, 'outra-tag', {name: 'Bolsa maxivertice sem a tag'})],
    minivertice: [shared, ...Array.from({length: 4}, (_, index) => product(index + 101, 'minivertice'))],
    hobovertice: [sharedClutch, product(202, 'hobovertice'), product(203, 'hobovertice')],
    clutch: [sharedClutch, product(301, 'clutch'), product(302, 'clutch'), product(303, 'clutch')],
};
const expectedIds = [...new Set(Object.values(products).flat().filter(item => item.id < 998).map(item => String(item.id)))].sort();

(async () => {
    const browser = await chromium.launch({headless: true, executablePath});
    try {
        const page = await browser.newPage({viewport: {width: 1440, height: 1000}});
        const errors = [];
        page.on('pageerror', error => errors.push(error.message));
        const requests = [];
        let failTag = '';
        let delayTag = '';
        await page.route(base + '/**', async route => {
            const url = new URL(route.request().url());
            if (url.pathname === '/') {
                return route.fulfill({contentType: 'text/html', body: '<!doctype html><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{margin:0;font-family:Arial}</style>' + render('snipplets/bolsas-eora/index.tpl', data)});
            }
            if (!url.pathname.startsWith('/search/')) return route.continue();
            const tag = url.searchParams.get('q').replace(/^"|"$/g, '');
            requests.push({tag, page: Number(url.searchParams.get('page') || 1), sort: url.searchParams.get('sort_by') || 'user'});
            if (tag === failTag) { failTag = ''; return route.fulfill({status: 503, body: 'Unavailable'}); }
            if (tag === delayTag) await new Promise(resolve => setTimeout(resolve, 250));
            const items = products[tag] || [];
            const index = Number(url.searchParams.get('page') || 1);
            const last = index * 5 >= items.length;
            url.searchParams.set('page', index + 1);
            const body = render('snipplets/bolsas-eora/search-feed.tpl', {...data,
                query: '"' + tag + '"', products: items.slice((index - 1) * 5, index * 5),
                pages: {current: index, is_last: last, next: last ? '' : url.pathname + url.search},
            });
            await route.fulfill({contentType: 'text/html', body});
        });
        const cards = () => page.locator('[data-be-results-grid] [data-be-product]');
        const ids = () => cards().evaluateAll(nodes => nodes.map(node => node.dataset.beProduct));
        const idle = () => expect(page.locator('[data-be-results]')).toHaveAttribute('aria-busy', 'false');
        async function finish() {
            for (let action = 0; !(await page.locator('[data-be-more]').isHidden()); action++) {
                assert(action < 20, 'paginacao deve terminar');
                const before = requests.length;
                await page.locator('[data-be-more]').click();
                await idle();
                assert(requests.length - before <= 12, 'no maximo doze consultas por lote de 24 produtos');
            }
        }
        async function assertAll() {
            await expect(page.locator('[data-be-reset]')).toBeVisible();
            await expect(page.locator('[data-be-reset]')).toHaveAttribute('aria-pressed', 'true');
            await finish();
            const found = await ids();
            assert.deepEqual([...found].sort(), expectedIds);
            assert.equal(new Set(found).size, found.length, 'produto com varias tags nao se repete');
            await expect(page.locator('[data-be-status]')).toHaveText('29 produtos encontrados');
            await expect(page.locator('[data-be-tag][aria-current]')).toHaveCount(0);
        }

        for (const viewport of [{width: 1440, height: 1000}, {width: 390, height: 844}]) {
            await page.setViewportSize(viewport);
            requests.length = 0;
            await page.goto(base);
            await idle();
            await expect(page.locator('[data-be-results]')).toBeVisible();
            await expect(page.locator('[data-be-reset]')).toBeVisible();
            assert(await page.locator('[data-be-reset]').evaluate(el => parseFloat(getComputedStyle(el).fontSize) >= 12 && el.getBoundingClientRect().height >= 42));
            await expect(page.locator('[data-be-result-title]')).toHaveText('Todas as bolsas');
            assert((await cards().count()) > 0 && (await cards().count()) <= 24);
            assert(requests.length <= 12);
            assert(new Set(requests.map(request => request.tag)).size > 1, 'consulta inicial alterna entre tags');
            await page.screenshot({path: path.join(output, 'all-models-' + viewport.width + '.png'), fullPage: true});
            await assertAll();
            assert.deepEqual([...new Set(requests.map(request => request.tag))].sort(), ['clutch', 'hobovertice', 'maxivertice', 'minivertice']);
            assert.equal(requests.filter(request => request.tag === 'maxivertice' && request.page === 1).length, 1, 'tag repetida com outra capitalizacao nao duplica consultas');

            requests.length = 0;
            await expect(page.locator('[data-be-sort]')).toBeVisible();
            await page.locator('[data-be-sort]').selectOption('price-descending');
            await idle();
            const descending = (await ids()).map(Number);
            assert.deepEqual(descending, [...descending].sort((first, second) => second - first), 'Todos ordena globalmente, nao apenas dentro de cada modelo');
            await expect(page.locator('[data-be-more]')).toBeHidden();
            assert(requests.length && requests.every(request => request.sort === 'price-descending'), 'ordenacao e enviada para todas as tags');
            assert.equal(new URL(page.url()).searchParams.get('be_sort'), 'price-descending');
            await page.locator('[data-be-reset]').click();
            await idle();
            await assertAll();

            await page.locator('[data-be-tag="minivertice"]').click();
            await idle();
            await expect(page.locator('[data-be-reset]')).toBeVisible();
            await expect(page.locator('[data-be-reset]')).toHaveAttribute('aria-pressed', 'false');
            assert.deepEqual((await ids()).sort(), ['101', '102', '103', '104', '700']);
            assert.equal(new URL(page.url()).searchParams.get('tag'), 'minivertice');
            await page.goBack();
            await idle();
            await assertAll();
            await page.locator('[data-be-tag="maxivertice"]').click();
            await idle();
            await finish();
            assert.equal((await ids()).length, 19);
            await page.locator('[data-be-reset]').click();
            await idle();
            await assertAll();
            assert.equal(new URL(page.url()).searchParams.get('tag'), null);
            console.log('PASS ' + viewport.width + 'px: todas as 4 tags ao entrar, 29 produtos unicos, tag exata, paginacao limitada, selecionar modelo, voltar e limpar.');
        }

        failTag = 'minivertice';
        await page.goto(base);
        await idle();
        await expect(page.locator('[data-be-status]')).toContainText('Tente novamente');
        assert((await cards().count()) > 0, 'falha de outra tag nao perde produtos ja encontrados');
        await assertAll();
        console.log('PASS agregacao: erro em uma tag e tentativa sem perder ou duplicar produtos.');

        await page.goto(base + '/?tag=desconhecida&be_sort=price-descending&be_filters=' + encodeURIComponent(JSON.stringify({Cor: 'Preto'})));
        await idle();
        const fallbackSorted = (await ids()).map(Number);
        assert.deepEqual(fallbackSorted, [...fallbackSorted].sort((first, second) => second - first));
        assert.deepEqual([...fallbackSorted].sort((first, second) => first - second).map(String), [...expectedIds].sort((first, second) => Number(first) - Number(second)));
        await expect(page.locator('[data-be-toolbar]')).toBeVisible();
        await expect(page.locator('[data-be-sort]')).toBeVisible();
        await expect(page.locator('[data-be-sort]')).toHaveValue('price-descending');
        console.log('PASS agregacao: modelo desconhecido volta para Todos, limpa filtros e preserva a ordenacao valida.');

        delayTag = 'maxivertice';
        await page.goto(base);
        await page.locator('[data-be-tag="minivertice"]').click();
        await idle();
        await page.waitForTimeout(350);
        assert.deepEqual((await ids()).sort(), ['101', '102', '103', '104', '700']);
        assert.deepEqual(errors, []);
        console.log('PASS agregacao: consulta inicial cancelada ao selecionar modelo; zero erros JS.');
    } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
