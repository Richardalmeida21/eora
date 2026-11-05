'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const publisher = require('../scripts/publish-product-description-performance.cjs');
const root = path.resolve(__dirname, '../..');
const old = 'function prefetchVariationPages(items) { items.forEach(function(item) { fetch(item.href); }); }\n    ';
const prefix = '<h2>Individual text</h2><table><tr><td>Per product</td></tr></table><img src="unique.jpg">';
function fixture(layout = 'vertice') {
  return prefix + '<script><!--\nvar layout=' + JSON.stringify(layout) + ';\n' + old +
    'function reorganizeEoraProductInfo(infoEl) { return infoEl; }\n// Cheguei and stock unchanged\nvar stock = 7;\n// -->\n</script>' +
    '<script>var embedUrl="https://video.example/123"; var html=\'<iframe src="\' + embedUrl + \'" allowfullscreen></iframe>\';</script>' +
    '<script>var unrelated=\'<iframe src="native.mp4"></iframe>\';</script>';
}
function product(id = 11, description = {pt: fixture()}) {
  return {id, description, name: {pt: 'Private name'}, variants: [{id: 99, stock: 7}], tags: 'untouched'};
}
function plan(products = [product()]) { return publisher.buildPlan(products, {root, targetIds: products.map(p => p.id)}); }
test('patches three layouts while preserving per-product HTML, other scripts and every locale', () => {
  for (const layout of ['hobo', 'maxivertice', 'vertice']) {
    const p = product(11, {pt: fixture(layout), en: '<p>English native text</p>', es: fixture(layout)});
    const result = plan([p]);
    assert.equal(result.rows.length, 1);
    const desc = result.rows[0].description;
    assert.equal(desc.en, p.description.en);
    assert.ok(desc.pt.startsWith(prefix));
    assert.ok(desc.pt.includes('metadata[path] = fetch(url.href'));
    assert.ok(desc.pt.includes('data-eora-video-src="\' + embedUrl'));
    assert.ok(desc.pt.includes('loading="lazy"'));
    assert.ok(desc.pt.endsWith('<script>var unrelated=\'<iframe src="native.mp4"></iframe>\';</script>'));
    const removePatch = html => html.replace(/function prefetchVariationPages[\s\S]*?(?=function reorganizeEoraProductInfo)/, '<HELPER>').replace(/<iframe[^>]*embedUrl[^>]*>/g, '<VIDEO>');
    assert.equal(removePatch(desc.pt), removePatch(p.description.pt));
    assert.deepEqual(plan([product(11, desc)]).rows, []);
  }
});
test('skips descriptions with no helper and rejects ambiguous or invalid scripts', () => {
  assert.deepEqual(plan([product(11, {pt: '<p>Native</p>'})]).rows, []);
  assert.throws(() => plan([product(11, {pt: fixture() + fixture()})]), /ambiguous/i);
  assert.throws(() => plan([product(11, {pt: fixture().replace('var stock = 7;', 'var stock = ;')})]), /syntax/i);
  assert.throws(() => plan([product(11, {pt: fixture().replace('function reorganizeEoraProductInfo', 'function wrongMarker')})]), /marker/i);
});
test('requires an explicit, bounded unique product allowlist', () => {
  assert.throws(() => publisher.buildPlan([product()], {root}), /targetIds/);
  assert.throws(() => publisher.buildPlan([product()], {root, targetIds: [12]}), /allowlist/i);
  for (const ids of [[0], [-1], ['11'], [11, 11], Array.from({length: 101}, (_, i) => i + 1)]) {
    assert.throws(() => publisher.buildPlan([], {root, targetIds: ids}), /targetIds/);
  }
});
test('dry run does no requests or backups', async () => {
  const result = await publisher.applyPlan({plan: plan(), request: () => { throw Error('Must not request'); }});
  assert.equal(result.dryRun, true);
  assert.deepEqual(result.results, [{id: 11, status: 'planned'}]);
});
test('apply backs up original descriptions and sends description as the sole payload key', async t => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'eora-description-test-'));
  t.after(() => fs.rmSync(dir, {recursive: true, force: true}));
  const original = product(); let live = structuredClone(original); const calls = [];
  const request = async (method, url, body) => {
    calls.push([method, url, body]);
    if (method === 'PUT') {
      assert.equal(fs.readdirSync(dir).length, 1);
      assert.deepEqual(Object.keys(body), ['description']);
      live.description = body.description;
    }
    return structuredClone(live);
  };
  const result = await publisher.applyPlan({plan: plan(), request, backupDir: dir, apply: true});
  assert.equal(result.results[0].status, 'verified');
  assert.deepEqual(calls.map(c => c[0]), ['GET', 'PUT', 'GET']);
  assert.deepEqual(live.variants, original.variants);
  const backup = JSON.parse(fs.readFileSync(path.join(dir, fs.readdirSync(dir)[0]), 'utf8'));
  assert.deepEqual(backup.description, original.description);
  assert.equal(backup.id, 11);
  assert.equal(backup.originalDescriptionHash, plan().rows[0].originalDescriptionHash);
});
test('fresh edits abort before PUT and verification mismatch stops later writes', async t => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'eora-description-test-'));
  t.after(() => fs.rmSync(dir, {recursive: true, force: true}));
  let puts = 0;
  const edited = await publisher.applyPlan({plan: plan(), backupDir: dir, apply: true, request: async method => {
    if (method === 'PUT') puts++;
    return product(11, {pt: 'Fresh merchant edit'});
  }});
  assert.equal(puts, 0); assert.equal(edited.stopped, true); assert.equal(edited.results[0].status, 'stale');
  const mismatch = await publisher.applyPlan({plan: plan([product(11), product(12)]), backupDir: dir, apply: true, request: async method => {
    if (method === 'PUT') puts++;
    return product();
  }});
  assert.equal(puts, 1); assert.equal(mismatch.stopped, true); assert.equal(mismatch.results[0].status, 'verification-failed');
  assert.ok(mismatch.results[0].backupPath);
});
