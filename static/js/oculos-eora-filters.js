(function () {
    'use strict';

    var definitions = [
        {key: 'oe_shape', tag: 'formato', label: 'Formato', options: [['aviador', 'Aviador'], ['retangular', 'Retangular'], ['quadrado', 'Quadrado'], ['oval', 'Oval'], ['redondo', 'Redondo'], ['cat-eye', 'Cat-eye'], ['geometrico', 'Geométrico']]},
        {key: 'oe_style', tag: 'estilo', label: 'Estilo', options: [['classico', 'Clássico'], ['minimalista', 'Minimalista'], ['statement', 'Statement'], ['esportivo', 'Esportivo']]},
        {key: 'oe_frame_color', tag: 'cor-armacao', label: 'Cor da armação', options: [['preta', 'Preta'], ['tartaruga', 'Tartaruga'], ['marrom', 'Marrom'], ['transparente', 'Transparente'], ['bege-creme', 'Bege / Creme'], ['cinza', 'Cinza'], ['colorido', 'Colorido'], ['dourado', 'Dourado'], ['prata', 'Prata']]},
        {key: 'oe_lens_color', tag: 'cor-lente', label: 'Cor da lente', options: [['cinza', 'Cinza'], ['marrom', 'Marrom'], ['verde', 'Verde'], ['azul', 'Azul'], ['preta', 'Preta'], ['lente-clara', 'Lente clara'], ['transparente', 'Transparente'], ['rosa', 'Rosa'], ['prata', 'Prata']]},
        {key: 'oe_lens_type', tag: 'tipo-lente', label: 'Tipo de lente', options: [['solar', 'Solar'], ['oftalmica-clara', 'Oftálmica / Clara'], ['degrade', 'Degradê'], ['fotocromatica', 'Fotocromática']]},
        {key: 'oe_frame_material', tag: 'material-armacao', label: 'Material da armação', options: [['acetato', 'Acetato'], ['metal', 'Metal'], ['acetato-metal', 'Acetato + Metal']]},
        {key: 'oe_size', tag: 'tamanho', label: 'Tamanho', options: [['pequeno', 'Pequeno'], ['medio', 'Médio'], ['grande-oversized', 'Grande / Oversized']]}
    ];

    function normalize(value) {
        return String(value || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().trim();
    }

    function slug(value) {
        return normalize(value).replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
    }

    function optionValue(definition, value) {
        var key = slug(value);
        if ((definition.key === 'oe_frame_color' || definition.key === 'oe_lens_color') && key === 'preto') key = 'preta';
        if (definition.key === 'oe_lens_color' && key === 'preto-escuro') key = 'preta';
        var option = definition.options.find(function (item) { return key === item[0] || key === slug(item[1]); });
        return option ? option[0] : key;
    }

    function tagPrefix(tag) {
        return slug(String(tag).split(':')[0]).replace(/-(da|de|do)-/g, '-');
    }

    function tagValues(tags, definition) {
        return tags.filter(function (tag) {
            return tag.indexOf(':') !== -1 && tagPrefix(tag) === definition.tag;
        }).map(function (tag) {
            return optionValue(definition, tag.slice(tag.indexOf(':') + 1));
        }).filter(Boolean);
    }

    function normalizeFilters(filters) {
        var result = Object.assign({}, filters);
        definitions.forEach(function (definition) {
            if (result[definition.key]) result[definition.key] = Array.from(new Set(result[definition.key].split('|').map(function (value) {
                return optionValue(definition, value);
            }))).join('|');
        });
        return result;
    }

    // Metal/Lente e o campo combinado usado pelo Luar. Cada linha representa
    // uma variante real: nunca cruzar a armacao de uma com a lente de outra.
    function variantTagSets(card, tags) {
        var variants;
        try { variants = JSON.parse(card.dataset.oeVariants || '[]'); } catch (_) { return [tags]; }
        if (!Array.isArray(variants) || !variants.length) return [tags];
        var hasMetalLens = variants.some(function (variant) {
            return Array.isArray(variant) && variant.some(function (option) { return option && slug(option.name) === 'metal-lente'; });
        });
        if (!hasMetalLens) return [tags];
        return variants.map(function (variant) {
            var option = Array.isArray(variant) && variant.find(function (item) { return item && slug(item.name) === 'metal-lente'; });
            var parts = option ? String(option.value || '').split('/') : [];
            var shared = tags.filter(function (tag) {
                return ['cor-armacao', 'cor-lente', 'tipo-lente'].indexOf(tagPrefix(tag)) === -1;
            });
            if (parts.length !== 2 || !parts[0].trim() || !parts[1].trim()) return shared;
            var frame = normalize(parts[0]).replace(/\s+fosc[oa]$/, '');
            var lens = normalize(parts[1]);
            var photochromic = /\bfotocromatic[oa]\b/.test(lens);
            var lensColor = lens.replace(/\bfotocromatic[oa]\b/g, '').trim();
            shared.push('cor-armacao:' + frame);
            if (lensColor) shared.push('cor-lente:' + lensColor);
            if (photochromic) shared.push('tipo-lente:fotocromatica');
            else tagValues(tags, definitions[4]).filter(function (value) { return value !== 'fotocromatica'; }).forEach(function (value) {
                shared.push('tipo-lente:' + value);
            });
            return shared;
        });
    }

    function facetTags(card, tags) {
        return Array.from(new Set([].concat.apply([], variantTagSets(card, tags))));
    }

    function matches(card, filters, tags) {
        return variantTagSets(card, tags).some(function (variantTags) {
            return definitions.every(function (definition) {
                if (!filters[definition.key]) return true;
                var candidates = tagValues(variantTags, definition);
                return filters[definition.key].split('|').some(function (value) { return candidates.indexOf(optionValue(definition, value)) !== -1; });
            });
        });
    }

    function render(container, selected, tags, append) {
        if (!append) container.replaceChildren();
        definitions.forEach(function (definition) {
            var values = Array.from(new Set(tagValues(tags, definition)));
            if (!values.length) return;
            var options = definition.options.filter(function (option) { return values.indexOf(option[0]) !== -1; });
            values.filter(function (value) {
                return !definition.options.some(function (option) { return option[0] === value; });
            }).sort().forEach(function (value) {
                var label = value.replace(/-/g, ' ');
                options.push([value, label.charAt(0).toUpperCase() + label.slice(1)]);
            });
            var fieldset = container.querySelector('[data-be-facet="' + definition.key + '"]');
            if (!fieldset) {
                fieldset = document.createElement('fieldset');
                fieldset.className = 'be-facet';
                fieldset.dataset.beFacet = definition.key;
                var legend = document.createElement('legend');
                legend.textContent = definition.label;
                fieldset.appendChild(legend);
                var following = Array.from(container.children).find(function (child) {
                    return definitions.findIndex(function (item) { return item.key === child.dataset.beFacet; }) > definitions.indexOf(definition);
                });
                container.insertBefore(fieldset, following || null);
            }
            var existing = Array.from(fieldset.querySelectorAll('input'));
            options.forEach(function (option) {
                if (existing.some(function (input) { return input.value === option[0]; })) return;
                var label = document.createElement('label');
                label.className = 'be-choice';
                var input = document.createElement('input');
                input.type = 'checkbox';
                input.name = definition.key;
                input.value = option[0];
                input.checked = (selected[definition.key] || '').split('|').some(function (value) { return optionValue(definition, value) === option[0]; });
                var span = document.createElement('span');
                span.textContent = option[1];
                label.appendChild(input);
                label.appendChild(span);
                var following = existing.find(function (current) {
                    return options.findIndex(function (item) { return item[0] === current.value; }) > options.indexOf(option);
                });
                fieldset.insertBefore(label, following ? following.parentNode : null);
            });
        });
    }

    function models(select, options) {
        select.replaceChildren(new Option('Todos os modelos', ''));
        options.forEach(function (option) { select.appendChild(new Option(option.label, option.value)); });
    }

    window.EoraEyewearFilters = {matches: matches, render: render, models: models, facetTags: facetTags, normalizeFilters: normalizeFilters};
}());
