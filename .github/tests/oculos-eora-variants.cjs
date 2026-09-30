const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const {chromium, expect} = require('@playwright/test');
const {oculosContext, render, product} = require('./bolsas-eora-harness.cjs');
const root = path.resolve(__dirname, '../..');
const scope = {window: {}};
for (const name of ['oculos-eora-filters.js', 'bolsas-eora-filters.js']) {
    vm.runInNewContext(fs.readFileSync(path.join(root, 'static/js', name), 'utf8'), scope);
}
const eyewear = scope.window.EoraEyewearFilters;
const bags = scope.window.EoraBagFilters;
// Nomes do cadastro real do Luar. Os SKUs nao precisam ser alterados nem interpretados.
const names = ['Dourado/Marrom', 'Preto Fosco/Preto', 'Prata/Cinza', 'Dourado/Preto', 'Prata/Rosa Fotocromática', 'Prata/Prata Fotocromática'];
const tags = ['luar', 'modelo:luar', 'dourado', 'prata', 'metal', 'lente cinza', 'lente marrom', 'lente rosa', 'formato:cat-eye', 'estilo:statement', 'material da armação:metal', 'tipo da lente:solar', 'tamanho:pequeno'];
const variantData = names.map(value => [{name: 'Metal/Lente', value}]);
const card = {dataset: {oeVariants: JSON.stringify(variantData)}};
const matches = (filters, extra = []) => eyewear.matches(card, filters, [...tags, ...extra]);

for (const [frame, lens, type] of [['dourado', 'marrom', 'solar'], ['preta', 'preta', 'solar'], ['prata', 'cinza', 'solar'], ['dourado', 'preta', 'solar'], ['prata', 'rosa', 'fotocromatica'], ['prata', 'prata', 'fotocromatica']]) {
    assert(matches({oe_frame_color: frame, oe_lens_color: lens, oe_lens_type: type, oe_frame_material: 'metal', oe_shape: 'cat-eye', oe_size: 'pequeno'}));
}
assert(!matches({oe_frame_color: 'dourado', oe_lens_type: 'fotocromatica'}));
assert(!matches({oe_lens_color: 'cinza', oe_lens_type: 'fotocromatica'}));
assert(!matches({oe_frame_color: 'prata', oe_lens_color: 'marrom'}));
assert(!matches({oe_frame_color: 'dourado', oe_lens_color: 'rosa'}, ['cor-armacao:dourado', 'cor-lente:rosa']), 'tags agregadas nao cruzam variantes');
assert(matches({oe_frame_color: 'dourado|prata', oe_lens_type: 'fotocromatica'}), 'OU no grupo e E entre grupos');
assert(matches({oe_frame_color: 'preto', oe_lens_color: 'preto-escuro'}), 'URLs antigas de oculos');
assert(eyewear.matches({dataset: {}}, {oe_frame_color: 'preta'}, ['cor da armação:preto']));
assert(!eyewear.matches({dataset: {}}, {oe_frame_color: 'preta'}, ['preto']), 'tags livres da busca nao viram facetas');
assert(eyewear.matches({dataset: {oeVariants: 'invalid'}}, {oe_frame_material: 'metal'}, tags), 'fallback para tags sem metadados validos');
assert(!eyewear.matches({dataset: {oeVariants: JSON.stringify([[{name: 'Couro', value: 'Prata/Cinza'}]])}}, {oe_lens_color: 'cinza'}, []), 'nao interpretar campos de outros produtos');
assert(!eyewear.matches({dataset: {oeVariants: JSON.stringify([[{name: 'Metal/Lente', value: 'Sem combinacao'}]])}}, {oe_frame_color: 'dourado'}, ['cor-armacao:dourado']), 'campo incompleto nao herda cores agregadas');
assert(eyewear.facetTags(card, tags).includes('tipo-lente:fotocromatica'));
for (const stored of ['preto', 'preta']) for (const selected of ['preto', 'preta']) {
    assert(bags.matches({dataset: {}}, {be_color: selected}, ['cor:' + stored]));
}
assert.equal(bags.normalizeFilters({be_color: 'preto|preta|azul'}).be_color, 'preta|azul');
console.log('PASS variantes: seis combinacoes, aliases de tags, ausencia de cruzamento, fallback e URLs antigas.');

(async () => {
    const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
    try {
        const page = await browser.newPage();
        const errors = [];
        page.on('pageerror', error => errors.push(error.message));
        const initial = oculosContext();
        const data = {...initial, settings: {...initial.settings,
            oculos_eora_models: [{link: 'luar', title: 'LUAR', image: '/fixtures/image-0.webp'}],
            oculos_eora_category_url: '', oculos_eora_best_enabled: false,
            oculos_eora_community_enabled: false, oculos_eora_categories_enabled: false,
        }};
        const luar = product(332346047, 'luar', {name: 'LUAR', tags, price: 124990,
            variations: [{name: 'Metal/Lente'}],
            variants_object: names.map((option0, id) => ({id, option0, is_visible: true, installments_data: 'DO-NOT-SERIALIZE'})).concat([{option0: 'Azul/Verde', is_visible: false}]),
        });
        const other = product(999, 'luar', {tags: ['luar', 'cor-armacao:preto', 'cor da armação:preta', 'cor-lente:preto', 'cor da lente:preta', 'material da armação:acetato'], variants_object: []});
        await page.route('**/*', async route => {
            const url = new URL(route.request().url());
            if (url.pathname.startsWith('/static/')) return route.fulfill({path: path.join(root, url.pathname.slice(1)), contentType: url.pathname.endsWith('.js') ? 'application/javascript' : 'text/css'});
            if (url.pathname.startsWith('/fixtures/')) return route.fulfill({path: path.join(process.env.BE_VALIDATION_DIR || 'C:/Temp/eora-bolsas-validation', 'assets', path.basename(url.pathname)), contentType: 'image/webp'});
            if (url.pathname === '/search/') {
                // Luar na segunda pagina: a descoberta de facetas precisa ler as variacoes tambem.
                const second = url.searchParams.get('page') === '2';
                const feed = render('snipplets/oculos-eora/search-feed.tpl', {...data, params: {oe_feed: '4'}, query: '"luar"', products: second ? [luar] : [other], pages: {current: second ? 2 : 1, is_last: second, next: '/search/?q=%22luar%22&oe_feed=4&page=2'}});
                assert(!feed.includes('DO-NOT-SERIALIZE'));
                assert(!feed.includes('Azul/Verde'), 'variante oculta nao vai ao feed');
                return route.fulfill({contentType: 'text/html', body: feed});
            }
            return route.fulfill({contentType: 'text/html; charset=utf-8', body: '<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{margin:0;font-family:Arial,sans-serif}</style></head><body>' + render('snipplets/oculos-eora/index.tpl', data) + '</body></html>'});
        });
        const base = 'http://eora.test';
        const cards = () => page.locator('[data-be-results-grid] [data-be-product]');
        const idle = () => expect(page.locator('[data-be-results]')).toHaveAttribute('aria-busy', 'false');
        const open = async () => { await page.locator('[data-be-open-filters]').click(); await expect(page.locator('[data-be-facet-status]')).toHaveText(''); };
        const apply = async () => { await page.locator('[data-be-filter-form] [type="submit"]').click(); await idle(); };
        for (const width of [1440, 390]) {
            await page.setViewportSize({width, height: 844});
            await page.goto(base); await idle(); await open();
            for (const key of ['oe_frame_color', 'oe_lens_color']) {
                await expect(page.locator('[name="' + key + '"][value="preta"]')).toHaveCount(1);
                await expect(page.locator('[name="' + key + '"][value="preto"]')).toHaveCount(0);
                await expect(page.locator('[name="' + key + '"][value="preta"] + span')).toHaveText('Preta');
            }
            await expect(page.locator('[name="oe_lens_type"][value="fotocromatica"]')).toHaveCount(1);
            await expect(page.locator('[name="oe_lens_type"][value="fotocromatica"] + span')).toHaveText('Fotocromática');
            await page.locator('[name="oe_lens_type"][value="fotocromatica"]').check();
            await page.locator('[name="oe_frame_color"][value="prata"]').check();
            await page.locator('[name="oe_frame_material"][value="metal"]').check();
            await page.screenshot({path: 'C:/Temp/eora-bolsas-validation/luar-filters-' + width + '.png'});
            await apply();
            await expect(cards()).toHaveCount(1);
            await expect(cards()).toHaveAttribute('data-be-product', '332346047');
            await page.reload(); await idle(); await expect(cards()).toHaveCount(1);
            await open();
            await page.locator('[name="oe_frame_color"][value="prata"]').uncheck();
            await page.locator('[name="oe_frame_color"][value="dourado"]').check();
            await apply(); await expect(cards()).toHaveCount(0);
            // URL legada: Preta deve vir marcada e deve ser possivel remove-la.
            await page.goto(base + '/?oe_filters=' + encodeURIComponent(JSON.stringify({oe_frame_color: 'preto'})));
            await idle(); await expect(cards()).toHaveCount(2); await open();
            await expect(page.locator('[name="oe_frame_color"][value="preta"]')).toBeChecked();
            await page.locator('[name="oe_frame_color"][value="preta"]').uncheck();
            await page.locator('[name="oe_frame_color"][value="prata"]').check();
            await apply(); await expect(cards()).toHaveCount(1);
            assert.equal(JSON.parse(new URL(page.url()).searchParams.get('oe_filters')).oe_frame_color, 'prata');
        }
        // Bolsas: renderizacao incremental tambem nao pode duplicar Preto/Preta.
        await page.addScriptTag({path: path.join(root, 'static/js/bolsas-eora-filters.js')});
        const bagOptions = await page.evaluate(() => {
            const container = document.createElement('div');
            EoraBagFilters.render(container, {be_color: 'preto'}, ['cor:preto'], false);
            EoraBagFilters.render(container, {be_color: 'preto'}, ['cor:preta'], true);
            return [...container.querySelectorAll('input')].map(input => ({value: input.value, checked: input.checked, label: input.nextElementSibling.textContent}));
        });
        assert.deepEqual(bagOptions, [{value: 'preta', checked: true, label: 'Preta'}]);
        const category = render('snipplets/oculos-eora/category-feed.tpl', {...data, params: {oe_category_feed: '1'}, products: [luar], pages: {current: 1, is_last: true}});
        assert(category.includes('data-oe-variants='), 'feed da categoria tambem transmite variantes');
        assert(!render('snipplets/bolsas-eora/product-card.tpl', {product: luar}).includes('data-oe-variants='), 'sem metadados novos em bolsas');
        assert.deepEqual(errors, []);
        console.log('PASS navegador desktop/mobile: feeds reais, facetas tardias, Preta unica, Luar fotocromatico, combinacao invalida, URL, desmarcacao e zero erros JS.');
    } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
