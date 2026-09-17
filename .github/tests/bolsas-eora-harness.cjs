// Ambiente local: nao e enviado pelo workflow FTP (.github esta excluido).
const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
const assert = require('node:assert/strict');
const {execFileSync} = require('node:child_process');
const Twig = require('twig');
const root = path.resolve(__dirname, '../..');
const temp = process.env.BE_VALIDATION_DIR || 'C:/Temp/eora-bolsas-validation';
const imageCount = 6;
const customImages = new Set(['bolsas_eora_1_banner.jpg', 'bolsas_eora_1_banner_mobile.jpg', 'bolsas_eora_2_banner.jpg']);
const asset = index => `/fixtures/image-${index % imageCount}.webp`;
Twig.extendFilter('static_url', value => customImages.has(value) ? asset(4) : String(value).startsWith('/fixtures/') ? value : '/static/' + value);
Twig.extendFilter('settings_image_url', value => value);
Twig.extendFilter('product_image_url', value => typeof value === 'string' ? value : value.url);
Twig.extendFilter('has_custom_image', value => customImages.has(value));
Twig.extendFilter('money', value => (Number(value) / 100).toLocaleString('pt-BR', {style: 'currency', currency: 'BRL'}));
Twig.extendFilter('take', (value, params) => (value || []).slice(0, params[0]));
Twig.extendFilter('translate', value => value);
Twig.extendFilter('is_external', value => /^https?:/.test(value || ''));
Twig.extendFunction('component', () => '');

const templates = new Map();
function compile(id, source) {
    const template = Twig.twig({id, data: source.replace(/\r\n/g, '\n'), rethrow: true, allowInlineIncludes: true});
    templates.set(id, template);
    return template;
}
for (const file of fs.readdirSync(path.join(root, 'snipplets/bolsas-eora'))) {
    const id = 'snipplets/bolsas-eora/' + file;
    compile(id, fs.readFileSync(path.join(root, id), 'utf8'));
}
function render(id, data) { return templates.get(id).render(data); }
function platformTag(tag) {
    const value = {attributes: {tag}, eager_where: null, dirty_attributes: []};
    Object.defineProperty(value, 'tag', {value: tag, enumerable: false});
    return value;
}
function product(id, tag = 'maxivertice', overrides = {}) {
    return {
        id, name: 'Bolsa Maxi Vértice ' + id, url: '/produto/' + id,
        available: true, display_price: true, price: 174900 + id * 100, compare_at_price: 0,
        tags: id % 3 === 0 ? [platformTag(tag), platformTag('bolsa')] : id % 2 ? [{tag}, {tag: 'bolsa'}] : [tag, 'bolsa'],
        featured_image: {url: asset(id), alt: 'Bolsa Eora', dimensions: {width: 600, height: 800}},
        other_images: [{url: asset(id + 1)}], brand: 'Eora', color: id % 2 ? 'Preto' : 'Marrom',
        ...overrides,
    };
}
const candidates = Array.from({length: 30}, (_, index) => product(index + 1, index % 5 === 0 ? 'maxivertice-extra' : 'maxivertice'));
const mini = product(101, 'minivertice', {name: 'Bolsa Mini Vértice'});
const settings = {
    bolsas_eora_enabled: true, bolsas_eora_page_url: 'bolsas-eora', bolsas_eora_title: 'Bolsas Eora',
    bolsas_eora_catalog_tag: 'bolsa', bolsas_eora_filters_enabled: true, product_hover: true,
    bolsas_eora_models: Array.from({length: 20}, (_, i) => ({image: asset(i), link: i === 0 ? 'maxivertice' : i === 1 ? 'minivertice' : 'modelo-' + i})),
    bolsas_eora_1_catalog_enabled: true, bolsas_eora_1_split_enabled: true,
    bolsas_eora_1_title: 'Vértice', bolsas_eora_1_subtitle: 'Conheça nossas bolsas', bolsas_eora_1_link: '/vertice',
    bolsas_eora_2_catalog_enabled: false, bolsas_eora_2_split_enabled: false,
    bolsas_eora_2_title: 'Novos olhares', bolsas_eora_2_subtitle: 'Descubra a coleção', bolsas_eora_2_link: '/colecao',
    bolsas_eora_best_enabled: true, bolsas_eora_best_title: 'Best sellers',
    bolsas_eora_community_enabled: true, bolsas_eora_community_title: 'Quem usa Eora',
    bolsas_eora_community_subtitle: 'Nossa comunidade', bolsas_eora_community_link: '/quem-usa',
    bolsas_eora_community: Array.from({length: 20}, (_, i) => ({image: asset(i), title: 'Quem usa ' + (i + 1), link: '/quem-usa/' + i})),
    bolsas_eora_categories_enabled: true,
    bolsas_eora_categories: Array.from({length: 5}, (_, i) => ({image: asset(i), title: ['Vértice', 'Mini Vértice', 'Maxi Vértice', 'Hobo', 'Coleção'][i], description: 'Conheça a coleção', link: '/colecao/' + i})),
};
const sections = {
    bolsas_eora_1_catalog: {products: candidates.slice(0, 18)},
    bolsas_eora_1_split: {products: candidates.slice(0, 4)},
    bolsas_eora_2_catalog: {products: candidates.slice(6, 18)},
    bolsas_eora_2_split: {products: candidates.slice(4, 8)},
    bolsas_eora_best: {products: candidates.slice(0, 8)},
};
const context = () => ({settings, sections, page: {handle: 'bolsas-eora', name: 'Bolsas Eora'}, store: {search_url: '/search/'}});
function feed(url) {
    const query = url.searchParams.get('q');
    const tag = (query || '').replace(/^"|"$/g, '');
    let products = tag === 'bolsa' ? [...candidates, mini] : tag === 'maxivertice' ? candidates : tag === 'minivertice' ? [mini] : [];
    const colors = url.searchParams.get('Cor');
    if (colors) products = products.filter(p => colors.split('|').includes(p.color));
    if (url.searchParams.has('min_price')) products = products.filter(p => p.price >= Number(url.searchParams.get('min_price')) * 100);
    if (url.searchParams.has('max_price')) products = products.filter(p => p.price <= Number(url.searchParams.get('max_price')) * 100);
    if (url.searchParams.get('sort_by') === 'price-descending') products = [...products].sort((a, b) => b.price - a.price);
    const page = Number(url.searchParams.get('page') || 1);
    const last = page * 5 >= products.length;
    const next = new URL(url); next.searchParams.set('page', page + 1);
    const product_filters = [
        {type: 'price', name: 'Preço'},
        {type: 'color', name: 'Cor', key: 'Cor', has_products: true, values: ['Preto', 'Marrom'].map(name => ({name, product_count: 10, selected: Boolean(colors && colors.split('|').includes(name))}))},
        {type: 'brand', name: 'Marca', key: 'brand', has_products: true, values: [{name: 'Eora', product_count: 30}]},
    ];
    return render('snipplets/bolsas-eora/search-feed.tpl', {...context(), query, products: products.slice((page - 1) * 5, page * 5), pages: {current: page, is_last: last, next: last ? '' : next.pathname + next.search}, has_filters_enabled: true, product_filters});
}

function validate() {
    const html = render('snipplets/bolsas-eora/index.tpl', context());
    assert.equal((html.match(/data-be-tag=/g) || []).length, 20, 'mais de 15 filtros');
    assert.equal((html.match(/class="be-gallery__item"/g) || []).length, 25, '20 fotos e 5 categorias');
    assert.match(html, /data-be-dots/);
    assert(!html.includes('data-be-position'), 'controles sem numeracao');
    assert.equal((html.match(/data-be-paged/g) || []).length, 1);
    assert.equal((html.match(/be-split__products/g) || []).length, 1);
    const catalogPosition = html.indexOf('be-catalog-block');
    const bannerPosition = html.indexOf('be-split');
    const bestPosition = html.indexOf('be-best');
    const communityPosition = html.indexOf('be-gallery--community');
    const categoriesPosition = html.indexOf('be-gallery--categories');
    assert(catalogPosition < bannerPosition && bannerPosition < bestPosition && bestPosition < communityPosition && communityPosition < categoriesPosition, 'ordem catalogo, banner, best sellers, quem usa e categorias');
    const response = feed(new URL('http://localhost/search/?q=%22maxivertice%22'));
    assert.match(response, /data-be-search-feed/);
    assert.match(response, /data-next=.*page=2/);
    assert(!response.includes('eager_where'), 'feed serializa os textos das tags sem os detalhes internos da plataforma');
    assert.equal(render('snipplets/bolsas-eora/search-feed.tpl', {...context(), query: 'oculos'}).trim(), '', 'busca comum sem feed');
    assert.match(feed(new URL('http://localhost/search/?q=%22modelo-3%22')), /data-last="1"/);
    // Mesmo template anterior e mesmas rotas quando a campanha estiver desligada.
    const currentSource = fs.readFileSync(path.join(root, 'templates/page.tpl'), 'utf8');
    const oldSource = execFileSync('git', ['show', 'HEAD:templates/page.tpl'], {cwd: root, encoding: 'utf8'});
    const includes = [...new Set([...oldSource.matchAll(/include\s+'([^']+)'/g)].map(m => m[1]))];
    includes.filter(id => !id.startsWith('snipplets/bolsas-eora/')).forEach(id => compile(id, 'LEGACY:' + id));
    const old = compile('legacy-page', oldSource);
    const current = compile('current-page', currentSource);
    const configured = {gift_guide_page_url: 'presentes', behind_lens_page_url: 'lentes'};
    for (let i = 1; i <= 10; i++) configured['campaign_page_' + String(i).padStart(2, '0') + '_url'] = 'campanha-' + i;
    const handles = ['sobre', 'bolsas-eora', 'presentes', 'lentes', 'garantia-eora', ...Array.from({length: 10}, (_, i) => 'campanha-' + (i + 1))];
    for (const enabled of [false, true]) for (const handle of handles) {
        const data = {settings: {...configured, bolsas_eora_enabled: enabled}, page: {handle, name: 'Teste', content: 'Conteudo'}};
        if (handle !== 'bolsas-eora') assert.equal(current.render(data), old.render(data), handle + ' preserved');
    }
    // Uma URL que ja pertença a outra campanha conserva a precedencia anterior.
    for (const handle of ['presentes', 'lentes', 'garantia-eora', 'campanha-1']) {
        const data = {settings: {...configured, bolsas_eora_enabled: true, bolsas_eora_page_url: handle}, page: {handle}};
        assert.equal(current.render(data), old.render(data));
    }
    assert.match(current.render(context()), /data-be-page/);
    assert.equal(currentSource, fs.readFileSync(path.join(root, 'snipplets/templates/page.tpl'), 'utf8'));
    const config = fs.readFileSync(path.join(root, 'config/settings.txt'), 'utf8').replace(/\r\n/g, '\n');
    const newConfig = config.slice(config.indexOf('\nBolsas Eora\n'), config.indexOf('\nEdición avanzada de CSS'));
    assert(!newConfig.includes('gallery_max'));
    assert(!newConfig.includes('\u00a0'));
    const names = [...newConfig.matchAll(/name = (bolsas_eora_\w+)/g)].map(m => m[1]);
    assert(names.length > 60);
    assert.equal(new Set(names).size, names.length, 'chaves exclusivas');
    const bannerOriginals = [...newConfig.matchAll(/original = (bolsas_eora_\w+\.jpg)/g)].map(m => m[1]);
    assert.equal(bannerOriginals.length, 20);
    bannerOriginals.forEach(name => {
        const bytes = fs.readFileSync(path.join(root, 'static', name));
        assert.equal(bytes.readUInt16BE(0), 0xffd8, name + ' possui arquivo JPEG base valido');
    });
    const configuredImages = [...customImages];
    customImages.clear();
    const withoutUploads = render('snipplets/bolsas-eora/index.tpl', context());
    configuredImages.forEach(name => customImages.add(name));
    assert(!withoutUploads.includes('class="be-split'), 'imagens-base nao exibem banners sem upload');
    assert(fs.existsSync(path.join(root, 'static/js/instatheme.js')), 'script no caminho esperado pelo editor');
    console.log('PASS: Twig parse/render, 20 modelos, 20 fotos, feed/paginacao, 32 rotas legadas, precedencia e configuracao.');
}

if (process.argv.includes('--check')) validate();
if (process.argv.includes('--serve')) {
    const port = Number(process.env.PORT || 4175);
    http.createServer((req, res) => {
        try {
            const url = new URL(req.url, 'http://127.0.0.1:' + port);
            if (url.pathname.startsWith('/static/')) {
                const file = path.resolve(root, '.' + url.pathname);
                if (!file.startsWith(path.join(root, 'static') + path.sep)) { res.writeHead(403); return res.end(); }
                res.setHeader('Content-Type', file.endsWith('.js') ? 'application/javascript' : 'text/css');
                return res.end(fs.readFileSync(file));
            }
            if (/^\/fixtures\/image-\d+\.webp$/.test(url.pathname)) {
                res.setHeader('Content-Type', 'image/webp');
                return res.end(fs.readFileSync(path.join(temp, 'assets', path.basename(url.pathname))));
            }
            if (url.pathname.startsWith('/search')) { res.setHeader('Content-Type', 'text/html; charset=utf-8'); return res.end(feed(url)); }
            if (url.pathname === '/favicon.ico') { res.writeHead(204); return res.end(); }
            const html = render('snipplets/bolsas-eora/index.tpl', context());
            res.setHeader('Content-Type', 'text/html; charset=utf-8');
            res.end('<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Bolsas Eora — prévia local</title><style>body{margin:0;font-family:Arial,sans-serif}.preview-header{padding:24px;text-align:center;border-bottom:1px solid #eee;font-size:24px;letter-spacing:5px}.preview-note{padding:8px;text-align:center;background:#f5f5f5;font-size:11px}.hidden{display:none}</style></head><body><div class="preview-note">Prévia local — produtos e configurações de demonstração</div><header class="preview-header">EORA</header>' + fs.readFileSync(path.join(root, 'snipplets/svg/icons.tpl'), 'utf8') + html + '</body></html>');
        } catch (error) { console.error(error); res.writeHead(500); res.end(String(error)); }
    }).listen(port, '127.0.0.1', () => console.log('Preview http://127.0.0.1:' + port));
}
module.exports = {context, feed, render, product, validate};
