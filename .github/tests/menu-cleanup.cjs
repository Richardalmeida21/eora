const assert = require('node:assert/strict');
const {context, render, read} = require('./menu-harness.cjs');
const names = [];
for (const line of read('config/settings.txt').split(/\r?\n/)) {
    const field = line.match(/^\t\t(?:name|original)\s*=\s*(.+?)\s*$/);
    if (field) names.push(field[1]);
}
assert.equal(names.filter(name => /^(header_menu_image|header_menu_imagem|desktop_menu_images|custom_menu_)/.test(name)).length, 0, 'editor must only expose the consolidated menu controls');
for (const name of ['head_transparent', 'logo_position_mobile', 'logo_position_desktop', 'ad_bar', 'header_placeholder', 'header_sugestoes_busca', 'header_has_actions', 'eora_menu_default_images', 'eora_menu_shop_images']) assert.ok(names.includes(name), 'preserve ' + name);
const html = render('snipplets/navigation/navigation.tpl', context());
assert.match(html, /href="\/best-sellers1\/\?bs_filters=%7B%22bs_new%22%3A%221%22%7D"/);
assert.match(html, /href="\/search\/\?eora_preorder=1"/);
assert.match(html, /href="\/garantia-eora\/#reparos-e-consertos"/);
assert.ok(html.includes('Consertos'));
console.log('PASS cleanup: only consolidated fields, header functions retained, New in/preorder/repairs destinations.');
