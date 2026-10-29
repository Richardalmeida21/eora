const assert = require('node:assert/strict');
const Twig = require('twig');
const {read, context} = require('./menu-harness.cjs');
Twig.twig({id: 'snipplets/pre-venda.tpl', data: read('snipplets/pre-venda.tpl'), allowInlineIncludes: true, rethrow: true});
const search = Twig.twig({data: read('templates/search.tpl').replace(/\{% paginate by \d+ %\}/g, ''), allowInlineIncludes: true, rethrow: true});
const page = Twig.twig({data: read('templates/page.tpl'), allowInlineIncludes: true, rethrow: true});
const data = {...context(), params: {eora_preorder: '1'}, page: {handle: 'pre-venda'}};
for (const template of [search, page]) {
    const html = template.render(data);
    assert.match(html, /<h1[^>]*>Pré-venda<\/h1>/);
    assert.ok(html.includes('Os produtos de pré-venda serão disponibilizados aqui em breve.'));
    assert.ok(!html.includes('category-body'), 'preorder is a dedicated notice, without an empty search results screen');
}
const guarantee = Twig.twig({data: read('snipplets/garantia-eora.tpl'), allowInlineIncludes: true, rethrow: true});
const repairs = guarantee.render({settings: {garantia_repair_show: true}});
assert.match(repairs, /id="reparos-e-consertos"/);
assert.ok(repairs.includes('REPAROS E CONSERTOS'));
assert.match(repairs, /href="https:\/\/api\.whatsapp\.com\/send\//);
console.log('PASS preorder/repairs: dedicated notice on working search/native routes; repairs anchor and existing WhatsApp CTA.');
