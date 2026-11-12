const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
const Twig = require('twig');
const existing = require('./bolsas-eora-harness.cjs');
const root = path.resolve(__dirname, '../..');
const temp = process.env.MARCELA_VALIDATION_DIR || 'C:/Temp/eora-marcela-validation';
const read = file => fs.readFileSync(path.join(root, file), 'utf8');
const live = fs.existsSync(path.join(temp, 'live-products.json')) ? JSON.parse(fs.readFileSync(path.join(temp, 'live-products.json'), 'utf8')) : [];
const hero = 'mf-upload-hero.jpg';
const lifestyle = 'mf-upload-lifestyle.jpg';
Twig.extendFilter('static_url', value => {
    const uploads = {'mf-upload-hero.jpg': '/fixtures/hero.jpg', 'mf-upload-lifestyle.jpg': '/fixtures/lifestyle.jpg', 'mf-upload-original.gif': '/fixtures/source-original.gif', 'campaign_page_04_banner_topo_img.jpg': '/fixtures/hero.jpg', 'campaign_page_04_banner_topo_mobile_img.jpg': '/fixtures/legacy-mobile.jpg'};
    return uploads[value] || '/static/' + value;
});
Twig.extendFilter('has_custom_image', value => ['campaign_page_04_banner_topo_img.jpg', 'campaign_page_04_banner_topo_mobile_img.jpg'].includes(value));
Twig.extendFilter('settings_image_url', value => value);
Twig.extendFilter('product_image_url', value => typeof value === 'string' ? value : value.url);
const templates = new Map();
for (const folder of ['marcela']) for (const file of fs.readdirSync(path.join(root, 'snipplets', folder))) {
    const id = 'snipplets/' + folder + '/' + file;
    templates.set(id, Twig.twig({id, data: read(id), rethrow: true, allowInlineIncludes: true}));
}
Twig.twig({id: 'snipplets/best-sellers/filters.tpl', data: read('snipplets/best-sellers/filters.tpl'), rethrow: true, allowInlineIncludes: true});
function context(options = {}) {
    const data = existing.context();
    data.current_settings_name = 'campaign_page_04';
    data.settings = {...data.settings, marcela_hero_enabled: true, marcela_hero_image: [{image: hero}], marcela_hero_image_mobile: [{image: lifestyle}], marcela_title: 'Favoritos da Marcela'};
    data.sections = {};
    const amount = options.amount ?? 42;
    const products = Array.from({length: amount}, (_, i) => {
        const original = live[i % Math.max(1, live.length)];
        const product = existing.product(i + 1, 'luar', original || {});
        product.id = 900000 + i;
        product.price = 100000 + i * 1000;
        product.other_images = [];
        product.featured_image = {...product.featured_image, url: '/fixtures/product-' + i % Math.max(1, live.length) + '.webp'};
        product.tags = (i % 3 === 0 ? [{tag: 'luar'}, {tag: 'oculos'}, {tag: 'tipo-lente:solar'}, {tag: 'cor-armacao:preto'}] : i % 3 === 1 ? [{tag: 'prism'}, {tag: 'oculos'}, {tag: 'formato:retangular'}, {tag: 'novo'}] : [{tag: 'bolsa'}, {tag: 'vertice'}, {tag: 'cor:preto'}, {tag: 'textura:lisa'}]);
        return product;
    });
    data.productsFixture = products;
    data.settings.marcela_custom_catalog = !options.legacy;
    if (options.legacy) {
        data.sections.campaign_page_04_fpc = {products: products.slice(0, 5)};
        data.sections.campaign_page_04_spc = {products: products.slice(3, 10)};
    } else {
        data.settings.marcela_catalog_1_enabled = true;
        data.sections.marcela_catalog_1 = {products};
        data.settings.marcela_catalog_2_enabled = true;
        data.sections.marcela_catalog_2 = {products: products.slice(0, 4)};
        data.sections.marcela_catalog_3 = {products: [existing.product(99999)]};
    }
    const tags = ['luar', 'prism', 'bolsa', 'nao-existe'];
    for (let i = 1; i <= (options.categories ?? 4); i++) {
        const p = 'marcela_category_' + i;
        Object.assign(data.settings, {[p + '_enabled']: true, [p + '_image']: [{image: i % 2 ? hero : lifestyle}], [p + '_mobile']: [{image: lifestyle}], [p + '_title']: ['Luar', 'Prism', 'Bolsas', 'Seleção'][i - 1] || 'Categoria ' + i, [p + '_tag']: tags[(i - 1) % tags.length], [p + '_description']: 'Os favoritos da Marcela: ' + tags[(i - 1) % tags.length] + '.', [p + '_order']: i});
    }
    for (let i = 1; i <= (options.looks ?? 4); i++) {
        const p = 'marcela_look_' + i;
        Object.assign(data.settings, {[p + '_enabled']: true, [p + '_image']: [{image: i % 2 ? lifestyle : hero}], [p + '_title']: 'Os favoritos da Marcela ' + i, [p + '_button']: 'Shop now', [p + '_order']: 11 - i});
        data.sections[p] = {products: products.slice(0, 3)};
    }
    for (let i = 1; i <= (options.founder ?? 6); i++) {
        const p = 'marcela_founder_' + i;
        Object.assign(data.settings, {[p + '_enabled']: true, [p + '_image']: [{image: i % 2 ? lifestyle : hero}], [p + '_title']: ['Bolsas', 'Óculos', 'Coleção .M.'][i % 3], [p + '_description']: 'Uma seleção pessoal de peças que acompanham diferentes versões de quem usa. Design, presença e expressão em cada detalhe.', [p + '_button']: 'Ver mais', [p + '_link']: '/favoritosdamarcela/', [p + '_order']: i});
    }
    if (options.empty) { data.sections = {}; data.settings.marcela_custom_catalog = true; }
    if (options.video) data.settings.marcela_hero_video = options.video;
    return data;
}
function render(data) { return templates.get('snipplets/marcela/index.tpl').render(data); }
function server(port = 4178) {
    return http.createServer((req, res) => {
        try {
            const url = new URL(req.url, 'http://127.0.0.1:' + port);
            if (url.pathname.startsWith('/static/')) {
                const file = path.resolve(root, 'static', url.pathname.slice(8));
                if (!file.startsWith(path.join(root, 'static') + path.sep)) { res.writeHead(403); return res.end(); }
                res.setHeader('Content-Type', file.endsWith('.css') ? 'text/css' : 'text/javascript'); return res.end(fs.readFileSync(file));
            }
            if (url.pathname.startsWith('/fixtures/')) {
                const file = path.join(temp, 'assets', path.basename(url.pathname));
                res.setHeader('Content-Type', file.endsWith('.webp') ? 'image/webp' : file.endsWith('.png') ? 'image/png' : 'image/jpeg'); return res.end(fs.readFileSync(file));
            }
            const data = context({amount: Number(url.searchParams.get('amount') || 42), empty: url.searchParams.has('empty'), legacy: url.searchParams.has('legacy'), categories: url.searchParams.has('minimal') ? 0 : 4, looks: url.searchParams.has('minimal') ? 0 : 4, founder: url.searchParams.has('minimal') ? 0 : 6, video: url.searchParams.get('video')});
            res.setHeader('Content-Type', 'text/html; charset=utf-8');
            res.end('<!doctype html><html lang="pt-BR" class="eora-commerce-brl"><head><meta name="viewport" content="width=device-width, initial-scale=1"><title>Favoritos da Marcela — prévia</title><link rel="stylesheet" href="/static/css/product-commerce.css"><style>body{margin:0;font-family:Arial,sans-serif}button,select{font:inherit}.mf-preview-header{padding:20px 32px;display:flex;justify-content:space-between;align-items:center;border-bottom:1px solid #eee;font-size:10px}.mf-preview-header img{width:100px;height:auto}.mf-preview-note{padding:6px;text-align:center;font-size:10px;background:#f5f5f5}.hidden{display:none}</style></head><body><div class="mf-preview-note">Prévia local — conteúdo demonstrativo para conferir a estrutura do briefing</div><header class="mf-preview-header"><span>MENU　 BEST SELLERS</span><a href="/favoritosdamarcela/"><img src="/fixtures/logo-native.png" alt="EORA"></a><span>BUSCAR　 SACOLA</span></header>' + read('snipplets/svg/icons.tpl') + render(data) + '<script src="/static/js/product-payment-summary.js.tpl"></script></body></html>');
        } catch (error) { console.error(error); res.writeHead(500); res.end(String(error)); }
    }).listen(port, '127.0.0.1', () => console.log('Marcela preview: http://127.0.0.1:' + port + '/favoritosdamarcela/'));
}
if (require.main === module) server();
module.exports = {context, render, server};
