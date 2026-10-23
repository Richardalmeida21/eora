// Renderiza os mesmos templates da loja. Os dados abaixo existem apenas na prévia local.
const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
const Twig = require('twig');
const root = path.resolve(__dirname, '../..');
const assets = process.env.SOBRE_PREVIEW_ASSETS || 'C:/Temp/eora-sobre-preview/assets';
const uploaded = new Set();
Twig.extendFilter('static_url', value => uploaded.has(value) ? '/preview-assets/' + value : '/static/' + value);
Twig.extendFilter('has_custom_image', value => uploaded.has(value));
Twig.extendFilter('settings_image_url', value => value);
Twig.extendFilter('product_image_url', value => typeof value === 'string' ? value : value.url);
Twig.extendFilter('money', value => (Number(value) / 100).toLocaleString('pt-BR', {style: 'currency', currency: 'BRL'}));
Twig.extendFilter('is_external', value => /^https?:\/\//.test(value || ''));
const compile = (id, data) => Twig.twig({id, data, rethrow: true, allowInlineIncludes: true});
const files = fs.existsSync(path.join(root, 'snipplets/sobre-eora')) ? fs.readdirSync(path.join(root, 'snipplets/sobre-eora')) : [];
for (const file of files) compile('snipplets/sobre-eora/' + file, fs.readFileSync(path.join(root, 'snipplets/sobre-eora', file), 'utf8'));
for (const file of ['product-name-pt.tpl', 'bolsas-eora/product-card.tpl']) compile('snipplets/' + file, fs.readFileSync(path.join(root, 'snipplets', file), 'utf8'));
// A cópia privada de títulos não faz parte do repositório; o macro real usa o nome do catálogo.
compile('snipplets/product-name-pt-v2-data.tpl', '');
compile('snipplets/product-name-pt-v2-data.backup.tpl', '');
function context() {
    uploaded.clear();
    const settings = {};
    for (const line of fs.readFileSync(path.join(root, 'config/defaults.txt'), 'utf8').split(/\r?\n/)) {
        const match = line.match(/^(sobre_eora_\S+)\s*=\s*(.*)$/);
        if (match) settings[match[1].replace(/_pt$/, '')] = match[2] === '1' ? true : match[2] === '0' ? false : match[2];
    }
    return {settings, page: {handle: 'sobre1', name: 'Sobre', content: '<p>História original da EORA.</p>'}, sections: {}, current_language: {lang: 'pt'}, languages: {pt: {active: true}}};
}
function demoContext() {
    const data = context(), s = data.settings;
    s.sobre_eora_intro_text = 'A EORA nasceu do sonho e da paixão compartilhada por Marcela Carrasco e Filipe Dantas. Uma marca brasileira que une design, estilo e conforto.\n\nUma história que começou com os óculos e segue se transformando, com o mesmo olhar atento a cada detalhe.';
    s.sobre_eora_founders_text = 'Marcela Carrasco e Filipe Dantas uniram suas experiências e o amor pela moda para criar a EORA.\n\nEm 2022, enquanto viviam em Mykonos, começaram a desenvolver uma marca com raízes brasileiras e um olhar para o mundo.\n\n<strong>Design com identidade.</strong> Peças que acompanham diferentes momentos e expressam quem somos.';
    s.sobre_eora_quote_text = 'Uma história feita de <strong>encontros, ideias e vontade de criar.</strong>\nUm olhar para o mundo. <em>Raízes no Brasil.</em>';
    uploaded.add('sobre_eora_founders.jpg');
    for (const kind of ['press', 'sustainability', 'timeline']) {
        s['sobre_eora_' + kind + '_images'] = [];
        for (let i = 1; i <= 5; i++) {
            const key = 'sobre_eora_' + kind + '_' + i;
            uploaded.add(key + '.jpg');
            s[key + '_enabled'] = true;
            s[key + '_title'] = kind === 'timeline' ? ['2022 · O início', '2023 · Novos olhares', '2024 · Novas formas', '2025 · Encontros', '2026 · Próximos capítulos'][i - 1] : kind === 'press' ? ['EORA em pauta', 'Design brasileiro', 'Um olhar para a EORA', 'Nossas criações', 'Novas perspectivas'][i - 1] : ['Escolhas conscientes', 'Peças para acompanhar', 'Um novo olhar', 'Cuidado em cada detalhe', 'Construindo o futuro'][i - 1];
            s[key + '_text'] = kind === 'press' ? 'Espaço de demonstração para a chamada e o veículo da matéria. Substituir pelo conteúdo e link da publicação real.' : kind === 'timeline' ? 'Conte aqui um momento importante da história da EORA. A foto e este texto avançam juntos no carrossel.' : 'Espaço de demonstração para apresentar uma iniciativa da marca. O texto deve ser preenchido com as políticas e ações reais da EORA.';
            s[key + '_link'] = kind === 'press' ? 'https://www.eoraeyewear.com/sobre1/' : '';
            s[key + '_button'] = kind === 'press' ? 'Ler matéria' : '';
            s['sobre_eora_' + kind + '_images'].push({image: key + '.jpg', title: s[key + '_title'], description: s[key + '_text'], link: s[key + '_link'], button: s[key + '_button']});
        }
    }
    s.sobre_eora_values_images = [];
    for (let i = 1; i <= 3; i++) {
        const key = 'sobre_eora_values_' + i;
        uploaded.add(key + '.jpg');
        s[key + '_title'] = ['Identidade', 'Conexão', 'Cuidado'][i - 1];
        s[key + '_text'] = 'Texto ilustrativo para apresentar um dos valores da marca. Este conteúdo poderá ser editado no personalizador.';
        s.sobre_eora_values_images.push({image: key + '.jpg', title: s[key + '_title'], description: s[key + '_text']});
    }
    data.sections.sobre_eora_community = {products: ['VÉRTICE', 'ONYX', 'MINI VÉRTICE', 'LUAR', 'PRISM', 'VÉRTICE'].map((name, i) => ({id: 9000 + i, name, url: 'https://www.eoraeyewear.com/produtos/' + ['vertice', 'onyx', 'minivertice', 'luar', 'prism', 'vertice-detog'][i] + '/', available: true, display_price: true, price: [274990, 64990, 199990, 74990, 64990, 274990][i], tags: [], featured_image: {url: '/preview-assets/product-' + i + '.webp', dimensions: {width: 900, height: 1200}}, other_images: []}))};
    return data;
}
function render(data = context()) {
    const id = 'snipplets/sobre-eora/index.tpl';
    return Twig.twig({ref: id}).render(data);
}
function html(data, mode = 'demo') {
    return '<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Sobre EORA · Prévia</title><style>body{margin:0;color:#111;background:#fff;font-family:Arial,sans-serif}*{box-sizing:border-box}.preview-note{padding:10px 20px;background:#eeeae4;text-align:center;font-size:11px;line-height:1.6}.preview-note a{color:inherit;margin:0 8px}.preview-header{height:100px;display:flex;align-items:center;justify-content:space-between;padding:0 4vw;border-bottom:1px solid #eee}.preview-header span{font-size:11px;letter-spacing:.05em}.preview-logo{font-family:Georgia,serif;font-size:42px;letter-spacing:.17em}.preview-footer{border-top:1px solid #ddd;padding:50px 4vw;font-size:12px;display:flex;justify-content:space-between}@media(max-width:767px){.preview-header{height:76px}.preview-header span{font-size:9px}.preview-logo{font-size:30px}.preview-footer{gap:20px}}</style></head><body><aside class="preview-note"><strong>PRÉVIA LOCAL · ' + (mode === 'demo' ? 'Imagens EORA e textos de demonstração. Press, políticas, datas e seleção de produtos precisam de revisão.' : 'Estado sem materiais cadastrados.') + '</strong><br><a href="/">Página completa</a><a href="/?empty=1">Sem materiais</a></aside><header class="preview-header"><span>SHOP · SOBRE</span><a class="preview-logo" style="color:inherit;text-decoration:none" href="/">EORA</a><span>BRASIL</span></header>' + render(data) + '<footer class="preview-footer"><span>EORA<br>Um olhar para o mundo. Raízes no Brasil.</span><span>Prévia para revisão · sem publicação na loja</span></footer></body></html>';
}
function server(port = 4181) {
    return http.createServer((req, res) => {
        try {
            const url = new URL(req.url, 'http://localhost');
            const base = url.pathname.startsWith('/static/') ? path.join(root, 'static') : assets;
            if (url.pathname.startsWith('/static/') || url.pathname.startsWith('/preview-assets/')) {
                const relative = decodeURIComponent(url.pathname.replace(/^\/(static|preview-assets)\//, ''));
                const mappingFile = path.join(assets, 'mapping.json');
                const mapping = url.pathname.startsWith('/preview-assets/') && fs.existsSync(mappingFile) ? JSON.parse(fs.readFileSync(mappingFile, 'utf8')) : {};
                const target = path.resolve(base, mapping[relative] || relative);
                if (!target.startsWith(path.resolve(base) + path.sep)) { res.writeHead(403); return res.end(); }
                if (!fs.existsSync(target)) { res.setHeader('Content-Type', 'image/svg+xml'); return res.end('<svg xmlns="http://www.w3.org/2000/svg" width="800" height="1000"><rect width="800" height="1000" fill="#eeece8"/></svg>'); }
                res.setHeader('Content-Type', target.endsWith('.css') ? 'text/css' : target.endsWith('.js') ? 'application/javascript' : target.endsWith('.webp') ? 'image/webp' : target.endsWith('.png') ? 'image/png' : 'image/jpeg');
                return res.end(fs.readFileSync(target));
            }
            res.setHeader('Content-Type', 'text/html; charset=utf-8');
            res.end(html(url.searchParams.has('empty') ? context() : demoContext(), url.searchParams.has('empty') ? 'empty' : 'demo'));
        } catch (error) { res.writeHead(500); res.end(error.message); }
    }).listen(port, '127.0.0.1');
}
function exportPreview(target) {
    let source = html(demoContext());
    source = source.replace(/<link rel="stylesheet" href="\/static\/css\/sobre-eora\.css[^"]*">/, '<style>' + fs.readFileSync(path.join(root, 'static/css/sobre-eora.css'), 'utf8') + '</style>');
    source = source.replace(/<script src="\/static\/js\/sobre-eora\.js[^>]*><\/script>/, '<script>' + fs.readFileSync(path.join(root, 'static/js/sobre-eora.js'), 'utf8') + '</script>');
    source = source.replace(/\s+srcset="[^"]*"/g, '');
    const mapping = JSON.parse(fs.readFileSync(path.join(assets, 'mapping.json'), 'utf8'));
    source = source.replace(/\/preview-assets\/[\w.-]+/g, value => {
        const name = value.split('/').pop();
        const file = path.join(assets, mapping[name] || name);
        const mime = file.endsWith('.png') ? 'image/png' : file.endsWith('.webp') ? 'image/webp' : 'image/jpeg';
        return 'data:' + mime + ';base64,' + fs.readFileSync(file).toString('base64');
    });
    source = source.replace('<a href="/">Página completa</a><a href="/?empty=1">Sem materiais</a>', '').replace('href="/"', 'href="#se-title"');
    fs.mkdirSync(path.dirname(target), {recursive: true});
    fs.writeFileSync(target, source);
    console.log('Prévia independente exportada: ' + target);
}
module.exports = {root, assets, context, demoContext, render, html, server, uploaded, compile, exportPreview};
if (require.main === module) {
    const index = process.argv.indexOf('--export');
    if (index >= 0) exportPreview(path.resolve(process.argv[index + 1] || 'sobre-eora-preview.html'));
    else server(Number(process.env.PORT || 4181)).on('listening', function () { console.log('Prévia Sobre EORA: http://localhost:' + this.address().port); });
}
