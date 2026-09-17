(function () {
    'use strict';

    function init() {
        var root = document.querySelector('[data-be-page]');
        if (!root || root.dataset.beReady) return;
        root.dataset.beReady = '1';
        var mobile = window.matchMedia('(max-width: 767px)');
        var reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
        var normalize = function (value) { return String(value || '').trim().toLocaleLowerCase('pt-BR'); };
        var all = function (selector, parent) { return Array.from((parent || root).querySelectorAll(selector)); };
        var one = function (selector) { return root.querySelector(selector); };

        function updateDots(controls, count, active, onSelect) {
            var dots = controls.querySelector('[data-be-dots]');
            if (dots.children.length !== count) {
                dots.replaceChildren();
                for (var index = 0; index < count; index++) {
                    var dot = document.createElement('button');
                    dot.type = 'button';
                    dot.className = 'be-dot';
                    dot.setAttribute('aria-label', 'Ir para página ' + (index + 1));
                    dot.addEventListener('click', (function (page) { return function () { onSelect(page); }; }(index)));
                    dots.appendChild(dot);
                }
            }
            all('.be-dot', dots).forEach(function (dot, index) {
                if (index === active) dot.setAttribute('aria-current', 'true');
                else dot.removeAttribute('aria-current');
            });
            var current = dots.children[active];
            if (current) dots.scrollLeft = Math.max(0, current.offsetLeft - dots.clientWidth / 2);
        }

        // Rolagem nativa: funciona por toque, teclado e botoes, sem Swiper global.
        all('[data-be-carousel]').forEach(function (section) {
            var track = section.querySelector('[data-be-track]');
            var controls = section.querySelector('[data-be-controls]');
            var previous = controls.querySelector('[data-be-prev]');
            var next = controls.querySelector('[data-be-next]');
            var currentPage = 0;
            function goTo(target, immediate) {
                var visible = Math.max(1, parseFloat(getComputedStyle(section).getPropertyValue('--be-visible')) || 4);
                var count = Math.ceil(track.children.length / visible);
                var page = Math.max(0, Math.min(count - 1, target));
                var maximum = Math.max(0, track.scrollWidth - track.clientWidth);
                var start = 0;
                var left = count > 1 ? start + (maximum - start) * page / (count - 1) : start;
                track.scrollTo({left: left, behavior: immediate || reducedMotion.matches ? 'auto' : 'smooth'});
            }
            function update() {
                var overflow = track.scrollWidth - track.clientWidth > 2;
                controls.hidden = !overflow;
                section.classList.toggle('be-models--overflow', section.classList.contains('be-models') && track.children.length > 4);
                var visible = Math.max(1, parseFloat(getComputedStyle(section).getPropertyValue('--be-visible')) || 4);
                var count = Math.ceil(track.children.length / visible);
                var maximum = Math.max(0, track.scrollWidth - track.clientWidth);
                var start = 0;
                var range = maximum - start;
                currentPage = range && count > 1 ? Math.max(0, Math.min(count - 1, Math.round((track.scrollLeft - start) / range * (count - 1)))) : 0;
                previous.disabled = currentPage === 0;
                next.disabled = currentPage >= count - 1;
                updateDots(controls, count, currentPage, goTo);
            }
            previous.addEventListener('click', function () { goTo(currentPage - 1); });
            next.addEventListener('click', function () { goTo(currentPage + 1); });
            track.addEventListener('scroll', update, {passive: true});
            if (window.ResizeObserver) new ResizeObserver(update).observe(track);
            else window.addEventListener('resize', update, {passive: true});
            update();
        });

        // Cada grade conserva todos os produtos selecionados no painel.
        all('[data-be-paged]').forEach(function (section) {
            var items = Array.from(section.querySelector('[data-be-page-items]').children);
            var controls = section.querySelector('[data-be-controls]');
            var page = 0;
            function render() {
                var size = mobile.matches ? 6 : 12;
                var count = Math.ceil(items.length / size);
                page = Math.min(page, count - 1);
                items.forEach(function (item, index) { item.hidden = index < page * size || index >= (page + 1) * size; });
                controls.hidden = count <= 1;
                controls.querySelector('[data-be-prev]').disabled = page === 0;
                controls.querySelector('[data-be-next]').disabled = page >= count - 1;
                updateDots(controls, count, page, function (target) { page = target; render(); });
            }
            controls.querySelector('[data-be-prev]').addEventListener('click', function () { page--; render(); section.scrollIntoView({block: 'start', behavior: 'auto'}); });
            controls.querySelector('[data-be-next]').addEventListener('click', function () { page++; render(); section.scrollIntoView({block: 'start', behavior: 'auto'}); });
            mobile.addEventListener('change', render);
            render();
        });

        var models = all('[data-be-tag]');
        var catalogTag = '';
        var searchBase = new URL(root.dataset.searchUrl, window.location.href);
        if (searchBase.origin !== window.location.origin) return;
        var grid = one('[data-be-results-grid]');
        var results = one('[data-be-results]');
        var status = one('[data-be-status]');
        var more = one('[data-be-more]');
        var dialog = one('#be-filter-dialog');
        var form = one('[data-be-filter-form]');
        var facetCache = new Map();
        var facetRequest = null;
        var facetVersion = 0;
        var productRequest = null;
        var version = 0;
        var state;
        var reserved = ['q', 'page', 'results_only', 'sort_by', 'be_model', 'preview', '__proto__', 'constructor', 'prototype'];

        function selectedModel(value) {
            var model = models.find(function (item) { return normalize(item.dataset.beTag) === normalize(value); });
            return model ? model.dataset.beTag : '';
        }
        function makeSearchUrl(tag, filters, sort) {
            var url = new URL(searchBase);
            url.search = '';
            url.searchParams.set('q', '"' + tag + '"');
            var preview = new URL(window.location.href).searchParams.get('preview');
            if (preview) url.searchParams.set('preview', preview);
            Object.keys(filters).forEach(function (key) {
                if (reserved.indexOf(key) === -1 && filters[key]) url.searchParams.set(key, filters[key]);
            });
            if (sort && sort !== 'user') url.searchParams.set('sort_by', sort);
            return url;
        }
        function checkedUrl(value, base) {
            var url = new URL(value, base || searchBase);
            var prefix = searchBase.pathname.replace(/\/$/, '');
            if (url.origin !== searchBase.origin || (url.pathname.replace(/\/$/, '') !== prefix && !url.pathname.startsWith(prefix + '/'))) throw new Error('Invalid search URL');
            return url;
        }
        async function fetchFeed(url, controller, tag) {
            var timeout = setTimeout(function () { controller.abort(); }, 20000);
            try {
                var response = await fetch(checkedUrl(url), {credentials: 'same-origin', signal: controller.signal, headers: {'Accept': 'text/html'}});
                if (!response.ok) throw new Error('Search HTTP ' + response.status);
                checkedUrl(response.url || url);
                var html = await response.text();
                var doc = new DOMParser().parseFromString(html, 'text/html');
                var feed = doc.querySelector('template[data-be-search-feed]');
                if (!feed || normalize(feed.dataset.tag) !== normalize(tag)) throw new Error('Missing campaign feed');
                return feed;
            } finally { clearTimeout(timeout); }
        }
        function tagsFor(card) {
            var tags;
            try { tags = JSON.parse(card.dataset.beTags || '[]'); } catch (_) { return []; }
            if (typeof tags === 'string') tags = tags.split(',');
            if (!Array.isArray(tags)) tags = Object.values(tags || {});
            return tags.map(function (tag) { return normalize(typeof tag === 'string' ? tag : tag.tag); });
        }
        function remember() {
            var url = new URL(window.location.href);
            ['tag', 'be_filters', 'be_sort'].forEach(function (key) { url.searchParams.delete(key); });
            if (state.model) url.searchParams.set('tag', state.model);
            if (Object.keys(state.filters).length) url.searchParams.set('be_filters', JSON.stringify(state.filters));
            if (state.sort !== 'user') url.searchParams.set('be_sort', state.sort);
            if (url.href !== window.location.href) window.history.pushState(null, '', url);
        }
        function showStatus(error) {
            var count = grid.children.length;
            if (error) status.textContent = 'Não foi possível carregar os produtos. Tente novamente.';
            else if (state.loading) status.textContent = 'Carregando produtos…';
            else if (!count && !state.next && !state.buffer.length) status.textContent = 'Nenhum produto encontrado com estes filtros.';
            else if (!count) status.textContent = 'Ainda não encontramos produtos nesta parte da busca. Continue para ver os próximos resultados.';
            else status.textContent = count + (count === 1 ? ' produto' : ' produtos') + (state.next || state.buffer.length ? ' carregados' : ' encontrados');
            more.hidden = !error && !state.next && !state.buffer.length;
            more.disabled = state.loading;
            more.textContent = error ? 'Tentar novamente' : 'Mostrar mais produtos';
            results.setAttribute('aria-busy', state.loading ? 'true' : 'false');
        }
        async function loadMore() {
            if (!state || state.loading) return;
            var run = version;
            var current = state;
            current.loading = true;
            showStatus();
            var size = mobile.matches ? 6 : 12;
            var requests = 0;
            var error = false;
            try {
                // No maximo 3 requisicoes sequenciais por acao. Nunca varre a loja inteira.
                while (current.buffer.length < size && current.next && requests < 3) {
                    var url = checkedUrl(current.next);
                    if (current.visited.has(url.href)) throw new Error('Repeated search page');
                    var controller = new AbortController();
                    productRequest = controller;
                    var feed = await fetchFeed(url, controller, current.tag);
                    if (run !== version) return;
                    var next = feed.dataset.last === '1' ? '' : feed.dataset.next;
                    if (feed.dataset.last !== '1' && !next) throw new Error('Missing pagination');
                    if (next) {
                        next = checkedUrl(next, url);
                        // Nao deixa a paginacao perder a tag ou os filtros da consulta.
                        url.searchParams.forEach(function (value, key) { if (key !== 'page' && key !== 'results_only') next.searchParams.set(key, value); });
                        next = next.href;
                    }
                    all('[data-be-product]', feed.content).forEach(function (card) {
                        var id = card.dataset.beProduct;
                        if (!current.ids.has(id) && tagsFor(card).indexOf(normalize(current.tag)) !== -1) {
                            current.ids.add(id);
                            current.buffer.push(card);
                        }
                    });
                    current.visited.add(url.href);
                    current.next = next;
                    requests++;
                }
                if (run !== version) return;
                current.buffer.splice(0, size).forEach(function (card) { grid.appendChild(document.importNode(card, true)); });
            } catch (_) {
                if (run !== version) return;
                error = true;
            } finally {
                if (run === version) { current.loading = false; showStatus(error); }
            }
        }
        function activate(model, filters, sort, save) {
            version++;
            if (productRequest) productRequest.abort();
            model = selectedModel(model);
            filters = filters || {};
            sort = sort || 'user';
            var active = Boolean(model || Object.keys(filters).length || sort !== 'user');
            state = {model: model, tag: model || catalogTag, filters: filters, sort: sort, next: '', buffer: [], ids: new Set(), visited: new Set(), loading: false};
            // Ao filtrar, troca somente as grades do catálogo. Os banners continuam
            // logo depois dos resultados, antes de Best sellers e das galerias.
            all('.be-catalog-block').forEach(function (section) { section.hidden = active; });
            one('[data-be-toolbar]').hidden = !active;
            results.hidden = !active;
            grid.replaceChildren();
            more.hidden = true;
            models.forEach(function (item) { if (item.dataset.beTag === model) item.setAttribute('aria-current', 'true'); else item.removeAttribute('aria-current'); });
            one('[data-be-sort]').value = sort;
            one('[data-be-result-title]').textContent = model || 'Todas as bolsas';
            if (save) remember();
            if (active && state.tag) { state.next = makeSearchUrl(state.tag, filters, sort).href; loadMore(); }
            else if (active) status.textContent = 'Escolha um modelo para ver os produtos.';
        }
        function fromLocation() {
            var url = new URL(window.location.href);
            var filters = {};
            try {
                var parsed = JSON.parse(url.searchParams.get('be_filters') || '{}');
                Object.keys(parsed || {}).forEach(function (key) { if (reserved.indexOf(key) === -1 && typeof parsed[key] === 'string') Object.defineProperty(filters, key, {value: parsed[key], enumerable: true}); });
            } catch (_) { /* URL incompleta: volta ao catalogo sem filtros adicionais. */ }
            var sort = url.searchParams.get('be_sort') || 'user';
            if (!all('option', one('[data-be-sort]')).some(function (option) { return option.value === sort; })) sort = 'user';
            activate(url.searchParams.get('tag'), filters, sort, false);
        }
        models.forEach(function (model) {
            model.addEventListener('click', function (event) {
                if (event.ctrlKey || event.metaKey || event.shiftKey || event.altKey || event.button !== 0) return;
                event.preventDefault();
                activate(model.dataset.beTag, {}, 'user', true);
            });
        });
        one('[data-be-reset]').addEventListener('click', function () { activate('', {}, 'user', true); });
        more.addEventListener('click', loadMore);
        one('[data-be-sort]').addEventListener('change', function (event) { activate(state.model, state.filters, event.target.value, true); });
        window.addEventListener('popstate', fromLocation);

        if (dialog && typeof dialog.showModal === 'function' && (catalogTag || models.length)) {
            var opener = one('[data-be-open-filters]');
            var facetStatus = one('[data-be-facet-status]');
            var facets = one('[data-be-facets]');
            var modelSelect = form.elements.be_model;
            var submit = form.querySelector('[type="submit"]');
            opener.hidden = false;
            async function loadFacets(model, selected) {
                var run = ++facetVersion;
                if (facetRequest) facetRequest.abort();
                var tag = model || catalogTag;
                facets.replaceChildren();
                facetStatus.textContent = 'Carregando filtros…';
                submit.disabled = true;
                if (!tag) { facetStatus.textContent = 'Escolha um modelo.'; return; }
                try {
                    if (!facetCache.has(tag)) {
                        var controller = new AbortController();
                        facetRequest = controller;
                        var feed = await fetchFeed(makeSearchUrl(tag, {}, 'user'), controller, tag);
                        if (run !== facetVersion) return;
                        facetCache.set(tag, feed.content.querySelector('[data-be-feed-facets]').cloneNode(true));
                    }
                    facets.appendChild(document.importNode(facetCache.get(tag), true));
                    all('input', facets).forEach(function (input) {
                        var value = selected[input.name] || '';
                        if (input.type === 'checkbox') input.checked = value.split('|').indexOf(input.value) !== -1;
                        else input.value = value;
                    });
                    facetStatus.textContent = '';
                    submit.disabled = false;
                } catch (_) {
                    if (run !== facetVersion) return;
                    facetStatus.textContent = 'Não foi possível carregar os filtros. Feche e abra novamente para tentar.';
                }
            }
            opener.addEventListener('click', function () {
                var initialModel = state.model || (models[0] ? models[0].dataset.beTag : '');
                modelSelect.value = initialModel;
                dialog.showModal();
                loadFacets(initialModel, state.model ? state.filters : {});
            });
            one('[data-be-close-filters]').addEventListener('click', function () { dialog.close(); });
            dialog.addEventListener('close', function () { facetVersion++; if (facetRequest) facetRequest.abort(); opener.focus(); });
            dialog.addEventListener('click', function (event) {
                if (event.target !== dialog) return;
                var rect = dialog.getBoundingClientRect();
                if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) dialog.close();
            });
            modelSelect.addEventListener('change', function () { loadFacets(modelSelect.value, {}); });
            one('[data-be-clear-filters]').addEventListener('click', function () { dialog.close(); activate('', {}, 'user', true); });
            form.addEventListener('submit', function (event) {
                event.preventDefault();
                if (submit.disabled) return;
                var filters = Object.create(null);
                new FormData(form).forEach(function (value, key) {
                    if (reserved.indexOf(key) === -1 && String(value).trim()) filters[key] = filters[key] ? filters[key] + '|' + value : String(value);
                });
                if (filters.min_price && filters.max_price && Number(filters.min_price) > Number(filters.max_price)) {
                    facetStatus.textContent = 'O preço máximo deve ser maior ou igual ao mínimo.';
                    return;
                }
                dialog.close();
                activate(modelSelect.value, filters, state.sort, true);
            });
        }
        fromLocation();
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init, {once: true});
    else init();
}());
