const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const Twig = require('twig');
const {JSDOM} = require('jsdom');
const root = path.resolve(__dirname, '../..');
const read = file => fs.readFileSync(path.join(root, file), 'utf8');
const widths = {large: 480, huge: 640, original: 1024, xlarge: 1400, '1080p': 1920};
Twig.extendFilter('static_url', value => '/assets/' + value);
Twig.extendFilter('settings_image_url', (value, size) => value + '?width=' + widths[size]);
Twig.extendFilter('setting_url', value => value);

function banners() {
    const template = Twig.twig({data: read('snipplets/home/home-banners-scroll.tpl'), rethrow: true});
    const html = template.render({settings: {banners_scroll_show: true, banners_scroll: [
        {image: 'mini.webp', link: '/mini/', button: 'Mini Vértice'},
        {image: 'maxi.webp', link: '/maxi/', button: 'Maxi Vértice'},
    ]}});
    const dom = new JSDOM(html, {url: 'https://eora.test/', runScripts: 'dangerously', beforeParse(window) {
        // Swiper is external to the image error path under test.
        window.Swiper = function () {};
    }});
    return dom;
}

test('an image failure recovers the same banner at a smaller resolution', () => {
    const dom = banners();
    try {
        const image = dom.window.document.querySelector('.banners-scroll-image img');
        const healthy = image.parentElement.closest('.swiper-wrapper').querySelectorAll('img')[1];
        const healthyMarkup = healthy.outerHTML;
        image.src = '/assets/mini.webp?width=1400';
        image.srcset = '/assets/mini.webp?width=1400 1400w';
        image.dispatchEvent(new dom.window.Event('error'));
        assert.equal(new URL(image.src).pathname, '/assets/mini.webp');
        assert.equal(new URL(image.src).searchParams.get('width'), '480');
        assert(!image.hasAttribute('srcset'), 'the browser must stop selecting the failed candidate');
        assert(!image.hasAttribute('data-srcset'), 'lazysizes must not restore the failed candidate');
        assert.equal(image.closest('a').getAttribute('href'), '/mini/');
        assert.equal(healthy.outerHTML, healthyMarkup, 'other banners are untouched');
    } finally { dom.window.close(); }
});

test('repeated image failures stop after two recovery requests', () => {
    const dom = banners();
    try {
        const image = dom.window.document.querySelector('.banners-scroll-image img');
        image.src = '/assets/mini.webp?width=1400';
        const sources = [];
        for (let i = 0; i < 4; i++) {
            image.dispatchEvent(new dom.window.Event('error'));
            sources.push(image.src);
        }
        assert.notEqual(sources[0], sources[1], 'a transient failure gets a fresh request');
        assert.equal(sources[1], sources[2], 'the third error does not start an infinite loop');
        assert.equal(sources[2], sources[3]);
    } finally { dom.window.close(); }
});

function header(width, template = 'home', extra = {}, geometry = {}) {
    const source = read('static/js/store.js.tpl');
    const block = source.slice(source.indexOf('    {# Transparent head #}'), source.indexOf('    {# Nav subitems hamburger #}'));
    const script = Twig.twig({data: block, rethrow: true}).render({template, settings: {
        head_transparent: true, head_transparent_type: 'all',
        slider: [{}], home_order_position_1: 'slider', ...extra,
    }});
    const dom = new JSDOM('<header class="js-head-mutator head-main head-transparent" style="height:70px"></header><section class="js-home-main-slider-container" style="height:900px"><div class="js-home-main-slider-visibility"></div></section><section class="js-home-mobile-slider-visibility"></section><div class="js-category-controls"></div>', {runScripts: 'outside-only'});
    dom.window.innerWidth = width;
    const doc = dom.window.document;
    doc.querySelector('header').getBoundingClientRect = () => ({top: 0, bottom: 70, height: 70, width});
    for (const [selector, visible] of [['.js-home-main-slider-visibility', !geometry.mobileOnly], ['.js-home-mobile-slider-visibility', !!geometry.mobileOnly]]) {
        doc.querySelector(selector).getBoundingClientRect = () => visible ? {
            top: (geometry.heroTop || 0) - dom.window.scrollY,
            bottom: (geometry.heroTop || 0) + 900 - dom.window.scrollY,
            height: 900, width,
        } : {top: 0, bottom: 0, width: 0, height: 0};
    }
    dom.window.eval(fs.readFileSync(require.resolve('jquery'), 'utf8'));
    dom.window.jQueryNuvem = dom.window.jQuery;
    dom.window.eval(script);
    return dom;
}

function scroll(dom, y) {
    dom.window.scrollY = y;
    dom.window.dispatchEvent(new dom.window.Event('scroll'));
}

test('mobile header covers content below the hero in both scroll directions', () => {
    const dom = header(390);
    try {
        const el = dom.window.document.querySelector('header');
        scroll(dom, 300);
        assert(!el.classList.contains('eora-header-solid'), 'the hero retains its transparent header');
        scroll(dom, 850);
        assert(el.classList.contains('eora-header-solid'), 'the bar is opaque when content first enters its area');
        scroll(dom, 1300);
        assert(el.classList.contains('eora-header-solid'), 'section titles need an opaque header immediately');
        scroll(dom, 1100);
        assert(el.classList.contains('eora-header-solid'), 'scrolling upward below the hero must remain opaque');
        scroll(dom, 0);
        assert(!el.classList.contains('eora-header-solid'), 'returning to the hero restores transparency');
    } finally { dom.window.close(); }
});

test('mobile header handles restored scroll position and resizing', () => {
    const dom = header(390);
    try {
        scroll(dom, 1300);
        const el = dom.window.document.querySelector('header');
        assert(el.classList.contains('eora-header-solid'));
        dom.window.innerWidth = 1440;
        dom.window.dispatchEvent(new dom.window.Event('resize'));
        assert(!el.classList.contains('eora-header-solid'), 'desktop transparency is preserved after rotation');
        assert(el.classList.contains('head-transparent'), 'desktop hover styling remains available after rotation');
        dom.window.innerWidth = 390;
        dom.window.dispatchEvent(new dom.window.Event('pageshow'));
        assert(el.classList.contains('eora-header-solid'), 'history restoration updates the header without scrolling');
    } finally { dom.window.close(); }
});

test('desktop keeps its configured transparent header', () => {
    const dom = header(1440);
    try {
        scroll(dom, 1300);
        assert(!dom.window.document.querySelector('header').classList.contains('eora-header-solid'));
    } finally { dom.window.close(); }
});

test('mobile hero bounds account for negative top margins and separate mobile artwork', () => {
    const dom = header(390, 'home', {}, {heroTop: -120, mobileOnly: true});
    try {
        scroll(dom, 300);
        const el = dom.window.document.querySelector('header');
        assert(!el.classList.contains('eora-header-solid'), 'visible mobile artwork retains its transparent header');
        scroll(dom, 720);
        assert(el.classList.contains('eora-header-solid'), 'opacity follows the visible hero bottom, including its negative margin');
    } finally { dom.window.close(); }
});
