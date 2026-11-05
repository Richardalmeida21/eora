const assert = require('node:assert/strict');
const {context, render} = require('./menu-harness.cjs');
const normal = render('snipplets/navigation/navigation.tpl', context());
assert.ok(normal.includes('data-menu-revision="1"'), 'the platform-validated revision is now the default menu');
const next = render('snipplets/navigation/navigation.tpl', {...context(), params: {menu_revision: '1'}});
assert.ok(next.includes('data-menu-revision="1"'));
assert.ok(next.includes('reparos-e-consertos'));
assert.ok(next.includes('Consertos'));
const preserved = render('snipplets/navigation/eora-menu.tpl', {...context({empty: true, settings: {eora_menu_previous_images_enabled: true}}), mode: 'mobile'});
// The current warranty fallback intentionally has two photos (Sobre/Garantia).
// Pin each screen so missing photos cannot be hidden by another screen's total.
const expectedPhotos = {primary: 4, shop: 4, favorites: 4, warranty: 2, new: 4, community: 4};
const screens = [...preserved.matchAll(/data-menu-screen="([^"]+)"/g)];
for (const [index, screen] of screens.entries()) {
    const segment = preserved.slice(screen.index, screens[index + 1]?.index);
    assert.equal((segment.match(/<img /g) || []).length, expectedPhotos[screen[1]], screen[1] + ': preserve the current fallback photos');
}
assert.equal((preserved.match(/<img /g) || []).length, 22, 'preserved photos do not depend on removed settings');
assert.ok(preserved.includes('src="/static/menu-preserved-1.webp"'));
assert.ok(!preserved.includes('srcset="/static/menu-preserved-'), 'FTP copies are served directly, without requesting unavailable generated thumbnails');
console.log('PASS isolated revision: stable default, opt-in candidate, links, plural repair label, preserved photos.');
