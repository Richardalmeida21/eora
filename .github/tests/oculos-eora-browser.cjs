const assert = require('node:assert/strict');
const path = require('node:path');
const {chromium, expect} = require('@playwright/test');

const base = 'http://127.0.0.1:4175';
const output = process.env.BE_VALIDATION_DIR || 'C:/Temp/eora-bolsas-validation';
const executablePath = process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe';

(async () => {
    const browser = await chromium.launch({headless: true, executablePath});
    const page = await browser.newPage({viewport: {width: 1440, height: 900}});
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    try {
        const cards = () => page.locator('[data-be-results-grid] [data-be-product]');
        const idle = () => expect(page.locator('[data-be-results]')).toHaveAttribute('aria-busy', 'false');

        await page.goto(base + '/oculos-eora');
        await idle();
        await expect(page.locator('[data-be-result-title]')).toHaveText('Todos os óculos');
        await expect(cards()).toHaveCount(24);
        assert.deepEqual(await page.locator('[data-be-tag]').evaluateAll(nodes => nodes.map(node => node.dataset.beTitle)), ['IRIS', 'NOVA', 'ASTRA', 'LUNA', 'LUAR', 'ONYX', 'SPARKY']);

        await page.locator('[data-be-more]').scrollIntoViewIfNeeded();
        await expect(cards()).toHaveCount(30);
        await idle();

        await page.locator('[data-be-open-filters]').click();
        await expect(page.locator('[data-be-facet-status]')).toHaveText('');
        const expectedFacets = [
            ['oe_shape', 'Formato'],
            ['oe_style', 'Estilo'],
            ['oe_frame_color', 'Cor da armação'],
            ['oe_lens_color', 'Cor da lente'],
            ['oe_lens_type', 'Tipo de lente'],
            ['oe_frame_material', 'Material da armação'],
            ['oe_size', 'Tamanho'],
        ];
        for (const [key, label] of expectedFacets) {
            await expect(page.locator('[data-be-facet="' + key + '"] legend')).toHaveText(label);
        }
        assert.deepEqual(await page.locator('[data-be-facet="oe_shape"] input').evaluateAll(nodes => nodes.map(node => node.value)), ['aviador', 'retangular', 'quadrado', 'oval', 'redondo', 'cat-eye', 'geometrico']);
        assert.deepEqual(await page.locator('[data-be-facet="oe_lens_type"] input').evaluateAll(nodes => nodes.map(node => node.value)), ['solar', 'oftalmica-clara', 'degrade']);
        await page.locator('[name="oe_shape"][value="aviador"]').check();
        await page.locator('[name="oe_style"][value="classico"]').check();
        await page.locator('[data-be-filter-form] [type="submit"]').click();
        await idle();
        await expect(cards()).toHaveCount(2);
        assert(new URL(page.url()).searchParams.has('oe_filters'));
        assert(!new URL(page.url()).searchParams.has('be_filters'));
        assert((await cards().evaluateAll(nodes => nodes.every(node => {
            const tags = JSON.parse(node.dataset.beTags);
            return tags.includes('formato:aviador') && tags.includes('estilo:classico');
        }))));

        await page.locator('[data-be-reset]').click();
        await idle();
        await page.locator('[data-be-tag="iris"]').click();
        await idle();
        await expect(page.locator('[data-be-result-title]')).toHaveText('IRIS');
        assert((await cards().count()) > 0);
        assert(await cards().evaluateAll(nodes => nodes.every(node => JSON.parse(node.dataset.beTags).includes('iris'))));

        await page.setViewportSize({width: 390, height: 844});
        await page.goto(base + '/oculos-eora');
        await idle();
        assert.equal(await page.locator('[data-be-results-grid]').evaluate(element => getComputedStyle(element).gridTemplateColumns.split(' ').length), 2);
        await page.screenshot({path: path.join(output, 'oculos-eora-mobile.png'), fullPage: true});
        await page.locator('[data-be-open-filters]').click();
        await expect(page.locator('#be-filter-dialog')).toBeVisible();
        assert((await page.locator('#be-filter-dialog').boundingBox()).height <= 760);
        await page.screenshot({path: path.join(output, 'oculos-eora-mobile-filters.png')});
        await page.keyboard.press('Escape');
        assert.deepEqual(errors, []);
        console.log('PASS Óculos Eora: categoria/24 produtos, sete modelos, sete facetas, tags, URL isolada, filtros combinados e layout mobile.');
    } finally {
        await browser.close();
    }
})().catch(error => { console.error(error); process.exitCode = 1; });
