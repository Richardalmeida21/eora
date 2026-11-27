/* Campanha: mesmas facetas das vitrines EORA, com fonte exclusiva da coleção. */
(function () {
    'use strict';
    var bags = window.EoraBagFilters;
    var eyewear = window.EoraEyewearFilters;
    if (!bags || !eyewear) return;
    function normalize(value) { return String(value || '').trim().toLocaleLowerCase('pt-BR'); }
    function type(card, tags) {
        var name = normalize(card.dataset.beName);
        if (tags.indexOf('bolsa') !== -1 || /^bolsa\b/.test(name)) return 'bag';
        if (tags.indexOf('oculos') !== -1 || /^(óculos|oculos)\b/.test(name)) return 'eyewear';
        return '';
    }
    function bagValues(filters) {
        var values = {};
        Object.keys(filters).forEach(function (key) {
            if (key.indexOf('oe_bag_') === 0) values['be_' + key.slice(7)] = filters[key];
        });
        return bags.normalizeFilters(values);
    }
    function normalizeFilters(filters) {
        var result = eyewear.normalizeFilters(filters);
        var values = bagValues(filters);
        Object.keys(values).forEach(function (key) { result['oe_bag_' + key.slice(3)] = values[key]; });
        return result;
    }
    function matches(card, filters, tags) {
        var productType = type(card, tags);
        var keys = Object.keys(filters).filter(function (key) { return filters[key]; });
        var hasBag = keys.some(function (key) { return key.indexOf('oe_bag_') === 0; });
        var hasEyewear = keys.some(function (key) { return key.indexOf('oe_') === 0 && key.indexOf('oe_bag_') !== 0 && key !== 'oe_model'; });
        if ((hasBag && productType === 'eyewear') || (hasEyewear && productType === 'bag')) return false;
        var price = Number(card.dataset.bePrice);
        if (filters.min_price && price < Number(filters.min_price) * 100) return false;
        if (filters.max_price && price > Number(filters.max_price) * 100) return false;
        return bags.matches(card, bagValues(filters), tags) && eyewear.matches(card, filters, tags);
    }
    function facetTags(card, tags) {
        // Cada registro conserva o tipo e o modelo para não misturar opções
        // de bolsas com opções de óculos ao trocar o modelo no diálogo.
        return [JSON.stringify({type: type(card, tags), tags: tags, eyewear: eyewear.facetTags(card, tags)})];
    }
    function group(container, kind) {
        var found = container.querySelector('[data-campaign-facets="' + kind + '"]');
        if (!found) {
            found = document.createElement('div');
            found.dataset.campaignFacets = kind;
            container.appendChild(found);
        }
        return found;
    }
    function render(container, selected, records, append, model) {
        if (!append) container.replaceChildren();
        var bagTags = new Set();
        var eyewearTags = new Set();
        records.forEach(function (value) {
            var record;
            try { record = JSON.parse(value); } catch (_) { return; }
            if (!record || !Array.isArray(record.tags)) return;
            if (model && record.tags.indexOf(normalize(model)) === -1) return;
            if (record.type !== 'eyewear') record.tags.forEach(function (tag) { bagTags.add(tag); });
            if (record.type !== 'bag') (record.eyewear || record.tags).forEach(function (tag) { eyewearTags.add(tag); });
        });
        var bagGroup = group(container, 'bag');
        // Reutiliza os renderizadores originais e conserva marcações durante
        // o carregamento progressivo das páginas da categoria.
        Array.from(bagGroup.querySelectorAll('input')).forEach(function (input) { input.name = 'be_' + input.name.slice(7); });
        Array.from(bagGroup.querySelectorAll('[data-be-facet]')).forEach(function (field) { field.dataset.beFacet = 'be_' + field.dataset.beFacet.slice(7); });
        bags.render(bagGroup, bagValues(selected), Array.from(bagTags), true);
        Array.from(bagGroup.querySelectorAll('input')).forEach(function (input) { input.name = 'oe_bag_' + input.name.slice(3); });
        Array.from(bagGroup.querySelectorAll('[data-be-facet]')).forEach(function (field) { field.dataset.beFacet = 'oe_bag_' + field.dataset.beFacet.slice(3); });
        eyewear.render(group(container, 'eyewear'), selected, Array.from(eyewearTags), true);
        [['oe_bag_size', 'Tamanho das bolsas'], ['oe_size', 'Tamanho dos óculos']].forEach(function (item) {
            var field = container.querySelector('[data-be-facet="' + item[0] + '"] legend');
            if (field) field.textContent = item[1];
        });
    }
    window.EoraCampaignFilters = {models: eyewear.models, normalizeFilters: normalizeFilters, matches: matches, facetTags: facetTags, render: render};
}());
