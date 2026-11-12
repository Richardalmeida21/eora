// Generates the dedicated editor schema; preserves every existing setting.
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '../..');
const field = (type, props) => '\t' + type + '\n' + Object.entries(props).map(([key, value]) => '\t\t' + key + ' = ' + value).join('\n') + '\n';
const text = (name, description, type = 'text') => field(type, {name, description});
const gallery = (name, description, width = 1600, height = 2000) => field('gallery', {name, gallery_image: description, gallery_link: 'Link opcional', gallery_width: width, gallery_height: height, gallery_more_info: true});
let block = 'Favoritos da Marcela\n' + field('meta', {icon: 'star', advanced: true});
block += field('description', {description: 'Briefing outubro/2026: banner, categorias, catálogo, shop the look e conteúdos da Marcela. Fotos e GIFs: use o primeiro item de cada galeria. Os slots desativados ou incompletos não aparecem. Sem catálogo personalizado, mantém os produtos da Página de campanha 4.'});
block += text('marcela_page_url', 'Página associada (identificador da URL, sem barras)');
block += text('marcela_title', 'Título da página', 'i18n_input');
block += field('collapse', {title: 'Banner principal — foto ou vídeo'});
block += text('marcela_hero_enabled', 'Mostrar banner principal', 'checkbox');
block += gallery('marcela_hero_image', 'Foto desktop — 2400 × 800 px', 2400, 800);
block += gallery('marcela_hero_image_mobile', 'Foto mobile — 1600 × 2000 px (opcional)');
block += text('marcela_hero_video', 'Vídeo desktop — link MP4, Vimeo ou YouTube (opcional)');
block += text('marcela_hero_video_mobile', 'Vídeo mobile — link MP4, Vimeo ou YouTube (opcional)');
block += text('marcela_hero_alt', 'Descrição acessível do banner', 'i18n_input');
block += text('marcela_hero_link', 'Link do banner (opcional)');
block += field('collapse', {title: 'Categorias visuais — até 15 filtros por tag'});
block += text('marcela_categories_title', 'Título das categorias', 'i18n_input');
block += field('description', {description: '3 categorias visíveis no desktop e 2 no celular. Com mais de 3, aparece parte da próxima no desktop. Informe a tag exata dos produtos; ao clicar, o catálogo é filtrado e apenas a descrição escolhida fica aberta.'});
for (let i = 1; i <= 15; i++) {
    const p = 'marcela_category_' + i;
    block += field('title', {title: 'Categoria ' + i});
    block += text(p + '_enabled', 'Ativar categoria ' + i, 'checkbox');
    block += gallery(p + '_image', 'Foto desktop — 2160 × 960 px', 2160, 960);
    block += gallery(p + '_mobile', 'Foto mobile — 1600 × 2000 px (opcional)');
    block += text(p + '_title', 'Nome da categoria', 'i18n_input');
    block += text(p + '_tag', 'Tag exata para filtrar (ex.: luar, prism ou bolsa)');
    block += text(p + '_description', 'Descrição exibida ao selecionar', 'textarea');
    block += text(p + '_link', 'Link ao abrir em nova aba (opcional)');
    block += text(p + '_order', 'Ordem no carrossel (menor número primeiro)');
}
block += field('collapse', {title: 'Catálogo — seleção e ordem dos produtos'});
block += text('marcela_custom_catalog', 'Usar somente o catálogo abaixo (permite deixar a página sem produtos)', 'checkbox');
block += field('description', {description: 'Selecione e arraste os produtos na organização de produtos em destaque: Favoritos da Marcela — Catálogo 1 a 10. Os slots aparecem na ordem de 1 a 10 e os produtos repetidos aparecem uma única vez. Começa com 3 fileiras: 12 produtos no desktop, 6 no celular. Mostrar mais expande outras 3 fileiras.'});
for (let i = 1; i <= 10; i++) block += text('marcela_catalog_' + i + '_enabled', 'Ativar catálogo ' + i, 'checkbox');
block += field('collapse', {title: 'Shop the look — até 10 looks'});
block += text('marcela_looks_title', 'Título da seção de looks', 'i18n_input');
block += field('description', {description: '2 fotos por vez no desktop, com parte da terceira; 1 no celular. Cada foto abre até 2 produtos. Selecione e ordene os produtos em Favoritos da Marcela — Look 1 a 10, na organização de produtos em destaque.'});
for (let i = 1; i <= 10; i++) {
    const p = 'marcela_look_' + i;
    block += field('title', {title: 'Look ' + i});
    block += text(p + '_enabled', 'Ativar look ' + i, 'checkbox');
    block += gallery(p + '_image', 'Foto desktop — 1600 × 1600 px', 1600, 1600);
    block += gallery(p + '_mobile', 'Foto mobile — 1600 × 1600 px (opcional)', 1600, 1600);
    block += text(p + '_title', 'Título do look', 'i18n_input');
    block += text(p + '_button', 'Texto do botão (padrão: Ver o look)', 'i18n_input');
    block += text(p + '_order', 'Ordem no carrossel');
}
block += field('collapse', {title: 'Conteúdos da Marcela — até 10 fotos ou GIFs'});
block += text('marcela_founder_title', 'Título da seção de conteúdos', 'i18n_input');
block += field('description', {description: '4 conteúdos por vez no desktop, com parte do quinto; 1 no celular. Use fotos ou GIFs na proporção 2:3. O arquivo original é usado para preservar a animação do GIF.'});
for (let i = 1; i <= 10; i++) {
    const p = 'marcela_founder_' + i;
    block += field('title', {title: 'Conteúdo ' + i});
    block += text(p + '_enabled', 'Ativar conteúdo ' + i, 'checkbox');
    block += text(p + '_title', 'Título acima da foto ou GIF', 'i18n_input');
    block += gallery(p + '_image', 'Foto ou GIF desktop — 1600 × 2400 px', 1600, 2400);
    block += gallery(p + '_mobile', 'Foto ou GIF mobile (opcional)', 1600, 2400);
    block += text(p + '_description', 'Descrição abaixo da foto ou GIF', 'textarea');
    block += text(p + '_button', 'Texto do botão (padrão: Ver mais)', 'i18n_input');
    block += text(p + '_link', 'Link do botão');
    block += text(p + '_order', 'Ordem no carrossel');
}
const settingsFile = path.join(root, 'config/settings.txt');
const before = fs.readFileSync(settingsFile, 'utf8');
if (/^Favoritos da Marcela$/m.test(before)) {
    const start = /^Favoritos da Marcela$/m.exec(before).index;
    const end = /^Edici[^\r\n]*CSS\r?$/m.exec(before).index;
    fs.writeFileSync(settingsFile, before.slice(0, start) + block + '\n' + before.slice(end));
} else {
    const marker = /^Edici[^\r\n]*CSS\r?$/m.exec(before);
    if (!marker) throw new Error('Editor insertion point not found');
    fs.writeFileSync(settingsFile, before.slice(0, marker.index) + block + '\n' + before.slice(marker.index));
}
const sectionFile = path.join(root, 'config/sections.txt');
if (!/^marcela_catalog_1$/m.test(fs.readFileSync(sectionFile, 'utf8'))) {
    let sections = '\n';
    for (let i = 1; i <= 10; i++) sections += 'marcela_catalog_' + i + '\n\tname = Favoritos da Marcela — Catálogo ' + i + '\n\tdescription = Selecione e arraste os produtos para definir a ordem do catálogo ' + i + '.\n';
    for (let i = 1; i <= 10; i++) sections += 'marcela_look_' + i + '\n\tname = Favoritos da Marcela — Look ' + i + '\n\tdescription = Selecione e ordene até 2 produtos do look ' + i + '.\n';
    fs.appendFileSync(sectionFile, sections);
}
const defaultsFile = path.join(root, 'config/defaults.txt');
if (!/^marcela_page_url\s*=/m.test(fs.readFileSync(defaultsFile, 'utf8'))) {
    fs.appendFileSync(defaultsFile, '\nmarcela_page_url = favoritosdamarcela\nmarcela_title_pt = Favoritos da Marcela\nmarcela_hero_enabled = 1\nmarcela_categories_title_pt = Favoritos da Marcela\nmarcela_looks_title_pt = Shop the look\nmarcela_founder_title_pt = Conteúdos da Marcela\n');
}
console.log('Marcela editor settings, featured-product sections and defaults generated.');
