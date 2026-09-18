const assert = require('node:assert/strict');
const {chromium, expect} = require('@playwright/test');
const {context, render, product} = require('./bolsas-eora-harness.cjs');
const base = 'http://127.0.0.1:4175';
const executablePath = process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe';
const tags = ['maxivertice', 'minivertice', 'hobovertice', 'clutch'];
const initial = context();
const data = {...initial, settings: {...initial.settings,
    bolsas_eora_models: tags.map(link => ({link, image: '/fixtures/image-0.webp'})),
    bolsas_eora_1_catalog_enabled: false, bolsas_eora_1_split_enabled: false,
    bolsas_eora_best_enabled: false, bolsas_eora_community_enabled: false, bolsas_eora_categories_enabled: false,
}};

(async () => {
    const browser = await chromium.launch({headless: true, executablePath});
    try {
        for (const width of [1440, 390]) {
            const page = await browser.newPage({viewport: {width, height: 900}});
            const errors = [];
            page.on('pageerror', error => errors.push(error.message));
            const requests = [];
            let active = 0;
            let maximum = 0;
            let release;
            let gate = null;
            function hold() { gate = new Promise(resolve => { release = resolve; }); }
            function resume() { gate = null; release(); }
            await page.route(base + '/**', async route => {
                const url = new URL(route.request().url());
                if (url.pathname === '/') return route.fulfill({contentType: 'text/html; charset=utf-8', body: '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">' + render('snipplets/bolsas-eora/index.tpl', data)});
                if (url.pathname !== '/search/') return route.continue();
                const tag = url.searchParams.get('q').replace(/"/g, '');
                const index = Number(url.searchParams.get('page') || 1);
                requests.push({tag, index, url: url.href});
                maximum = Math.max(maximum, ++active);
                try {
                    if (gate) await gate;
                    const id = tags.indexOf(tag) * 10 + index;
                    const colors = ['preto', 'azul', 'terracota'];
                    const item = product(id, tag, {tags: [tag, 'cor:' + colors[index - 1], 'ocasiao:trabalho']});
                    url.searchParams.set('page', index + 1);
                    const body = render('snipplets/bolsas-eora/search-feed.tpl', {...data, query: '"' + tag + '"', products: [item], pages: {current: index, is_last: index === 3, next: url.pathname + url.search}});
                    await route.fulfill({contentType: 'text/html; charset=utf-8', body});
                } finally { active--; }
            });
            const submit = page.locator('[data-be-filter-form] [type="submit"]');
            const status = page.locator('[data-be-facet-status]');
            const idle = () => expect(page.locator('[data-be-results]')).toHaveAttribute('aria-busy', 'false');
            const open = () => page.locator('[data-be-open-filters]').click();
            const black = page.locator('[name="be_color"][value="preto"]');
            await page.goto(base);
            await idle();
            const initialRequests = requests.length;
            maximum = 0;
            hold();
            await open();
            await expect(submit).toBeEnabled();
            await expect(status).toContainText('Carregando mais opções');
            await expect(black).toBeVisible();
            await black.check();
            await black.focus();
            await page.evaluate(() => { window.originalFilter = document.activeElement; });
            await expect.poll(() => active).toBe(3);
            assert.equal(maximum, 3, 'tres consultas independentes em paralelo');
            assert(requests.slice(initialRequests).every(item => item.index === 2), 'primeiras paginas do catalogo reaproveitadas');
            resume();
            await expect(status).toHaveText('');
            await expect(black).toBeChecked();
            assert(await page.evaluate(() => document.activeElement === window.originalFilter), 'foco e elemento preservados ao adicionar opcoes');
            assert.deepEqual(await page.locator('[name="be_color"]').evaluateAll(nodes => nodes.map(node => node.value)), ['preto', 'azul', 'terracota']);
            assert.equal(maximum, 3);
            assert.equal(requests.length, 12, 'cada uma das 12 paginas consultada uma unica vez');
            await submit.click();
            await idle();
            assert.equal(requests.length, 12, 'aplicar caracteristicas reutiliza o feed sem novas consultas');
            await open();
            await expect(status).toHaveText('');
            await expect(black).toBeChecked();
            await black.uncheck();
            await expect(black).not.toBeChecked();
            assert.equal(requests.length, 12, 'reabrir painel completo nao faz consultas');
            await page.keyboard.press('Escape');

            // Interrompe a descoberta e comprova que paginas concluidas nao se repetem.
            await page.goto(base);
            await idle();
            const afterReload = requests.length;
            hold();
            await open();
            await expect.poll(() => active).toBe(3);
            await page.keyboard.press('Escape');
            resume();
            await expect.poll(() => active).toBe(0);
            await open();
            await expect(status).toHaveText('');
            assert(requests.slice(afterReload).filter(item => item.index === 1).every(item => item.tag === 'clutch'), 'reabrir nao reinicia paginas concluidas');
            await page.keyboard.press('Escape');

            // Aplicar antes da descoberta completa deve funcionar, sem aguardar a rede.
            await page.goto(base);
            await idle();
            hold();
            await open();
            await expect.poll(() => active).toBe(3);
            await black.check();
            await submit.click();
            await expect(page.locator('#be-filter-dialog')).not.toBeVisible();
            await idle();
            assert.equal(JSON.parse(new URL(page.url()).searchParams.get('be_filters')).be_color, 'preto');
            resume();
            await expect.poll(() => active).toBe(0);

            // Filtro da URL em uma pagina tardia nao pode sumir ao aplicar cedo.
            await page.goto(base + '/?be_filters=' + encodeURIComponent(JSON.stringify({be_color: 'terracota'})));
            await idle();
            hold();
            await open();
            await expect.poll(() => active).toBe(3);
            await expect(page.locator('[name="be_color"][value="terracota"]')).toHaveCount(0);
            await submit.click();
            await idle();
            assert.equal(JSON.parse(new URL(page.url()).searchParams.get('be_filters')).be_color, 'terracota', 'selecao ativa ainda nao descoberta e preservada');
            resume();
            await expect.poll(() => active).toBe(0);
            assert.deepEqual(errors, []);
            console.log('PASS ' + width + 'px: filtros utilizaveis com rede pendente, concorrencia limitada, foco/selecao, 12 paginas sem repeticoes, cache ao aplicar/reabrir e retomada apos cancelamento.');
            await page.close();
        }
    } finally { await browser.close(); }
})().catch(error => {console.error(error); process.exitCode = 1;});
