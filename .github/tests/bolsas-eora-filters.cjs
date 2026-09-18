const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
const assert = require('node:assert/strict');
const {chromium, expect} = require('@playwright/test');
const {context, render, product} = require('./bolsas-eora-harness.cjs');
const scope = {window: {}};
vm.runInNewContext(fs.readFileSync(path.join(__dirname, '../../static/js/bolsas-eora-filters.js'), 'utf8'), scope);
const filters = scope.window.EoraBagFilters;
const matches = (options, selected, tags = []) => filters.matches({dataset: {beVariants: JSON.stringify(options)}}, selected, tags);
const leather = value => [{name: 'Couro', value}];

assert(matches([], {be_color: 'azul', be_texture: 'pony-hair', be_hardware: 'prata'}, ['cor:azul', 'textura:pony-hair', 'ferragem:prata']));
assert(!matches([leather('Pony hair azul / Prata')], {be_color: 'preto'}));
assert(!matches([leather('Pony hair azul / Dourado'), leather('Croco Preto / Prata')], {be_texture: 'pony-hair', be_hardware: 'prata'}), 'nao combinar textura de uma variante com metal de outra');
assert(matches([], {be_color: 'azul|marrom', be_hardware: 'dourado'}, ['cor:marrom', 'ferragem:dourado']));
assert(!matches([leather('Pony Hair Azul / Prata')], {be_color: 'azul'}), 'cor depende da tag, nao do nome da variacao');
assert(!matches([], {be_color: 'azul'}, ['azul', 'cor:azul-extra']), 'tag inteira com prefixo cor');
assert(matches([leather('Nome comercial do couro / Prata')], {be_color: 'azul'}, ['cor:azul']), 'tag de cor funciona independentemente do nome comercial');
assert(matches([], {be_color: 'bordo'}, [' COR:BORDÔ ']));
assert(!matches([leather('Croco Preto / Prata e Dourado')], {be_texture: 'croco', be_hardware: 'mix'}), 'textura e ferragem nao vem da variacao');
assert(!matches([[{name: 'Metal', value: 'Dourado'}]], {be_hardware: 'dourado'}));
assert(!matches([leather('Azul / Prata')], {be_texture: 'liso'}), 'nao inventar textura ausente');
assert(matches([leather('Azul / Prata')], {be_texture: 'liso'}, ['textura:liso']));
assert(matches([], {be_occasion: 'trabalho', be_size: 'media', be_capacity: 'notebook-14'}, ['ocasiao:trabalho', 'tamanho:média', 'cabe:notebook-14']));
assert(!matches([], {be_capacity: 'notebook-16'}, ['cabe:notebook-14']), 'capacidade deve ser cadastrada explicitamente');
assert(!matches([], {be_occasion: 'trabalho'}, ['trabalho', 'ocasiao:trabalho-extra']));
assert(!matches([[{name: 'O que cabe', value: 'Notebook até 14”'}]], {be_capacity: 'notebook-14'}));
console.log('PASS classificacao: todos os grupos exigem tags, sem inferir nomes ou variacoes.');

(async () => {
    const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
    try {
        const page = await browser.newPage();
        const errors = [];
        page.on('pageerror', error => errors.push(error.message));
        const initial = context();
        const tags = ['maxivertice', 'hobovertice', 'minivertice', 'clutch', 'modelo-extra'];
        const data = {...initial, settings: {...initial.settings, bolsas_eora_models: tags.map((link, i) => ({link, image: '/fixtures/image-' + i + '.webp'}))}};
        const item = (id, model, colors, extra = []) => product(id, model, {
            tags: [model, ...extra], price: id === 501 ? 254990 : 200000,
            variations: [{name: 'Couro', options: colors.map(name => ({name}))}],
            variants_object: colors.map(option0 => ({option0})),
        });
        const items = [
            item(501, 'maxivertice', ['Pony hair azul / Prata'], ['cor:azul', 'textura:pony-hair', 'ferragem:prata', 'ocasiao:trabalho', 'tamanho:media', 'cabe:notebook-14']),
            item(502, 'maxivertice', ['Pony hair azul / Dourado', 'Croco Preto / Prata'], ['cor:azul', 'cor:preto', 'textura:croco', 'ferragem:dourado', 'ocasiao:trabalho', 'tamanho:grande', 'cabe:notebook-16', 'cor:terracota']),
            item(503, 'hobovertice', ['Pony Hair Azul / Prata'], ['cor:azul', 'textura:pony-hair', 'ferragem:prata', 'ocasiao:viagem', 'tamanho:media', 'cabe:tablet']),
            item(504, 'clutch', ['Verniz Bordo / Dourado'], ['cor:bordo', 'textura:verniz', 'ferragem:dourado', 'ocasiao:noite-eventos', 'tamanho:pequena', 'cabe:essenciais']),
            item(505, 'modelo-extra', ['Lizard / Verde'], ['cor:verde', 'textura:lizard']),
        ];
        let failOnce = false;
        let emptyTags = false;
        let delayedTag = '';
        await page.route('http://127.0.0.1:4175/**', async route => {
            const url = new URL(route.request().url());
            if (url.pathname === '/') return route.fulfill({contentType: 'text/html; charset=utf-8', body: '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{margin:0;font-family:Arial}</style>' + render('snipplets/bolsas-eora/index.tpl', data)});
            if (url.pathname !== '/search/') return route.continue();
            assert.equal(url.searchParams.get('be_feed'), '4');
            assert(!url.searchParams.has('be_color'), 'classificacao local nao vira parametro nativo invalido');
            const tag = url.searchParams.get('q').replace(/"/g, '');
            if (failOnce) {failOnce = false; return route.fulfill({status: 503, body: 'Unavailable'});}
            if (tag === delayedTag) await new Promise(resolve => setTimeout(resolve, 200));
            let products = items.filter(item => item.tags.includes(tag));
            if (emptyTags) products = products.map(item => ({...item, tags: [tag]}));
            if (url.searchParams.has('min_price')) products = products.filter(item => item.price >= Number(url.searchParams.get('min_price')) * 100);
            if (url.searchParams.has('max_price')) products = products.filter(item => item.price <= Number(url.searchParams.get('max_price')) * 100);
            const index = Number(url.searchParams.get('page') || 1);
            url.searchParams.set('page', index + 1);
            let body = render('snipplets/bolsas-eora/search-feed.tpl', {...data, query: '"' + tag + '"', products: products.slice(index - 1, index), pages: {current: index, is_last: index >= products.length, next: url.pathname + url.search}});
            return route.fulfill({contentType: 'text/html; charset=utf-8', body});
        });
        const idle = () => expect(page.locator('[data-be-results]')).toHaveAttribute('aria-busy', 'false');
        const ready = async () => {
            await expect(page.locator('[data-be-filter-form] [type="submit"]')).toBeEnabled();
            await expect(page.locator('[data-be-facet-status]')).toHaveText('');
        };
        const open = async () => {await page.locator('[data-be-open-filters]').click(); await ready();};
        const select = (key, value) => page.locator('input[name="' + key + '"][value="' + value + '"]').check();
        const apply = async () => {await ready(); await page.locator('[data-be-filter-form] [type="submit"]').click(); await idle();};
        const ids = () => page.locator('[data-be-results-grid] [data-be-product]').evaluateAll(nodes => nodes.map(n => Number(n.dataset.beProduct)).sort());
        async function finish() {
            for (let i = 0; await page.locator('[data-be-more]').isVisible(); i++) {
                assert(i < 10);
                await page.locator('[data-be-more]').click(); await idle();
            }
        }
        for (const width of [1440, 390, 320]) {
            await page.setViewportSize({width, height: 844});
            await page.goto('http://127.0.0.1:4175'); await idle(); await open();
            assert.equal(await page.locator('select[name="be_model"]').inputValue(), '', 'filtro abre em todos os modelos');
            assert.deepEqual(await page.locator('select[name="be_model"] option').allTextContents(), ['Todos os modelos', ...tags]);
            assert.deepEqual(await page.locator('[data-be-filter-form] legend').allTextContents(), ['Ocasião', 'Tamanho', 'Cor', 'O que cabe', 'Textura', 'Ferragem', 'Preço']);
            await expect(page.locator('[name="be_color"][value="rosa"]')).toHaveCount(0);
            await expect(page.locator('[name="be_texture"][value="camurca"]')).toHaveCount(0);
            await expect(page.locator('[name="be_color"][value="terracota"]')).toHaveCount(1);
            await expect(page.locator('[name="be_capacity"][value="notebook-16"]')).toHaveCount(1);
            await page.screenshot({path: 'C:/Temp/eora-bolsas-validation/new-filters-top-' + width + '.png'});
            await select('be_color', 'azul'); await select('be_texture', 'pony-hair'); await select('be_hardware', 'prata'); await apply(); await finish();
            assert.deepEqual(await ids(), [501, 503], 'cor por tag e textura/metal juntos, em todos os modelos');
            await open(); await expect(page.locator('input[name="be_color"][value="azul"]')).toBeChecked();
            await select('be_occasion', 'trabalho'); await select('be_capacity', 'notebook-14'); await select('be_size', 'media'); await select('be_texture', 'pony-hair');
            await page.locator('[name="min_price"]').fill('2500'); await page.locator('[name="max_price"]').fill('2600');
            assert(await page.locator('[data-be-filter-form]').evaluate(form => {
                const field = form.elements.max_price.getBoundingClientRect();
                return field.bottom <= form.querySelector('footer').getBoundingClientRect().top;
            }), 'barra de acoes nao cobre os campos de preco');
            await page.screenshot({path: 'C:/Temp/eora-bolsas-validation/new-filters-' + width + '.png'});
            await apply(); await finish(); assert.deepEqual(await ids(), [501]);
            await page.reload(); await idle(); await finish(); assert.deepEqual(await ids(), [501], 'URL restaura filtros sem exigir modelo');
            await open(); await page.locator('[data-be-clear-filters]').click(); await idle(); await finish(); assert.deepEqual(await ids(), [501, 502, 503, 504, 505]);
            await open(); await page.locator('[name="be_model"]').selectOption('clutch'); await ready();
            assert.deepEqual(await page.locator('[name="be_color"]').evaluateAll(nodes => nodes.map(n => n.value)), ['bordo']);
            await apply(); await finish(); assert.deepEqual(await ids(), [504]);
            await page.goBack(); await idle(); await finish(); assert.deepEqual(await ids(), [501, 502, 503, 504, 505]);
            await open(); await page.locator('[name="be_model"]').selectOption('modelo-extra'); await apply(); await finish(); assert.deepEqual(await ids(), [505]);
            await page.locator('[data-be-reset]').click(); await idle();
            await open(); await select('be_color', 'preto'); await select('be_texture', 'pony-hair'); await select('be_hardware', 'prata'); await apply(); await finish(); assert.deepEqual(await ids(), [], 'sem combinar texturas de variantes diferentes');
            assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth));
            console.log('PASS ' + width + 'px: ordem, combinacoes, tags, faixa de preco, todos/modelo/outros, URL, historico e limpar.');
        }
        await page.goto('http://127.0.0.1:4175'); await idle();
        failOnce = true;
        await page.locator('[data-be-open-filters]').click();
        await expect(page.locator('[data-be-facet-status]')).toContainText('Não foi possível');
        await expect(page.locator('[data-be-filter-form] [type="submit"]')).toBeEnabled();
        await page.keyboard.press('Escape'); await open();
        await expect(page.locator('[name="be_color"][value="azul"]')).toHaveCount(1);
        await page.keyboard.press('Escape');
        emptyTags = true;
        await page.reload(); await idle(); await open();
        await expect(page.locator('[data-be-facets] input')).toHaveCount(0);
        await expect(page.locator('[data-be-filter-form] legend')).toHaveText(['Preço']);
        await page.keyboard.press('Escape');
        emptyTags = false;
        await page.reload(); await idle();
        delayedTag = 'maxivertice';
        await page.locator('[data-be-open-filters]').click();
        await page.locator('[name="be_model"]').selectOption('clutch'); await ready();
        await page.waitForTimeout(300);
        assert.deepEqual(await page.locator('[name="be_color"]').evaluateAll(nodes => nodes.map(n => n.value)), ['bordo']);
        await page.keyboard.press('Escape');
        delayedTag = '';
        items.forEach((item, index) => {item.tags = [tags[index < 2 ? 0 : index - 1]];});
        items[0].tags.push('cor:rosa', 'textura:matelasse', 'cabe:garrafa', 'ocasiao:passeio', 'tamanho:compacta', 'ferragem:cobre');
        items[1].tags.push('cor:amarelo');
        await page.reload(); await idle(); await open();
        assert.deepEqual((await page.locator('[name="be_color"]').evaluateAll(nodes => nodes.map(n => n.value))).sort(), ['amarelo', 'rosa']);
        for (const [name, value] of [['be_texture', 'matelasse'], ['be_capacity', 'garrafa'], ['be_occasion', 'passeio'], ['be_size', 'compacta'], ['be_hardware', 'cobre']]) {
            assert.deepEqual(await page.locator('[name="' + name + '"]').evaluateAll(nodes => nodes.map(n => n.value)), [value]);
        }
        await select('be_color', 'amarelo'); await apply(); await finish();
        assert.deepEqual(await ids(), [502], 'valor novo filtra o produto correto sem cadastro no codigo');
        await page.locator('[data-be-reset]').click(); await idle(); await open();
        await select('be_color', 'rosa'); await apply(); await finish();
        assert.deepEqual(await ids(), [501]);
        console.log('PASS valores livres: somente Rosa/Amarelo, filtragem individual e valores novos em todos os demais grupos.');
        assert.deepEqual(errors, []);
        console.log('PASS descoberta: paginas posteriores, tags novas, ausencia de tags, erro/retry, troca rapida de modelo e zero erros JS.');
    } finally { await browser.close(); }
})().catch(error => {console.error(error); process.exitCode = 1;});
