const assert = require('node:assert/strict');
const {chromium, expect} = require('@playwright/test');
const base = process.env.BE_BASE_URL || 'http://127.0.0.1:4175';

(async () => {
    const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
    try {
        const page = await browser.newPage();
        const errors = [];
        page.on('pageerror', error => errors.push(error.message));
        for (const pathname of ['/bolsas-eora', '/oculos-eora']) {
            await page.setViewportSize({width: 1440, height: 900});
            await page.goto(base + pathname);
            await expect(page.locator('[data-be-page]')).toHaveAttribute('data-be-ready', '1');
            // Redimensiona a mesma pagina para verificar tambem os novos limites.
            for (const width of [1440, 390, 1024]) {
                await page.setViewportSize({width, height: 900});
                const sections = page.locator('[data-be-carousel]');
                for (let index = 0; index < await sections.count(); index++) {
                    const section = sections.nth(index);
                    const track = section.locator('[data-be-track]');
                    const metric = await track.evaluate(el => ({
                        maximum: el.scrollWidth - el.clientWidth,
                        step: el.children.length > 1 ? el.children[1].offsetLeft - el.children[0].offsetLeft : 0,
                    }));
                    if (metric.maximum <= 2) {
                        await expect(section.locator('[data-be-controls]')).toBeHidden();
                        continue;
                    }
                    const previous = section.locator('[data-be-prev]');
                    const next = section.locator('[data-be-next]');
                    const dots = section.locator('.be-dot');
                    const position = target => expect.poll(async () => Math.abs(await track.evaluate(el => el.scrollLeft) - target)).toBeLessThan(2);
                    await dots.first().click();
                    await position(0);
                    await expect(previous).toBeDisabled();
                    for (let step = 1; step <= 2; step++) {
                        if (metric.maximum <= (step - 1) * metric.step + 2) break;
                        await next.click();
                        await position(Math.min(step * metric.step, metric.maximum));
                        await expect(dots.nth(step)).toHaveAttribute('aria-current', 'true');
                    }
                    await dots.last().click();
                    await position(metric.maximum);
                    await expect(next).toBeDisabled();
                    // A ultima posicao pode ser parcial; voltar alinha o item anterior.
                    const preceding = await track.evaluate(el => {
                        const maximum = el.scrollWidth - el.clientWidth;
                        return [...el.children].map(child => child.offsetLeft - el.children[0].offsetLeft).filter(left => left < maximum - 2).pop();
                    });
                    await previous.click();
                    await position(preceding);
                    await dots.first().click();
                    await position(0);
                    assert.equal(await section.locator('.be-dot[aria-current="true"]').count(), 1);
                }
                console.log('PASS ' + pathname + ' ' + width + 'px: avancar um item, voltar, dots, limites e resize em todos os carrosseis.');
            }
        }
        assert.deepEqual(errors, []);
    } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
