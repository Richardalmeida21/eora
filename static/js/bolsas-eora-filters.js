(function () {
    'use strict';
    var definitions = [
        {key: 'be_occasion', tag: 'ocasiao', label: 'Ocasi\u00e3o', options: [['trabalho', 'Trabalho'], ['dia-a-dia', 'Dia a dia'], ['noite-eventos', 'Noite e eventos'], ['viagem', 'Viagem']]},
        {key: 'be_size', tag: 'tamanho', label: 'Tamanho', options: [['mini', 'Mini'], ['pequena', 'Pequena'], ['media', 'M\u00e9dia'], ['grande', 'Grande']]},
        {key: 'be_color', tag: 'cor', label: 'Cor', options: [['preto', 'Preto'], ['marrom', 'Marrom'], ['bordo', 'Bord\u00f4'], ['bege-creme', 'Bege / Creme'], ['cinza', 'Cinza'], ['verde', 'Verde'], ['azul', 'Azul'], ['rosa', 'Rosa'], ['outras', 'Outras cores']]},
        {key: 'be_capacity', tag: 'cabe', label: 'O que cabe', options: [['essenciais', 'Essenciais'], ['tablet', 'Tablet'], ['notebook-14', 'Notebook at\u00e9 14\u201d'], ['notebook-16', 'Notebook at\u00e9 16\u201d'], ['notebook-17', 'Notebook at\u00e9 17\u201d']]},
        {key: 'be_texture', tag: 'textura', label: 'Textura', options: [['liso', 'Liso'], ['croco', 'Croco'], ['camurca', 'Camur\u00e7a'], ['verniz', 'Verniz'], ['pony-hair', 'Pony Hair'], ['lizard', 'Lizard'], ['piton', 'P\u00edton'], ['avestruz', 'Avestruz']]},
        {key: 'be_hardware', tag: 'ferragem', label: 'Ferragem', options: [['prata', 'Prata'], ['dourado', 'Dourado'], ['mix', 'Mix de metais']]}
    ];
    function normalize(value) { return String(value || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().trim(); }
    function slug(value) { return normalize(value).replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, ''); }
    function optionValue(definition, value) {
        var key = slug(value);
        var option = definition.options.find(function (item) { return key === item[0] || key === slug(item[1]); });
        return option ? option[0] : key;
    }
    function tagValues(tags, definition) {
        return tags.filter(function (tag) { return tag.indexOf(':') !== -1 && normalize(tag).split(':')[0].trim() === definition.tag; })
            .map(function (tag) { return optionValue(definition, tag.slice(tag.indexOf(':') + 1)); }).filter(Boolean);
    }
    function matches(card, filters, tags) {
        return definitions.every(function (definition) {
            if (!filters[definition.key]) return true;
            var candidates = tagValues(tags, definition);
            return filters[definition.key].split('|').some(function (value) { return candidates.indexOf(value) !== -1; });
        });
    }
    function render(container, selected, tags, append) {
        if (!append) container.replaceChildren();
        definitions.forEach(function (definition) {
            var values = Array.from(new Set(tagValues(tags, definition)));
            if (!values.length) return;
            // O dicionario define apenas rotulos/ordem; as opcoes vem das tags reais.
            var options = definition.options.filter(function (option) { return values.indexOf(option[0]) !== -1; });
            values.filter(function (value) { return !definition.options.some(function (option) { return option[0] === value; }); }).sort().forEach(function (value) {
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
                input.type = 'checkbox'; input.name = definition.key; input.value = option[0];
                input.checked = (selected[definition.key] || '').split('|').indexOf(option[0]) !== -1;
                var span = document.createElement('span'); span.textContent = option[1];
                label.appendChild(input); label.appendChild(span);
                var following = existing.find(function (input) {
                    return options.findIndex(function (item) { return item[0] === input.value; }) > options.indexOf(option);
                });
                fieldset.insertBefore(label, following ? following.parentNode : null);
            });
        });
    }
    function models(select, tags) {
        select.replaceChildren(new Option('Todos os modelos', ''));
        tags.forEach(function (tag) { select.appendChild(new Option(tag, tag)); });
    }
    window.EoraBagFilters = {matches: matches, render: render, models: models};
}());
