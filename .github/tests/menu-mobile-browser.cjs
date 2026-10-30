// Exercises the real hamburger Twig embed, native modal handlers and menu assets.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const Twig = require('twig');
const {chromium} = require('playwright');
const {context, render, read, startServer} = require('./menu-harness.cjs');
Twig.extendFilter('a_tag', (label, url) => `<a href="${url || '/account/login/'}">${label}</a>`);
Twig.twig({id: 'snipplets/modal.tpl', data: read('snipplets/modal.tpl'), rethrow: true, allowInlineIncludes: true});
// Twig.js needs a space here; native Twig accepts the theme's with{ spelling.
const hamburger = read('snipplets/header/header-modals.tpl').match(/{% embed "snipplets\/modal.tpl" with\{modal_id: 'nav-hamburger'[\s\S]*?{% endembed %}/)[0].replace(/with\{/g, 'with {');
Twig.twig({id: 'mobile-modal-test', data: hamburger, rethrow: true, allowInlineIncludes: true});
const nativeSource = read('static/js/store.js.tpl');
const nativeHandlers = Twig.twig({data: nativeSource.slice(nativeSource.indexOf('    function scheduleModalHide('), nativeSource.indexOf("    {% if template == 'home' and settings.home_promotional_popup %}"))}).render(context());
const modalStyles = read('static/css/style-async.scss');
const nativeModalCss = modalStyles.slice(modalStyles.indexOf('.modal {'), modalStyles.indexOf('.modal-bottom-sheet {'));
const out = process.env.MENU_TEST_OUTPUT || path.join(os.tmpdir(), 'eora-menu-mobile');
fs.mkdirSync(out, {recursive: true});

(async () => {
    const server = await startServer(0);
    const browser = await chromium.launch({headless: true, ...(process.env.BE_BROWSER ? {executablePath: process.env.BE_BROWSER} : {}), args: ['--no-sandbox']});
    try {
        const page = await browser.newPage({viewport: {width: 390, height: 844}});
        const errors = [];
        page.on('pageerror', error => errors.push(error.message));
        const data = context();
        for (const key of Object.keys(data.settings).filter(key=>key.endsWith('_images'))) {
            data.settings[key] = data.settings[key].map((image,i)=>({...image,image:'menu-preserved-' + (i+1) + '.webp'}));
        }
        const modal = render('mobile-modal-test', data);
        await page.route('**/mobile-menu-test', route => route.fulfill({contentType: 'text/html; charset=utf-8', body: `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>
            :root{--main-background:#fff;--main-foreground:#111}body{margin:0;font-family:Arial,sans-serif}.row{display:flex;flex-wrap:wrap}.col{flex:1 0 0}.col-auto{flex:0 0 auto}.p-3{padding:16px}.py-3{padding-top:16px;padding-bottom:16px}.align-items-center{align-items:center}.d-flex{display:flex}.no-gutters{margin:0}.icon-inline{width:20px;height:20px}.nav-login{padding:16px;background:#f3f3f3}.modal-close{display:flex;width:44px;min-height:44px;align-items:center;justify-content:center}.modal-overlay{position:fixed;inset:0;background:#0003;z-index:19999}.overflow-none{overflow:hidden}${nativeModalCss}
            </style><link rel="stylesheet" href="/static/css/eora-menu.css"></head><body><button class="js-modal-open" data-toggle="#nav-hamburger">Abrir menu</button>${modal}
            <svg style="display:none"><symbol id="times" viewBox="0 0 24 24"><path d="M4 4l16 16M20 4L4 20" stroke="currentColor" stroke-width="2"/></symbol></svg><script>${fs.readFileSync(require.resolve('jquery/dist/jquery.js'), 'utf8')}</script><script>var jQueryNuvem=jQuery;var modalOpen;function resetSearchBox(){}${nativeHandlers}</script><script src="/static/js/eora-menu.js"></script></body></html>`}));
        await page.goto('http://127.0.0.1:' + server.address().port + '/mobile-menu-test');
        const panel = page.locator('#nav-hamburger');
        const opener = page.locator('[data-toggle="#nav-hamburger"]');
        await opener.click();
        const header = panel.locator('.modal-header');
        assert.equal(await header.locator('a[href="/best-sellers1/"]').count(), 1, 'Best Sellers belongs beside Menu');
        assert.equal(await header.locator('a[href="/sobre1/"]').count(), 1, 'Sobre belongs beside Menu');
        assert.equal(await header.locator('a[href="/personal-shopper/"]').count(), 1, 'Personal Shopper belongs beside Menu');
        assert.equal(await panel.locator('.eora-menu__mobile-primary > a').count(), 0, 'header shortcuts are not duplicated among categories');
        await page.waitForFunction(() => !document.querySelector('#nav-hamburger').getAnimations().length);
        for (const width of [320, 360, 390, 768, 1199]) {
            await page.setViewportSize({width, height: 844});
            const boxes = await header.locator('.eora-menu__mobile-label, .eora-menu__mobile-shortcuts a, .modal-close').evaluateAll(nodes => nodes.map(node => { const r = node.getBoundingClientRect(); return {left:r.left,right:r.right,top:r.top,bottom:r.bottom,height:r.height}; }));
            assert.equal(boxes.length, 5);
            assert.ok(boxes.every(r => r.left >= 0 && r.right <= width + 1), 'header fits at ' + width + ': ' + JSON.stringify(boxes));
            assert.ok(Math.max(...boxes.map(r=>r.top)) < Math.min(...boxes.map(r=>r.bottom)), 'Menu, shortcuts and close share one row');
            assert.ok(boxes.slice(1).every(r=>r.height >= 44), 'links and close retain touch target height');
            assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), 'no horizontal overflow');
            if (width === 390) await page.screenshot({path: path.join(out, 'mobile.png')});
        }
        await page.evaluate(() => document.addEventListener('click', event => {
            if (!event.target.closest('.eora-menu__mobile-shortcuts a')) return;
            window.shortcutPrevented = event.defaultPrevented;
            event.preventDefault(); // Keep the test document; inspect the native handler's earlier result.
        }));
        await header.locator('a[href="/sobre1/"]').click();
        assert.equal(await page.evaluate(() => window.shortcutPrevented), false, 'shortcuts must not inherit click-to-close/preventDefault');
        assert.ok(await panel.evaluate(el => el.classList.contains('modal-show')));
        const close = panel.locator('a.modal-close');
        await close.click();
        await panel.waitFor({state:'hidden'});
        await page.setViewportSize({width:390,height:844});
        const motion = await opener.evaluate(button => { button.click(); return new Promise(resolve => requestAnimationFrame(() => {
            const panel = document.querySelector('#nav-hamburger');
            const animation = panel.getAnimations().find(a => a.effect.getTiming().duration >= 250);
            if (!animation) return resolve(null);
            panel.getAnimations().filter(a=>a.effect.getTiming().duration>=250).forEach(a=>{a.pause();a.currentTime=a.effect.getTiming().duration/2;});
            resolve({duration:animation.effect.getTiming().duration,clip:getComputedStyle(panel).clipPath});
        })); });
        assert.ok(motion && motion.duration <= 450, 'entry must visibly animate instead of appearing instantly');
        assert.notEqual(motion.clip, 'none');
        assert.ok((motion.clip.match(/[\d.]+/g) || []).some(value => Number(value) > 0), 'midpoint still reveals toward right and bottom');
        await page.screenshot({path:path.join(out,'mobile-opening.png')});
        const interrupted = await close.evaluate(button=>{
            const panel=button.closest('#nav-hamburger');
            const before=Number(getComputedStyle(panel).opacity);
            button.click();
            return {before,after:Number(getComputedStyle(panel).opacity)};
        });
        assert.ok(interrupted.before>.05 && Math.abs(interrupted.before-interrupted.after)<.05, 'closing during entry continues from the current visual state: '+JSON.stringify(interrupted));
        await panel.waitFor({state:'hidden'});
        await opener.evaluate(button=>button.click());
        await page.waitForFunction(()=>!document.querySelector('#nav-hamburger').getAnimations().length);
        await page.locator('[data-menu-screen="primary"] [data-menu-go="shop"]').click();
        await page.keyboard.press('Escape');
        assert.ok(await page.locator('[data-menu-screen="primary"]').isVisible());
        await page.keyboard.press('Escape');
        const exit = await panel.evaluate(el=>({shown:el.classList.contains('modal-show'),transition:getComputedStyle(el).transitionProperty}));
        assert.equal(exit.shown,false);
        assert.ok(exit.transition.includes('clip-path'), 'close should animate the same reveal in reverse');
        await panel.waitFor({state:'hidden'});
        await page.waitForFunction(()=>document.activeElement.matches('[data-toggle="#nav-hamburger"]'));
        await opener.evaluate(button=>button.click());
        await page.waitForTimeout(400);
        await close.click();
        await page.waitForTimeout(100);
        await opener.evaluate(button=>button.click());
        await page.waitForTimeout(550);
        assert.ok(await panel.isVisible(), 'an old hide timer must not hide a reopened menu');
        const laterClose = await panel.evaluate(async el=>{
            const wait=ms=>new Promise(resolve=>setTimeout(resolve,ms));
            const close=el.querySelector('a.modal-close');
            close.click();
            await wait(100);
            document.querySelector('[data-toggle="#nav-hamburger"]').click();
            await wait(250);
            close.click();
            await wait(175);
            return {display:getComputedStyle(el).display,visibility:getComputedStyle(el).visibility};
        });
        assert.notEqual(laterClose.display,'none','a hide timer from the previous close must not cut a later exit short');
        assert.equal(laterClose.visibility,'visible','the later exit remains visible until its transition completes');
        await panel.waitFor({state:'hidden'});
        await page.emulateMedia({reducedMotion:'reduce'});
        await opener.evaluate(button=>button.click());
        await page.waitForTimeout(50);
        assert.equal(await panel.evaluate(el=>el.getAnimations().filter(a=>a.effect.getTiming().duration>0).length),0,'reduced motion disables reveal animation');
        assert.equal(await panel.evaluate(el=>getComputedStyle(el).pointerEvents),'auto');
        assert.deepEqual(errors,[]);
        console.log('PASS mobile menu: real Twig/native handlers, header links/touch targets at 320–1199px, reversible reveal/exit, interrupted close, reduced motion, Escape/focus, fast reopen.');
    } finally { await browser.close(); await new Promise(resolve=>server.close(resolve)); }
})().catch(error=>{console.error(error);process.exitCode=1;});
