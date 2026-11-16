const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');

test('campaign notices are hidden, including dynamically inserted banners', () => {
    const makeNotice = textContent => ({
        textContent,
        classList: {toggle(name, hidden) {
            assert.equal(name, 'eora-retired-campaign-notice');
            this.hidden = hidden;
        }},
    });
    const campaign = makeNotice('10% off com EORABLACK');
    const unrelated = makeNotice('Frete grátis');
    const notices = [campaign, unrelated];
    let update;
    vm.runInNewContext(fs.readFileSync('static/js/black-promotion.js.tpl', 'utf8'), {
        document: {readyState: 'complete', body: {}, querySelectorAll: () => notices},
        MutationObserver: class {constructor(callback) {update = callback;} observe() {}},
        requestAnimationFrame: callback => callback(),
    });
    assert.equal(campaign.classList.hidden, true);
    assert.equal(unrelated.classList.hidden, false);
    const lateBanner = makeNotice('Oferta Black Friday 2026');
    notices.push(lateBanner);
    update([{target: {nodeType: 1, closest: () => null}, addedNodes: [
        {nodeType: 1, matches: () => true},
    ]}]);
    assert.equal(lateBanner.classList.hidden, true);
    lateBanner.textContent = 'Nova coleção';
    update([{target: {nodeType: 1, closest: () => lateBanner}, addedNodes: []}]);
    assert.equal(lateBanner.classList.hidden, false);
});
