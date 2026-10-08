// Previa e verificacao local. .github nao e enviado ao tema por FTP.
const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
const assert = require('node:assert/strict');
const Twig = require('twig');
const root = path.resolve(__dirname, '../..');
const args = process.argv;
process.argv = args.slice(0, 2);
const existing = require('./bolsas-eora-harness.cjs');
process.argv = args;
const temp = process.env.BS_VALIDATION_DIR || 'C:/Temp/eora-best-sellers-validation';
const fixtures = 'C:/Temp/eora-bolsas-validation/assets';
const asset = i => '/fixtures/image-' + i % 6 + '.webp';
const tags = ['onyx', 'prism', 'minivertice', 'luar'];
const images = fs.existsSync(path.join(temp, 'images.json')) ? JSON.parse(fs.readFileSync(path.join(temp, 'images.json'), 'utf8')) : {};
const modelImage = (tag, type, fallback) => images[tag]?.[type] || fallback;
Twig.extendFilter('static_url', value => /^best_sellers_eora_macro_\d+(?:_mobile)?\.jpg$/.test(value) ? modelImage(tags[(Number(value.match(/\d+/)[0]) - 1) % 4], 'lifestyle', asset(Number(value.match(/\d+/)[0]))) + (value.includes('_mobile') ? '?fixture_crop=mobile' : '') : value.startsWith('/fixtures/') ? value : '/static/' + value);
Twig.extendFilter('has_custom_image', value => /^best_sellers_eora_macro_\d+\.jpg$/.test(value) || value === 'best_sellers_eora_macro_1_mobile.jpg');
// A query identifica a thumb escolhida, sem depender do CDN nos testes.
const thumbnail = (value, params) => {
    const url = new URL(value, 'http://127.0.0.1:4176');
    url.searchParams.set('fixture_thumb', params[0]);
    return /^https?:/.test(value) ? url.href : url.pathname + url.search;
};
Twig.extendFilter('settings_image_url', thumbnail);
Twig.extendFilter('product_image_url', (value, params) => thumbnail(typeof value === 'string' ? value : value.url, params));
const templates = new Map();
for (const file of fs.readdirSync(path.join(root, 'snipplets/best-sellers'))) {
    const id = 'snipplets/best-sellers/' + file;
    templates.set(id, Twig.twig({id, data: fs.readFileSync(path.join(root, id), 'utf8'), rethrow: true, allowInlineIncludes: true}));
}
function context(options = {}) {
    const data = existing.context();
    data.current_settings_name = 'campaign_page_01';
    data.settings = {...data.settings, best_sellers_eora_title: 'Best sellers', best_sellers_eora_filters_enabled: true, best_sellers_eora_community_enabled: true, best_sellers_eora_community_title: 'Quem usa Eora', best_sellers_eora_community_subtitle: 'Nossa comunidade', best_sellers_eora_community_link: '/quem-usa/', best_sellers_eora_categories_enabled: true, best_sellers_eora_categories: data.settings.bolsas_eora_categories};
    data.settings.best_sellers_eora_community = Array.from({length: options.galleryItems ?? 18}, (_, i) => ({image: modelImage(tags[i % 4], 'lifestyle', asset(i)), link: '/quem-usa/todos-' + i, title: 'Nossa comunidade ' + i}));
    data.settings.best_sellers_eora_categories = [...tags, 'onyx'].slice(0, options.bannerItems ?? 5).map((tag, i) => ({image: modelImage(tag, 'lifestyle', asset(i)), title: ['Onyx', 'Prism', 'Mini Vértice', 'Luar', 'Todos os modelos'][i], button: 'Conheça a coleção', link: '/colecao/' + tag}));
    for (let i = 1; i <= 15; i++) {
        const prefix = 'best_sellers_eora_macro_' + i;
        const tag = tags[(i - 1) % tags.length];
        data.settings[prefix + '_enabled'] = i <= (options.macros ?? 4);
        data.settings[prefix + '_tag'] = tag;
        data.settings[prefix + '_title'] = ['Onyx', 'Prism', 'Mini Vértice', 'Luar'][(i - 1) % 4];
        data.settings[prefix + '_description'] = 'Os favoritos da coleção ' + data.settings[prefix + '_title'] + '. Design EORA para todos os dias.';
        data.settings[prefix + '_order'] = i;
        data.settings[prefix + '_community'] = Array.from({length: 18}, (_, j) => ({image: modelImage(tag, 'lifestyle', asset(j + i)), title: tag + ' — nossa comunidade', link: '/quem-usa/' + tag + '-' + j}));
        if (options.communityMode === 'general') data.settings[prefix + '_community'] = [];
        if (options.communityMode === 'imageless' || options.communityMode === 'mixed') {
            data.settings[prefix + '_community'] = options.communityMode === 'mixed' && i === 2
                ? data.settings[prefix + '_community'].slice(0, 3)
                : [{title: tag + ' — cadastro sem foto', link: '/quem-usa/sem-foto-' + i}, {image: '', title: 'Foto ainda nao enviada'}];
        }
    }
    data.category_products = Array.from({length: options.empty ? 0 : options.amount ?? 120}, (_, n) => {
            const tag = tags[n % 4];
            const bag = tag === 'minivertice';
            return existing.product(n + 1, tag, {
                name: (bag ? 'Bolsa Mini Vértice' : 'Óculos ' + tag.toUpperCase()) + ' ' + (n + 1), price: 10000 + n * 1000,
                featured_image: {url: modelImage(tag, 'primary', asset(n)), dimensions: {width: 900, height: 1221}},
                other_images: [{url: modelImage(tag, 'lifestyle', asset(n + 1))}],
                tags: [tag, bag ? 'bolsa' : 'oculos', bag ? 'cor:' + (n % 2 ? 'marrom' : 'preto') : 'formato:' + (n % 2 ? 'aviador' : 'redondo'), 'cor-armacao:preto', 'cor-lente:cinza', 'tamanho:medio'],
            });
        });
    // Produtos com a mesma tag fora da categoria nunca podem entrar na campanha.
    data.sections.best_sellers = {products: [existing.product(888, 'onyx')]};
    data.sections.campaign_page_01_fpc = {products: [existing.product(889, 'onyx')]};
    data.sections.best_sellers_eora_catalog_1 = {products: [existing.product(890, 'onyx')]};
    if (options.empty) { data.sections = {}; data.settings.best_sellers_eora_community = []; }
    if (options.noFilters) data.settings.best_sellers_eora_filters_enabled = false;
    if (options.noCommunity) { data.settings.best_sellers_eora_community_enabled = false; data.settings.best_sellers_eora_categories_enabled = false; }
    return data;
}
function render(data = context()) { return templates.get('snipplets/best-sellers/index.tpl').render(data); }
function categoryFeed(url, options = {}) {
    const data = context(options);
    const page = Number(url.pathname.match(/\/page\/(\d+)/)?.[1] || url.searchParams.get('page') || 1);
    const start = (page - 1) * 24;
    const last = start + 24 >= data.category_products.length;
    const next = new URL(url);
    if (options.prettyPages) { next.pathname = '/best-sellers/page/' + (page + 1) + '/'; next.searchParams.delete('page'); }
    else next.searchParams.set('page', page + 1);
    return templates.get('snipplets/best-sellers/category-feed.tpl').render({...data, products: data.category_products.slice(start, start + 24), params: {bs_category_feed: '1'}, pages: {current: page, is_last: last, next: last ? '' : next.pathname + next.search}});
}
function validate() {
    const html = render();
    assert.equal((html.match(/data-bs-category=/g) || []).length, 4);
    assert.match(html, /data-bs-category-url="\/best-sellers\/"/);
    assert.doesNotMatch(html, /data-be-product="(?:888|889|890)"/, 'home, campanha antiga e destaques nao sao fontes de produtos');
    assert.equal((html.match(/<template data-bs-community-template=/g) || []).length, 5);
    const communityTemplate = (markup, id) => markup.match(new RegExp('<template data-bs-community-template="' + id + '">([\\s\\S]*?)</template>'))?.[1] || '';
    const generalCommunity = render(context({galleryItems: 5, communityMode: 'general'}));
    assert.equal((generalCommunity.match(/<template data-bs-community-template=/g) || []).length, 1, 'configuracao publicada: cinco fotos gerais e nenhum album de filtro');
    assert.equal((communityTemplate(generalCommunity, 'all').match(/be-gallery__item/g) || []).length, 5);
    const imagelessCommunity = render(context({galleryItems: 5, communityMode: 'imageless'}));
    assert.equal((communityTemplate(imagelessCommunity, 'all').match(/be-gallery__item/g) || []).length, 5);
    assert.equal((communityTemplate(imagelessCommunity, '1').match(/be-gallery__item/g) || []).length, 0, 'entradas sem imagem nao representam fotos validas');
    const mixedCommunity = render(context({galleryItems: 5, communityMode: 'mixed'}));
    assert.equal((communityTemplate(mixedCommunity, '2').match(/be-gallery__item/g) || []).length, 3, 'album valido do filtro continua disponivel como override');
    assert.doesNotMatch(html, /data-bs-disabled-blocks/);
    const feed = categoryFeed(new URL('http://127.0.0.1:4176/best-sellers/?bs_category_feed=1'));
    assert.equal((feed.match(/data-be-product=/g) || []).length, 24);
    assert.match(feed, /data-next="[^\"]*page=2/);
    assert.doesNotMatch(feed, /data-be-product="(?:888|889|890)"/);
    assert.doesNotMatch(render(context({noFilters: true})), /data-bs-filter-form/);
    assert.equal((render(context({macros: 15})).match(/data-bs-category=/g) || []).length, 15);
    render(context({empty: true, macros: 0, noCommunity: true}));
    const names = [...fs.readFileSync(path.join(root, 'config/settings.txt'), 'utf8').matchAll(/^\s*name = (best_sellers_eora_\S+)/gm)].map(match => match[1]);
    assert.equal(new Set(names).size, names.length, 'configuracoes sem nomes duplicados');
    assert.equal(names.filter(name => /^best_sellers_eora_macro_\d+_enabled$/.test(name)).length, 15);
    assert.equal(names.filter(name => /^best_sellers_eora_catalog_\d+_enabled$/.test(name)).length, 0);
    for (const file of ['templates/page.tpl', 'snipplets/templates/page.tpl']) {
        const source = fs.readFileSync(path.join(root, file), 'utf8');
        assert(source.indexOf("include 'snipplets/best-sellers/index.tpl'") < source.indexOf('{% elseif is_on_page %}'), 'rota dedicada precede campanhas genericas');
    }
    for (const file of ['templates/category.tpl', 'snipplets/templates/category.tpl', 'layouts/layout.tpl']) assert.match(fs.readFileSync(path.join(root, file), 'utf8'), /params\.bs_category_feed == '1'/);
    assert.doesNotMatch(fs.readFileSync(path.join(root, 'config/sections.txt'), 'utf8'), /^best_sellers_eora_catalog_/m);
    for (const file of ['layouts/layout.tpl', 'static/js/store.js.tpl']) {
        const source = fs.readFileSync(path.join(root, file), 'utf8');
        const rules = source.match(/\{% set is_best_sellers_eora_page =[^\n]+\n\s*\{% set is_on_campaign_page =[^\n]+/)[0];
        const template = Twig.twig({data: rules + '{% if is_on_campaign_page %}legacy{% else %}dedicated{% endif %}', rethrow: true});
        const variables = {template: 'page', settings: {}, page: {handle: 'best-sellers1'}, page_current_01: 'best-sellers1', is_campaign_01: true};
        assert.equal(template.render(variables).trim(), 'dedicated');
        variables.page.handle = 'campanha'; variables.page_current_01 = 'campanha';
        assert.equal(template.render(variables).trim(), 'legacy');
    }
    console.log('PASS: Twig, fonte exclusiva da categoria Best Sellers, feed de 24 produtos, 15 categorias, painel sem blocos e rotas.');
}
if (process.argv.includes('--check')) validate();
if (process.argv.includes('--serve')) {
    http.createServer(async (req, res) => {
        try {
            const url = new URL(req.url, 'http://127.0.0.1:4176');
            if (url.pathname.startsWith('/static/')) {
                const file = path.resolve(root, '.' + url.pathname);
                if (!file.startsWith(path.join(root, 'static') + path.sep)) { res.writeHead(403); return res.end(); }
                res.setHeader('Content-Type', file.endsWith('.js') ? 'application/javascript' : 'text/css');
                return res.end(fs.readFileSync(file));
            }
            if (/^\/fixtures\/image-\d+\.webp$/.test(url.pathname)) { res.setHeader('Content-Type', 'image/webp'); return res.end(fs.readFileSync(path.join(fixtures, path.basename(url.pathname)))); }
            if (/^\/fixtures\/live\/[a-z-]+\.webp$/.test(url.pathname)) { res.setHeader('Content-Type', 'image/webp'); return res.end(fs.readFileSync(path.join(temp, 'assets', path.basename(url.pathname)))); }
            if (url.pathname === '/favicon.ico') { res.writeHead(204); return res.end(); }
            const isFeed = /^\/best-sellers(?:\/page\/[1-9]\d*)?\/?$/.test(url.pathname);
            const fixtureUrl = isFeed ? new URL(req.headers.referer || 'http://127.0.0.1:4176/') : url;
            const isFixture = Array.from(fixtureUrl.searchParams.keys()).some(key => key.startsWith('fixture_'));
            const options = {macros: Number(fixtureUrl.searchParams.get('fixture_macros') ?? 4), amount: Number(fixtureUrl.searchParams.get('fixture_products') ?? 120), empty: fixtureUrl.searchParams.has('fixture_empty'), noFilters: fixtureUrl.searchParams.has('fixture_no_filters'), noCommunity: fixtureUrl.searchParams.has('fixture_no_community'), prettyPages: fixtureUrl.searchParams.has('fixture_pretty_pages'), galleryItems: Number(fixtureUrl.searchParams.get('fixture_gallery_items') ?? 18), bannerItems: Number(fixtureUrl.searchParams.get('fixture_banner_items') ?? 5), communityMode: fixtureUrl.searchParams.get('fixture_community_mode')};
            res.setHeader('Content-Type', 'text/html; charset=utf-8');
            if (isFeed && isFixture) return res.end(categoryFeed(url, options));
            if (isFeed) {
                // Adaptador somente da previa: a loja publicada ainda usa o feed be.
                // O tema novo usa bs_category_feed, com variantes para filtros de oculos.
                const remote = new URL(url.pathname, 'https://www.eoraeyewear.com');
                remote.searchParams.set('be_category_feed', '1');
                if (url.searchParams.has('page')) remote.searchParams.set('page', url.searchParams.get('page'));
                const response = await fetch(remote, {signal: AbortSignal.timeout(20000)});
                if (!response.ok) throw new Error('Live category HTTP ' + response.status);
                const markup = await response.text();
                const match = markup.match(/<template\b[^>]*\bdata-be-search-feed\b[^>]*>[\s\S]*?<\/template\s*>/i);
                if (!match) throw new Error('Missing live category feed');
                const feed = match[0].replace('data-be-search-feed', 'data-bs-category-feed').replace(/data-next="([^"]*)"/, (_, value) => {
                    if (!value) return 'data-next=""';
                    const next = new URL(value.replace(/&amp;/g, '&'), remote);
                    if (!/^\/best-sellers(?:\/page\/[1-9]\d*)?\/?$/.test(next.pathname)) throw new Error('Invalid live category pagination');
                    next.searchParams.delete('be_category_feed'); next.searchParams.set('bs_category_feed', '1');
                    return 'data-next="' + (next.pathname + next.search).replace(/&/g, '&amp;') + '"';
                });
                return res.end(feed);
            }
            const note = isFixture ? 'Prévia local — imagens e produtos de demonstração' : 'Prévia local — produtos reais da categoria Best Sellers; banners de demonstração';
            res.end('<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Best Sellers Eora — prévia local</title><style>body{margin:0;font-family:Arial,sans-serif}.preview-header{padding:24px;text-align:center;border-bottom:1px solid #eee;font-size:24px;letter-spacing:5px}.preview-note{padding:8px;text-align:center;background:#f5f5f5;font-size:11px}.hidden{display:none}</style></head><body><div class="preview-note">' + note + '</div><header class="preview-header">EORA</header>' + fs.readFileSync(path.join(root, 'snipplets/svg/icons.tpl'), 'utf8') + render(context(options)) + '</body></html>');
        } catch (error) { console.error(error); res.writeHead(500); res.end(String(error)); }
    }).listen(4176, '127.0.0.1', () => console.log('Preview http://127.0.0.1:4176/best-sellers1/'));
}
module.exports = {context, render, categoryFeed, validate};
