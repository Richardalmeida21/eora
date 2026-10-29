// Read-only integration against a public storefront snapshot and its original compiled styles.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const {chromium} = require('playwright');
const {context, render, read, startServer} = require('./menu-harness.cjs');
(async () => {
    const snapshot = fs.readFileSync(process.env.MENU_NATIVE_SNAPSHOT || 'C:/Temp/eora-best-sellers-validation/current.html', 'utf8');
    const dir = 'C:/Temp/eora-menu-preview';
    const cssFiles = fs.readdirSync(dir).filter(name => /^native-\d+\.css$/.test(name));
    assert.ok(cssFiles.length >= 3, 'Cache the native compiled styles before running this integration check');
    const css = cssFiles.map(file => fs.readFileSync(dir + '/' + file, 'utf8')).join('\n');
    const tokens = [...snapshot.matchAll(/<style\b[^>]*>([\s\S]*?)<\/style>/g)].map(m => m[1]).filter(s => s.includes('--main-foreground:')).join('\n');
    const server = await startServer(0);
    const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
    try {
        const page = await browser.newPage({viewport: {width: 1440, height: 1000}});
        await page.route('**/static/js/eora-menu.js', route => route.fulfill({body: ''}));
        await page.goto('http://127.0.0.1:' + server.address().port);
        const data = context();
        await page.evaluate(({snapshot, desktop, mobile, search}) => {
            const doc = new DOMParser().parseFromString(snapshot, 'text/html');
            const header = doc.querySelector('header.js-head-main');
            header.querySelector('.js-desktop-nav-col').innerHTML = desktop;
            header.querySelectorAll('.js-desktop-nav-col,.js-utility-col').forEach(el => { el.style.visibility = 'visible'; el.style.height = 'auto'; });
            const nav = doc.querySelector('#nav-hamburger');
            nav.querySelector('.nav-primary').innerHTML = mobile;
            const searchModal = doc.querySelector('#nav-search');
            searchModal.querySelector('form').insertAdjacentHTML('afterend', search);
            searchModal.querySelector('.-result-input')?.remove(); // Replaced by discovery heading in header-search.tpl.
            const symbols = doc.querySelector('#logo')?.closest('svg');
            document.body.className = 'template-home';
            document.body.innerHTML = (symbols?.outerHTML || '') + header.outerHTML + nav.outerHTML + searchModal.outerHTML + '<main style="height:1500px;background:#eee"></main>';
            document.querySelector('link[href="/preview.css"]').remove();
        }, {snapshot, desktop: render('snipplets/navigation/navigation.tpl', data), mobile: render('snipplets/navigation/eora-menu.tpl', {...data, mode: 'mobile'}), search: render('snipplets/header/search-discovery.tpl', data)});
        await page.addStyleTag({content: css + '\n' + tokens + '\n' + read('static/css/eora-menu.css')});
        await page.addScriptTag({content: read('static/js/eora-menu.js')});
        for (const width of [1440, 1920]) {
            await page.setViewportSize({width, height: 1000});
            const left = await page.locator('[data-menu-toggle]').evaluate(el => el.getBoundingClientRect().left);
            assert.ok(left >= 24 && left <= 80, 'menu keeps a comfortable left inset at ' + width + 'px: ' + left);
        }
        await page.setViewportSize({width: 1440, height: 1000});
        await page.locator('[data-menu-toggle]').click();
        const geometry = await page.evaluate(() => {
            const head = document.querySelector('header').getBoundingClientRect();
            const panel = document.querySelector('[data-menu-desktop]').getBoundingClientRect();
            return {headBottom: head.bottom, top: panel.top, width: panel.width, height: panel.height, windowWidth: innerWidth, windowHeight: innerHeight, transform: getComputedStyle(document.querySelector('header')).transform};
        });
        assert.notEqual(geometry.transform, 'none', 'Exercise the real transformed native header');
        assert.ok(Math.abs(geometry.top - geometry.headBottom) < 1, JSON.stringify(geometry));
        assert.ok(Math.abs(geometry.width - geometry.windowWidth) < 1, JSON.stringify(geometry));
        assert.ok(geometry.top + geometry.height <= geometry.windowHeight * .6, JSON.stringify(geometry));
        await page.locator('[data-menu-desktop] img').evaluateAll(images => Promise.all(images.map(i => i.decode().catch(() => {}))));
        await page.screenshot({path: dir + '/native-desktop.png'});
        await page.keyboard.press('Escape');
        await page.locator('#nav-search').evaluate(el => { document.body.appendChild(el); el.style.display = 'block'; el.classList.add('modal-show'); });
        const nativeColumns = await page.locator('[data-search-track]').evaluate(el => (el.clientWidth + 12) / (el.firstElementChild.getBoundingClientRect().width + 12));
        assert.ok(Math.abs(nativeColumns - 3) < .02, 'native search shows three complete products');
        await page.screenshot({path: dir + '/native-search-desktop.png'});
        await page.locator('#nav-search').evaluate(el => { el.style.display = 'none'; el.classList.remove('modal-show'); });
        await page.setViewportSize({width: 390, height: 844});
        // Reproduce only the display/detach behavior in native modalOpen, without inventing focus or Escape.
        await page.evaluate(() => {
            document.addEventListener('click', event => {
                const open = event.target.closest('[data-toggle="#nav-hamburger"]');
                if (open) { event.preventDefault(); const modal = document.querySelector('#nav-hamburger'); document.body.appendChild(modal); modal.style.display = 'block'; modal.classList.add('modal-show'); }
                const close = event.target.closest('#nav-hamburger .js-modal-close');
                if (close) { event.preventDefault(); const modal = document.querySelector('#nav-hamburger'); modal.classList.remove('modal-show'); modal.style.display = 'none'; }
            });
        });
        await page.locator('[data-toggle="#nav-hamburger"]').click();
        await page.waitForFunction(() => document.activeElement.closest('[data-menu-screen="primary"]'));
        assert.equal(await page.locator('[data-menu-screen="primary"]:visible').count(), 1);
        await page.locator('[data-menu-screen="primary"] [data-menu-go="secondary"]').click();
        await page.locator('[data-menu-screen="secondary"] [data-menu-go="shop"]').click();
        await page.screenshot({path: dir + '/native-mobile.png'});
        await page.keyboard.press('Escape');
        await page.keyboard.press('Escape');
        await page.keyboard.press('Escape');
        assert.equal(await page.locator('#nav-hamburger').evaluate(el => getComputedStyle(el).display), 'none');
        console.log('PASS native integration: original header markup/compiled CSS, viewport-aligned desktop panel, mobile focus/levels/Escape through native close control.');
    } finally { await browser.close(); await new Promise(resolve => server.close(resolve)); }
})().catch(error => { console.error(error); process.exitCode = 1; });
