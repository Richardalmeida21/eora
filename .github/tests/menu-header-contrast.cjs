// Reproduces the home header losing :hover after the pointer enters the body-mounted dropdown.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const {chromium} = require('playwright');
const {context, render, read, startServer} = require('./menu-harness.cjs');
const snapshot = fs.readFileSync(process.env.MENU_HOME_SNAPSHOT || 'C:/Temp/eora-menu-cleanup/contrast-home.html', 'utf8');
const dir = 'C:/Temp/eora-menu-preview';
const css = fs.readdirSync(dir).filter(n => /^native-\d+\.css$/.test(n)).map(n => fs.readFileSync(dir + '/' + n, 'utf8')).join('\n');
const tokens = [...snapshot.matchAll(/<style\b[^>]*>([\s\S]*?)<\/style>/g)].map(m => m[1]).filter(s => s.includes('--main-foreground:')).join('\n');
(async () => {
    const server = await startServer(0);
    const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
    try {
        const page = await browser.newPage({viewport: {width: 1440, height: 1000}, reducedMotion: 'reduce'});
        await page.route('**/static/js/eora-menu.js', route => route.fulfill({body: ''}));
        await page.goto('http://127.0.0.1:' + server.address().port);
        await page.setContent('<!doctype html><html><head></head><body class="template-home"></body></html>');
        await page.evaluate(({snapshot, desktop}) => {
            const doc = new DOMParser().parseFromString(snapshot, 'text/html');
            const header = doc.querySelector('header.js-head-main');
            header.querySelector('.js-desktop-nav-col').innerHTML = desktop;
            header.querySelectorAll('.js-desktop-nav-col,.js-utility-col').forEach(el => { el.style.visibility = 'visible'; el.style.height = 'auto'; });
            const symbols = doc.querySelector('symbol')?.closest('svg');
            document.body.innerHTML = (symbols?.outerHTML || '') + header.outerHTML + '<main style="height:1500px;background:linear-gradient(110deg,#9d3333,#e1ba81,#295c7c)"></main>';
        }, {snapshot, desktop: render('snipplets/navigation/navigation.tpl', context())});
        // Ensure deterministic logo loading without changing the original header markup/classes.
        const logos = [0, 1].map(i => fs.readFileSync('C:/Temp/eora-menu-cleanup/contrast-logo-' + i + '.webp').toString('base64'));
        await page.locator('.logo-img').evaluateAll((images, logos) => images.forEach((image, i) => { image.src = 'data:image/webp;base64,' + logos[i]; }), logos);
        await page.addStyleTag({content: css + '\n' + tokens + '\n' + read('static/css/eora-menu.css')});
        await page.addScriptTag({content: read('static/js/eora-menu.js')});
        for (const width of [1440, 1920]) for (const compress of [false, true]) {
            await page.setViewportSize({width, height: 1000});
            await page.locator('header').evaluate((el, compress) => el.classList.toggle('compress', compress), compress);
            await page.locator('[data-menu-toggle]').hover();
            await page.locator('[data-menu-desktop]').waitFor({state: 'visible'});
            await page.locator('[data-menu-desktop]').hover();
            const state = await page.evaluate(() => {
                const header = document.querySelector('header');
                const normalLogo = header.querySelector('.logo-img:not(.logo-header-transparent)');
                const darkLogo = header.querySelector('.logo-header-transparent');
                return {hover: header.matches(':hover'), blend: getComputedStyle(header).mixBlendMode, background: getComputedStyle(header).backgroundColor, linkColor: getComputedStyle(header.querySelector('.eora-menu__primary a')).color, normalOpacity: getComputedStyle(normalLogo).opacity, darkOpacity: getComputedStyle(darkLogo).opacity};
            });
            assert.equal(state.hover, false, 'pointer is in the dropdown outside the transformed header');
            assert.equal(state.blend, 'normal', JSON.stringify(state));
            await page.waitForFunction(() => getComputedStyle(document.querySelector('header')).backgroundColor === 'rgb(255, 255, 255)');
            await page.waitForFunction(() => getComputedStyle(document.querySelector('header .eora-menu__primary a')).color === 'rgb(0, 0, 0)');
            await page.waitForFunction(() => getComputedStyle(document.querySelector('.logo-header-transparent')).opacity === '1');
            assert.equal(state.normalOpacity, '0', 'the white logo must not cover the dark logo');
            await page.locator('img:visible').evaluateAll(images => Promise.all(images.map(image => image.decode().catch(() => {}))));
            await page.screenshot({path: dir + '/header-contrast-' + width + '-' + (compress ? 'scroll' : 'top') + '.png'});
            await page.keyboard.press('Escape');
            assert.equal(await page.locator('header').evaluate(el => getComputedStyle(el).mixBlendMode), 'difference', 'closing restores the chosen transparent-header behavior');
        }
        console.log('PASS home header contrast at 1440/1920px: pointer leaves header for menu, opaque background, normal blend, dark links/logo, compressed state, transparency restored on close.');
    } finally { await browser.close(); await new Promise(resolve => server.close(resolve)); }
})().catch(e => { console.error(e); process.exitCode = 1; });
