// Prévia local com os mesmos templates da produção. .github é excluído do FTP.
const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
const Twig = require('twig');
const root = path.resolve(__dirname, '../..');
const assets = 'C:/Temp/eora-sobre-preview/assets';
const read = file => fs.readFileSync(path.join(root, file), 'utf8');
Twig.twig({id: 'snipplets/product-name-pt-v2-data.tpl', data: ''});
Twig.twig({id: 'snipplets/product-name-pt-v2-data.backup.tpl', data: ''});
Twig.extendFilter('static_url', value => value.startsWith('/fixtures/') ? value : '/static/' + value);
Twig.extendFilter('setting_url', value => value);
Twig.extendFilter('settings_image_url', value => value);
Twig.extendFilter('product_image_url', value => typeof value === 'string' ? value : value.url);
Twig.extendFilter('has_custom_image', () => false);
Twig.extendFilter('translate', value => value);
Twig.extendFilter('money', value => (Number(value) / 100).toLocaleString('pt-BR', {style: 'currency', currency: 'BRL'}));
function compile(file) { return Twig.twig({id: file, data: read(file), rethrow: true, allowInlineIncludes: true}); }
compile('snipplets/product-name-pt.tpl');
for (const file of fs.readdirSync(path.join(root, 'snipplets/navigation'))) if (file.startsWith('eora-') || ['navigation.tpl', 'navigation-panel.tpl', 'navigation-nav-list.tpl'].includes(file)) compile('snipplets/navigation/' + file);
if (fs.existsSync(path.join(root, 'snipplets/header/search-discovery.tpl'))) compile('snipplets/header/search-discovery.tpl');
const photos = ['onyx-lifestyle.webp', 'minivertice-lifestyle.webp', 'prism-lifestyle.webp', 'luar-lifestyle.webp'];
function context(options = {}) {
    const settings = {};
    for (const line of read('config/defaults.txt').split(/\r?\n/)) {
        const m = line.match(/^(eora_menu_\S+|eora_search_\S+)\s*=\s*(.*)$/);
        if (m) settings[m[1].replace(/_pt$/, '')] = m[2];
    }
    settings.eora_menu_default_images = photos.map((photo, i) => ({image: '/fixtures/' + photo, title: ['Óculos', 'Bolsas', 'Acessórios', 'New in'][i], link: ['/oculos-eora/', '/bolsas-eora/', '/acessorios/', '/shop/'][i]}));
    const captions = [['Óculos', 'Bolsas', 'Acessórios', 'Cintos'], ['Favoritos da Marcela', 'Gifts', 'Escolhas da Marcela', 'Presentes EORA'], ['Cuidados', 'Conserto', 'Política de troca', 'Garantia EORA'], ['Lançamentos', 'Pré-venda', 'De volta ao estoque', 'New in'], ['Quem usa EORA', 'Press', 'Nossa comunidade', 'EORA em foco']];
    for (const [j, key] of ['shop', 'favorites', 'warranty', 'new', 'community'].entries()) {
        settings['eora_menu_' + key + '_images'] = photos.map((_, i) => ({image: '/fixtures/' + photos[(i + j) % 4], title: captions[j][i], link: ['/oculos-eora/', '/bolsas-eora/', '/acessorios/', '/shop/'][i]}));
    }
    if (options.empty) {
        for (const key of Object.keys(settings)) if (key.endsWith('_images')) settings[key] = [];
        settings.eora_menu_previous_images_enabled = false;
    }
    const navigation = [{name: 'Shop', url: '#', subitems: [{name: 'Óculos de sol', url: '/oculos-eora/'}, {name: 'Bolsas', url: '/bolsas-eora/'}, {name: 'Acessórios', url: '/acessorios/'}]}, {name: 'Sobre', url: '/sobre1/'}];
    const products = Array.from({length: options.products ?? 8}, (_, i) => ({id: i + 1, name: ['Óculos Onyx', 'Bolsa Mini Vértice', 'Óculos Prism', 'Óculos Luar', 'Óculos Onyx', 'Bolsa Mini Vértice', 'Sétimo produto', 'Oitavo produto'][i], url: ['https://www.eoraeyewear.com/produtos/onyx/', 'https://www.eoraeyewear.com/bolsas-eora/', 'https://www.eoraeyewear.com/produtos/prism/', 'https://www.eoraeyewear.com/produtos/luar/'][i % 4], price: 49900 + i * 1000, featured_image: {url: '/fixtures/' + ['onyx-primary.webp', 'minivertice-primary.webp', 'prism-primary.webp', 'luar-primary.webp'][i % 4]}}));
    return {settings: {...settings, ...options.settings}, navigation, sections: {menu_search: {products}}, store: {name: 'EORA'}, mode: 'desktop'};
}
function render(file, data) { return Twig.twig({ref: file}).render(data); }
function documentHtml(options = {}) {
    const data = context(options);
    // Header and modal shells are local fixtures. All menu/search content and behaviors are production code.
    const search = render('snipplets/header/search-discovery.tpl', data);
    return `<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>EORA — Prévia do menu</title>
    <link rel="stylesheet" href="/preview.css"><link rel="stylesheet" href="/static/css/eora-menu.css"><script src="/static/js/eora-menu.js" defer></script></head><body>
    <div class="preview-bar">PRÉVIA LOCAL · MENU EORA <span>OUTUBRO 2026</span></div>
    <header class="js-head-main preview-header"><button class="preview-hamburger" type="button" data-toggle="#nav-hamburger" aria-label="Abrir menu">☰</button><a class="preview-logo" href="/" aria-label="EORA início">EORA</a><div class="preview-navigation">${render('snipplets/navigation/navigation.tpl', data)}</div><div class="preview-utilities"><button type="button" data-toggle="#nav-search" aria-label="Abrir busca"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="10" cy="10" r="6.5" stroke="currentColor" stroke-width="1.3"/><path d="m15 15 6 6" stroke="currentColor" stroke-width="1.3"/></svg></button><a href="https://www.eoraeyewear.com/account/login/" aria-label="Minha conta"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="1.3"/><circle cx="12" cy="9" r="3" stroke="currentColor" stroke-width="1.3"/><path d="M6 19c0-7 12-7 12 0" stroke="currentColor" stroke-width="1.3"/></svg></a><a href="https://www.eoraeyewear.com/cart/" aria-label="Sacola"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M5 8h14l1 13H4L5 8Z" stroke="currentColor" stroke-width="1.3"/><path d="M9 11V6a3 3 0 0 1 6 0v5" stroke="currentColor" stroke-width="1.3"/></svg></a></div></header>
    <main><section class="preview-hero"><img src="/fixtures/onyx-lifestyle.webp" alt="Óculos EORA"><img src="/fixtures/minivertice-lifestyle.webp" alt="Bolsa EORA"><div><span>O SEU OLHAR. A SUA EORA.</span><a href="https://www.eoraeyewear.com/shop/">Conheça as coleções ↗</a></div></section><div class="preview-note">Explore Menu e Buscar no cabeçalho. Reduza a janela para conferir a versão mobile.<br>Fotografias e produtos demonstrativos da EORA. A loja publicada permanece inalterada. <a href="/?empty=1">Ver sem imagens</a> · <a href="/">Ver com imagens</a></div></main>
    <div class="preview-backdrop" hidden></div>
    <div id="nav-hamburger" class="preview-modal" role="dialog" aria-modal="true" aria-label="Menu da loja" hidden><div class="preview-modal-head"><span>Menu</span><button type="button" class="js-modal-close" aria-label="Fechar menu">×</button></div><div class="modal-scrollable-area"><div class="nav-body">${render('snipplets/navigation/navigation-panel.tpl', {...data, primary_links: true})}</div></div></div>
    <div id="nav-search" class="preview-modal" role="dialog" aria-modal="true" aria-label="Busca" hidden><div class="preview-modal-head"><span>Buscar</span><button type="button" class="js-modal-close" aria-label="Fechar busca">×</button></div><div class="modal-body nav-body"><form action="https://www.eoraeyewear.com/search/" class="preview-search-form"><label for="preview-query">O que você procura?</label><div><input id="preview-query" type="search" name="q" placeholder="Buscar na EORA"><button type="submit" aria-label="Buscar">↗</button></div></form>${search}<div class="preview-search-suggestions"><span>SUGESTÕES DE BUSCA</span><a href="https://www.eoraeyewear.com/search/?q=onyx">Onyx ↗</a><a href="https://www.eoraeyewear.com/search/?q=vertice">Vértice ↗</a><a href="https://www.eoraeyewear.com/search/?q=prism">Prism ↗</a></div></div></div>
    <script>
    (function(){function close(){document.querySelectorAll('.preview-modal').forEach(function(m){m.hidden=true;m.classList.remove('modal-show')});document.querySelector('.preview-backdrop').hidden=true;document.body.classList.remove('preview-modal-open')}
    document.addEventListener('click',function(e){var b=e.target.closest('[data-toggle]');if(b){var m=document.querySelector(b.dataset.toggle);m.hidden=false;if(m.id==='nav-hamburger')m.getBoundingClientRect();m.classList.add('modal-show');document.querySelector('.preview-backdrop').hidden=false;document.body.classList.add('preview-modal-open')}if(e.target.closest('.js-modal-close')||e.target.matches('.preview-backdrop'))close()});
    window.addEventListener('load',function(){if(new URLSearchParams(location.search).has('menu')){var mobile=matchMedia('(max-width:1199px)').matches;document.querySelector(mobile?'[data-toggle="#nav-hamburger"]':'[data-menu-toggle]').click()}});})();
    </script></body></html>`;
}
const previewCss = `@import url('https://fonts.googleapis.com/css2?family=Hanken+Grotesk:wght@400;500;600&display=swap');
    :root{--body-font:'Hanken Grotesk',Arial,sans-serif;--heading-font:var(--body-font);--main-background:#fff;--main-foreground:#111;--header-background:#fff;--header-foreground:#111}*{box-sizing:border-box}body{margin:0;color:#111;background:#fff;font-family:var(--body-font)}button,input{font:inherit}button{cursor:pointer}a{color:inherit}.preview-bar{height:30px;display:flex;justify-content:space-between;align-items:center;padding:0 34px;background:#111;color:#fff;font-size:9px;letter-spacing:1.5px}.preview-header{position:sticky;top:0;display:grid;grid-template-columns:180px 1fr 180px;align-items:center;gap:20px;padding:8px 36px;background:#fff;z-index:100;border-bottom:1px solid #eee;min-height:86px}.preview-logo{font-family:Arial,sans-serif;letter-spacing:6px;font-weight:500;font-size:38px;text-decoration:none}.preview-navigation{justify-self:center}.preview-utilities{display:flex;align-items:center;justify-content:flex-end;gap:20px}.preview-utilities button,.preview-hamburger,.preview-modal-head button{background:none;border:0;padding:8px}.preview-utilities a{font-size:25px;text-decoration:none}.preview-hamburger{display:none}.preview-hero{position:relative;display:grid;grid-template-columns:1fr 1fr;height:min(780px,80vh);overflow:hidden;background:#ece9e5}.preview-hero>img{width:100%;height:100%;object-fit:cover;min-width:0}.preview-hero>div{position:absolute;bottom:45px;left:36px;display:flex;flex-direction:column;gap:18px;color:white;text-shadow:0 1px 12px #0008;font-size:12px;letter-spacing:2px}.preview-hero a{font-size:11px;text-underline-offset:5px}.preview-note{padding:28px 36px;font-size:12px;line-height:1.8;color:#666}.preview-modal[hidden],.preview-backdrop[hidden]{display:none!important}.preview-modal{position:fixed;inset:0 auto 0 0;background:white;width:min(460px,100vw);z-index:300;display:flex;flex-direction:column}.preview-backdrop{position:fixed;inset:0;background:#0004;z-index:299}.preview-modal-head{display:flex;justify-content:space-between;align-items:center;padding:16px 24px;min-height:75px;border-bottom:1px solid #eee;font-size:12px;text-transform:uppercase;letter-spacing:1px}.preview-modal-head button{font-size:30px;width:44px;min-height:44px;font-weight:300;line-height:1}.modal-scrollable-area{overflow:auto;min-height:0}.preview-modal-open{overflow:hidden}.preview-modal .modal-body{padding:28px;overflow-y:auto}.preview-search-form label{display:block;margin-bottom:18px;font-size:11px;text-transform:uppercase;letter-spacing:.08em}.preview-search-form>div{display:flex;align-items:center;border-bottom:1px solid #aaa;padding-bottom:8px}.preview-search-form input{min-width:0;flex:1;outline-offset:5px;border:0;font-size:14px;background:white;padding:10px 0}.preview-search-form button{border:0;background:none;font-size:24px}.preview-search-suggestions{display:grid;gap:14px;border-top:1px solid #eee;padding-top:24px;font-size:12px}.preview-search-suggestions>span{font-size:10px;color:#777;margin-bottom:5px}.preview-search-suggestions a{text-decoration:none}
    .preview-header{grid-template-columns:1fr auto 1fr}.preview-logo{grid-column:2;grid-row:1}.preview-navigation{grid-column:1;grid-row:1;justify-self:start}.preview-utilities{grid-column:3;grid-row:1}.preview-utilities svg{display:block}
    @media(max-width:1199px){.preview-header{grid-template-columns:1fr auto 1fr;padding:8px 14px;gap:8px;min-height:74px}.preview-bar{padding:0 16px;font-size:8px}.preview-navigation{display:none}.preview-hamburger{display:block;justify-self:start;grid-column:1;grid-row:1;font-size:22px;padding:5px}.preview-logo{font-size:30px;letter-spacing:5px}.preview-utilities{gap:6px}.preview-utilities a{display:none}.preview-hero{height:75vh;grid-template-columns:1fr}.preview-hero>img:nth-child(2){display:none}.preview-hero>div{bottom:30px;left:24px;font-size:11px}.preview-note{padding:24px;font-size:11px}.preview-modal{width:100vw}.preview-modal .modal-body{padding:24px}}`;
function startServer(port = 4183) {
    const server = http.createServer((req, res) => {
        const url = new URL(req.url, 'http://localhost');
        if (url.pathname === '/') { res.setHeader('content-type', 'text/html; charset=utf-8'); return res.end(documentHtml({empty: url.searchParams.has('empty')})); }
        if (url.pathname === '/preview.css') { res.setHeader('content-type', 'text/css'); return res.end(previewCss); }
        if (!url.pathname.startsWith('/static/') && !url.pathname.startsWith('/fixtures/')) { res.writeHead(302, {location: 'https://www.eoraeyewear.com' + url.pathname + url.search}); return res.end(); }
        const base = url.pathname.startsWith('/fixtures/') ? assets : root;
        const relative = url.pathname.startsWith('/fixtures/') ? url.pathname.slice(10) : url.pathname.slice(1);
        const full = path.resolve(base, decodeURIComponent(relative));
        if (!full.startsWith(path.resolve(base) + path.sep)) { res.statusCode = 403; return res.end(); }
        if (!fs.existsSync(full) || !fs.statSync(full).isFile()) {
            if (!url.pathname.startsWith('/static/') && !url.pathname.startsWith('/fixtures/')) { res.writeHead(302, {location: 'https://www.eoraeyewear.com' + url.pathname + url.search}); return res.end(); }
            res.statusCode = 404; return res.end();
        }
        res.setHeader('content-type', ({'.css': 'text/css', '.js': 'text/javascript', '.webp': 'image/webp', '.png': 'image/png'})[path.extname(full)] || 'application/octet-stream');
        fs.createReadStream(full).pipe(res);
    });
    return new Promise(resolve => server.listen(port, '127.0.0.1', () => resolve(server)));
}
module.exports = {root, read, context, render, assets, documentHtml, startServer};
if (require.main === module) startServer(Number(process.env.PORT) || 4183).then(() => console.log('Prévia do menu: http://localhost:' + (process.env.PORT || 4183) + '/'));
