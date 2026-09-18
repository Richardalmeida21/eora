const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const Twig = require('twig');
const root = path.resolve(__dirname, '../..');
const read = file => fs.readFileSync(path.join(root, file), 'utf8');

// Check the complete editor schema, including fields outside Bolsas Eora.
const blocks = [];
let block;
for (const [index, line] of read('config/settings.txt').split(/\r?\n/).entries()) {
    if (/^\S/.test(line)) block = undefined;
    if (/^\t[^\t\s]/.test(line)) {
        block = {type: line.trim(), line: index + 1, props: {}};
        blocks.push(block);
    } else if (block && /^\t\t[^\t\s]/.test(line)) {
        const match = line.trim().match(/^([^=]+?)\s*=\s*(.*)$/);
        if (match) block.props[match[1].trim()] = match[2];
    }
}
const namedTypes = new Set(['gallery', 'text', 'checkbox', 'color', 'font', 'i18n_input', 'dropdown', 'css_code', 'textarea', 'range_number', 'menu', 'section_order']);
const names = new Set();
for (const field of blocks) {
    const context = `${field.type}, line ${field.line}`;
    if (field.type === 'image') assert.ok(field.props.original, `Missing image original: ${context}`);
    if (namedTypes.has(field.type)) {
        assert.ok(field.props.name, `Missing field identifier: ${context}`);
        assert.ok(!names.has(field.props.name), `Duplicate identifier: ${field.props.name}`);
        names.add(field.props.name);
    }
}

let customImages = new Set();
Twig.extendFilter('has_custom_image', filename => customImages.has(filename));
Twig.extendFilter('static_url', filename => `/static/${filename}`);
Twig.extendFilter('settings_image_url', url => url);
Twig.extendFilter('setting_url', url => url);
const cases = [
    {file: 'snipplets/home/home-banner-duplo.tpl', enabled: 'banner_duplo_show', images: ['banner_duplo_1_image', 'banner_duplo_2_image']},
    {file: 'snipplets/home/home-banner-video-botao.tpl', enabled: 'banner_video_botao_show', images: ['banner_video_botao_image'], video: 'banner_video_botao_embed'},
    {file: 'snipplets/product/product-banner-video-botao.tpl', enabled: 'product_banner_show', images: ['product_banner_image'], video: 'product_banner_video'},
];
for (const test of cases) {
    const template = Twig.twig({data: read(test.file), rethrow: true});
    const render = settings => template.render({settings, store: {name: 'Eora'}});
    customImages = new Set();
    assert.doesNotMatch(render({[test.enabled]: true}), /<section\b/, 'Empty placeholders must not create a storefront banner');
    const legacy = Object.fromEntries(test.images.map(name => [name, `${name}-legacy.jpg`]));
    const legacyHtml = render({...legacy, [test.enabled]: true});
    for (const name of test.images) assert.ok(legacyHtml.includes(`/static/${name}-legacy.jpg`), 'Retain any existing legacy image values');
    for (const name of test.images) {
        const original = `${name}.png`;
        assert.ok(blocks.some(b => b.type === 'image' && b.props.original === original));
        assert.ok(fs.existsSync(path.join(root, 'static', original)), `Missing original asset: ${original}`);
        customImages = new Set([original]);
        const html = render({[test.enabled]: true});
        assert.ok(html.includes(`data-src="/static/${original}"`), 'Render a newly uploaded image without requiring settings.name');
        assert.ok(render({...legacy, [test.enabled]: true}).includes(`data-src="/static/${original}"`), 'New upload wins over a legacy value');
        assert.doesNotMatch(render({[test.enabled]: false}), /<section\b/, 'Respect disabled sections');
    }
    if (test.video) {
        const html = render({[test.enabled]: true, [test.video]: 'https://www.youtube.com/watch?v=example123'});
        assert.match(html, /data-platform="youtube"/);
        assert.match(html, /data-video-id="example123"/);
        assert.doesNotMatch(html, /data-src="\/static\//, 'Video continues to take precedence over the fallback image');
    }
}
console.log(`PASS: ${names.size} named fields, ${blocks.filter(b => b.type === 'image').length} image fields; empty, legacy, uploaded, disabled and video banner rendering.`);
