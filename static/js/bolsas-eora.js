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
            function pageOffsets() {
                var visible = Math.max(1, Math.floor(parseFloat(getComputedStyle(section).getPropertyValue('--be-visible')) || 4));
                var maximum = Math.max(0, track.scrollWidth - track.clientWidth);
                var offsets = [0];
                for (var index = visible; index < track.children.length; index += visible) {
                    var left = track.children[index].offsetLeft - track.children[0].offsetLeft;
                    if (left >= maximum - 2) break;
                    offsets.push(left);
                }
                if (maximum > 2) offsets.push(maximum);
                return offsets;
            }
            function goTo(target, immediate) {
                var offsets = pageOffsets();
                var page = Math.max(0, Math.min(offsets.length - 1, target));
                track.scrollTo({left: offsets[page], behavior: immediate || reducedMotion.matches ? 'auto' : 'smooth'});
            }
            function update() {
                var overflow = track.scrollWidth - track.clientWidth > 2;
                controls.hidden = !overflow;
                section.classList.toggle('be-models--overflow', section.classList.contains('be-models') && track.children.length > 4);
                var offsets = pageOffsets();
                var count = offsets.length;
                currentPage = offsets.reduce(function (closest, left, index) {
                    return Math.abs(left - track.scrollLeft) < Math.abs(offsets[closest] - track.scrollLeft) ? index : closest;
                }, 0);
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

        var models = all('[data-be-tag]');
        var modelTags = [];
        models.forEach(function (model) {
            if (!modelTags.some(function (tag) { return normalize(tag) === normalize(model.dataset.beTag); })) modelTags.push(model.dataset.beTag);
        });
        var searchBase = new URL(root.dataset.searchUrl, window.location.href);
        if (searchBase.origin !== window.location.origin) return;
        var grid = one('[data-be-results-grid]');
        var bannerTemplates = all('[data-be-banner-template]');
        var activeBanners = [];
        var results = one('[data-be-results]');
        var status = one('[data-be-status]');
        var more = one('[data-be-more]');
        var dialog = one('#be-filter-dialog');
        var form = one('[data-be-filter-form]');
        var bagFilters = window.EoraBagFilters;
        var facetCache = new Map();
        var feedCache = new Map();
        var feedCacheBytes = 0;
        var feedCacheLimit = 2 * 1024 * 1024;
        var facetRequest = null;
        var facetVersion = 0;
        var productRequest = null;
        var version = 0;
        var state;
        var reserved = ['q', 'page', 'results_only', 'sort_by', 'be_model', 'be_feed', 'preview', '__proto__', 'constructor', 'prototype'];

        function placeBanners() {
            if (!activeBanners.length) return;
            var products = all('[data-be-product]', grid);
            // Um banner conserva duas linhas completas antes dele. Com varios banners,
            // o primeiro sobe o necessario para que todos alternem junto aos produtos.
            var preferredRow = Math.floor(Math.max(0, Math.min(8, products.length - 4)) / 4) + 1;
            var firstRow = Math.max(1, preferredRow - Math.max(0, activeBanners.length - 1));
            var productImage = products[0] && products[0].querySelector('.be-product__image');
            var rowGap = parseFloat(getComputedStyle(grid).rowGap) || 0;
            var cardHeight = products.slice(0, 4).reduce(function (height, product) {
                return Math.max(height, product.getBoundingClientRect().height);
            }, 0);
            var bannerHeight = productImage && cardHeight ? cardHeight + productImage.getBoundingClientRect().height + rowGap : 0;
            activeBanners.forEach(function (banner, index) {
                var row = firstRow + index * 2;
                var before = mobile.matches ? Math.min(4 + index * 4, products.length) : Math.min((row - 1) * 4, products.length);
                banner.style.setProperty('--be-banner-row', row);
                banner.style.setProperty('--be-banner-column', index % 2 ? '1 / span 2' : '3 / span 2');
                if (!mobile.matches && bannerHeight) banner.style.setProperty('--be-banner-height', bannerHeight + 'px');
                else banner.style.removeProperty('--be-banner-height');
                grid.insertBefore(banner, products[before] || null);
            });
        }
        function bannerSettings(item) {
            var values = String(item.dataset.beBannerFilter || '').split(',');
            var tag = values.shift() || '';
            var showInAll = values.some(function (value) { return normalize(value) === 'todos'; });
            var href = '';
            var rawHref = String(item.dataset.beBannerHref || '').trim();
            if (rawHref) {
                try {
                    var url = new URL(rawHref, window.location.href);
                    if (url.protocol === 'http:' || url.protocol === 'https:') href = url.origin === window.location.origin ? url.pathname + url.search + url.hash : url.href;
                } catch (error) {}
            }
            return {tag: tag.trim(), showInAll: showInAll || item.dataset.beBannerLegacyAll === 'true', href: href};
        }
        function createBanner(template, settings) {
            var banner = document.importNode(template.content.firstElementChild, true);
            var body = banner.querySelector('[data-be-banner-body]');
            if (settings.href && body) {
                var link = document.createElement('a');
                link.className = 'be-catalog-banner__link';
                link.setAttribute('href', settings.href);
                if (body.dataset.beBannerLabel) link.setAttribute('aria-label', body.dataset.beBannerLabel);
                while (body.firstChild) link.appendChild(body.firstChild);
                body.replaceWith(link);
            }
            return banner;
        }
        function selectBanners(model) {
            var templates = bannerTemplates.map(function (item) {
                var banner = bannerSettings(item);
                return {template: item, settings: banner};
            }).filter(function (item) {
                return model ? normalize(item.settings.tag) === normalize(model) : item.settings.showInAll;
            });
            activeBanners = templates.map(function (item) { return createBanner(item.template, item.settings); });
            placeBanners();
        }
        mobile.addEventListener('change', placeBanners);
        window.addEventListener('resize', placeBanners, {passive: true});

        function selectedModel(value) {
            var model = models.find(function (item) { return normalize(item.dataset.beTag) === normalize(value); });
            return model ? model.dataset.beTag : '';
        }
        function makeSearchUrl(tag, filters, sort) {
            var url = new URL(searchBase);
            url.search = '';
            url.searchParams.set('q', '"' + tag + '"');
            url.searchParams.set('be_feed', '4');
            var preview = new URL(window.location.href).searchParams.get('preview');
            if (preview) url.searchParams.set('preview', preview);
            Object.keys(filters).forEach(function (key) {
                if (reserved.indexOf(key) === -1 && key.indexOf('be_') !== 0 && filters[key]) url.searchParams.set(key, filters[key]);
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
        function forgetFeed(key) {
            feedCacheBytes -= feedCache.get(key).bytes;
            feedCache.delete(key);
        }
        function parseFeed(markup, tag) {
            // Somente o template da campanha vira DOM. Cabecalho, scripts, imagens
            // e cards da busca normal nao devem ser processados nem retidos no cache.
            var container = document.createElement('template');
            container.innerHTML = markup;
            var feed = container.content.querySelector('template[data-be-search-feed]');
            if (!feed || normalize(feed.dataset.tag) !== normalize(tag)) throw new Error('Missing campaign feed');
            return feed;
        }
        async function fetchFeed(url, controller, tag) {
            url = checkedUrl(url);
            feedCache.forEach(function (entry, key) { if (Date.now() - entry.time >= 300000) forgetFeed(key); });
            var cached = feedCache.get(url.href);
            if (cached) return parseFeed(cached.markup, tag);
            var timeout = setTimeout(function () { controller.abort(); }, 20000);
            try {
                var response = await fetch(checkedUrl(url), {credentials: 'same-origin', signal: controller.signal, headers: {'Accept': 'text/html'}});
                if (!response.ok) throw new Error('Search HTTP ' + response.status);
                checkedUrl(response.url || url);
                var html = await response.text();
                // O formato deste template e definido em search-feed.tpl; os campos
                // dos produtos sao escapados e nao contem templates aninhados.
                var match = html.match(/<template\b[^>]*\bdata-be-search-feed\b[^>]*>[\s\S]*?<\/template\s*>/i);
                if (!match) throw new Error('Missing campaign feed');
                var feed = parseFeed(match[0], tag);
                if (feed.dataset.last !== '1') {
                    if (!feed.dataset.next) throw new Error('Missing pagination');
                    checkedUrl(feed.dataset.next, url);
                }
                var unusedFacets = feed.content.querySelector('[data-be-feed-facets]');
                if (unusedFacets) unusedFacets.remove();
                // Strings compactas, sem documentos/DOM em cache. O limite em bytes
                // complementa o numero de paginas para respostas de tamanhos diferentes.
                var markup = feed.outerHTML;
                var bytes = markup.length * 2;
                if (feedCache.has(url.href)) forgetFeed(url.href);
                if (bytes <= feedCacheLimit) {
                    while (feedCache.size && (feedCache.size >= 40 || feedCacheBytes + bytes > feedCacheLimit)) forgetFeed(feedCache.keys().next().value);
                    feedCache.set(url.href, {markup: markup, bytes: bytes, time: Date.now()});
                    feedCacheBytes += bytes;
                }
                var facet = getFacet(tag);
                all('[data-be-product]', feed.content).forEach(function (card) {
                    var tags = tagsFor(card);
                    if (tags.indexOf(normalize(tag)) !== -1) tags.forEach(function (value) { facet.tags.add(value); });
                });
                return feed;
            } finally { clearTimeout(timeout); }
        }
        function getFacet(tag) {
            if (!facetCache.has(tag)) facetCache.set(tag, {tags: new Set(), next: makeSearchUrl(tag, {}, 'user').href, visited: new Set()});
            return facetCache.get(tag);
        }
        function tagsFor(card) {
            var tags;
            try { tags = JSON.parse(card.dataset.beTags || '[]'); } catch (_) { return []; }
            if (typeof tags === 'string') tags = tags.split(',');
            if (!Array.isArray(tags)) tags = Object.values(tags || {});
            return tags.map(function (tag) {
                return normalize(typeof tag === 'string' ? tag : tag && (tag.tag || (tag.attributes && tag.attributes.tag)));
            });
        }
        function remember() {
            var url = new URL(window.location.href);
            ['tag', 'be_filters', 'be_sort'].forEach(function (key) { url.searchParams.delete(key); });
            if (state.model) url.searchParams.set('tag', state.model);
            if (Object.keys(state.filters).length) url.searchParams.set('be_filters', JSON.stringify(state.filters));
            if (state.sort !== 'user') url.searchParams.set('be_sort', state.sort);
            if (url.href !== window.location.href) window.history.pushState(null, '', url);
        }
        function hasMore() {
            return state.searches.some(function (search) { return search.next || search.buffer.length; });
        }
        function showStatus(error) {
            var count = all('[data-be-product]', grid).length;
            var remaining = hasMore();
            if (error) status.textContent = 'Não foi possível carregar os produtos. Tente novamente.';
            else if (state.loading) status.textContent = 'Carregando produtos…';
            else if (!count && !remaining) status.textContent = 'Nenhum produto encontrado com estes filtros.';
            else if (!count) status.textContent = 'Ainda não encontramos produtos nesta parte da busca. Continue para ver os próximos resultados.';
            else status.textContent = count + (count === 1 ? ' produto' : ' produtos') + (remaining ? (count === 1 ? ' carregado' : ' carregados') : (count === 1 ? ' encontrado' : ' encontrados'));
            more.hidden = !error && !remaining;
            more.disabled = state.loading;
            more.textContent = error ? 'Tentar novamente' : 'Mostrar mais produtos';
            results.setAttribute('aria-busy', state.loading ? 'true' : 'false');
        }
        function sortCards(cards, sort) {
            if (sort === 'price-ascending' || sort === 'price-descending') {
                var direction = sort === 'price-ascending' ? 1 : -1;
                cards.sort(function (first, second) { return direction * (Number(first.dataset.bePrice || 0) - Number(second.dataset.bePrice || 0)); });
            } else if (sort === 'alpha-ascending') {
                cards.sort(function (first, second) { return String(first.dataset.beName || '').localeCompare(String(second.dataset.beName || ''), 'pt-BR', {sensitivity: 'base'}); });
            } else if (sort === 'created-descending') {
                var createdValue = function (card) {
                    var value = String(card.dataset.beCreated || '');
                    if (/^\d+$/.test(value)) return Number(value);
                    var parsed = Date.parse(value);
                    return Number.isNaN(parsed) ? Number(value || 0) : parsed;
                };
                cards.sort(function (first, second) { return createdValue(second) - createdValue(first); });
            }
            return cards;
        }
        async function loadMore() {
            if (!state || state.loading) return;
            var run = version;
            var current = state;
            current.loading = true;
            showStatus();
            // Ao filtrar, percorre todas as paginas antes de concluir. Os filtros
            // de caracteristicas sao locais e um resultado pode estar em qualquer
            // pagina da busca; exigir outro clique produziria uma lista incompleta.
            var automatic = Boolean(current.model || Object.keys(current.filters).length || current.sort !== 'user');
            var size = automatic ? Number.POSITIVE_INFINITY : (mobile.matches ? 6 : 12);
            var requestLimit = automatic ? Number.POSITIVE_INFINITY : 3;
            var requests = 0;
            var skipped = 0;
            var cards = [];
            var error = false;
            try {
                // Alterna entre modelos, com no maximo 3 consultas por acao.
                while (cards.length < size && skipped < current.searches.length) {
                    var search = current.searches[current.cursor];
                    if (!search.buffer.length && search.next && requests < requestLimit) {
                        var url = checkedUrl(search.next);
                        if (current.visited.has(url.href)) throw new Error('Repeated search page');
                        var controller = new AbortController();
                        productRequest = controller;
                        var feed = await fetchFeed(url, controller, search.tag);
                        if (run !== version) return;
                        if (Object.keys(current.filters).some(function (key) { return key.indexOf('be_') === 0; }) && !bagFilters) throw new Error('Missing filters');
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
                            var tags = tagsFor(card);
                            if (!current.ids.has(id) && tags.indexOf(normalize(search.tag)) !== -1 && (!bagFilters || bagFilters.matches(card, current.filters, tags))) {
                                current.ids.add(id);
                                search.buffer.push(card);
                            }
                        });
                        current.visited.add(url.href);
                        search.next = next;
                        requests++;
                    }
                    current.cursor = (current.cursor + 1) % current.searches.length;
                    if (search.buffer.length) { cards.push(search.buffer.shift()); skipped = 0; }
                    else if (search.next && requests < requestLimit) skipped = 0;
                    else skipped++;
                }
            } catch (_) {
                if (run !== version) return;
                error = true;
            } finally {
                if (run === version) {
                    if (current.sort !== 'user') sortCards(cards, current.sort);
                    cards.forEach(function (card) { grid.appendChild(document.importNode(card, true)); });
                    placeBanners();
                    current.loading = false;
                    showStatus(error);
                }
            }
        }
        function activate(model, filters, sort, save) {
            version++;
            if (productRequest) productRequest.abort();
            var requestedModel = model;
            model = selectedModel(model);
            filters = requestedModel && !model ? {} : filters || {};
            sort = sort || 'user';
            var active = Boolean(model || Object.keys(filters).length || sort !== 'user');
            var tags = model ? [model] : modelTags;
            state = {model: model, filters: filters, sort: sort, searches: tags.map(function (tag) {
                return {tag: tag, next: makeSearchUrl(tag, filters, sort).href, buffer: []};
            }), cursor: 0, ids: new Set(), visited: new Set(), loading: false};
            one('[data-be-toolbar]').hidden = false;
            one('[data-be-reset]').setAttribute('aria-pressed', active ? 'false' : 'true');
            one('[data-be-sort]').closest('label').hidden = !tags.length;
            results.hidden = false;
            grid.replaceChildren();
            selectBanners(model);
            more.hidden = true;
            models.forEach(function (item) { if (item.dataset.beTag === model) item.setAttribute('aria-current', 'true'); else item.removeAttribute('aria-current'); });
            one('[data-be-sort]').value = sort;
            one('[data-be-result-title]').textContent = model || 'Todas as bolsas';
            if (save) remember();
            if (tags.length) loadMore();
            else status.textContent = 'Nenhum modelo disponível no momento.';
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
        function scrollToResults() {
            window.requestAnimationFrame(function () {
                var header = document.querySelector('.js-head-main');
                var headerPosition = header && getComputedStyle(header).position;
                var offset = header && (headerPosition === 'fixed' || headerPosition === 'sticky') ? header.getBoundingClientRect().height : 0;
                one('[data-be-result-title]').focus({preventScroll: true});
                window.scrollTo({top: Math.max(0, window.scrollY + one('[data-be-toolbar]').getBoundingClientRect().top - offset - 16), behavior: reducedMotion.matches ? 'auto' : 'smooth'});
            });
        }
        models.forEach(function (model) {
            model.addEventListener('click', function (event) {
                if (event.ctrlKey || event.metaKey || event.shiftKey || event.altKey || event.button !== 0) return;
                event.preventDefault();
                activate(model.dataset.beTag, {}, 'user', true);
                scrollToResults();
            });
        });
        one('[data-be-reset]').addEventListener('click', function () { activate('', {}, 'user', true); scrollToResults(); });
        more.addEventListener('click', loadMore);
        one('[data-be-sort]').addEventListener('change', function (event) { activate(state.model, state.filters, event.target.value, true); });
        window.addEventListener('popstate', fromLocation);

        if (dialog && typeof dialog.showModal === 'function' && models.length && bagFilters) {
            var opener = one('[data-be-open-filters]');
            var facetStatus = one('[data-be-facet-status]');
            var facets = one('[data-be-facets]');
            var modelSelect = form.elements.be_model;
            var submit = form.querySelector('[type="submit"]');
            var pendingSelection = null;
            opener.hidden = false;
            bagFilters.models(modelSelect, modelTags);
            async function loadFacets(model, selected) {
                var run = ++facetVersion;
                if (facetRequest) facetRequest.abort();
                var controller = new AbortController();
                facetRequest = controller;
                facets.replaceChildren();
                pendingSelection = selected;
                submit.disabled = false;
                var sources = model ? [model] : modelTags;
                var pending = sources.filter(function (tag) { return getFacet(tag).next; });
                var failed = false;
                function renderAvailable() {
                    if (run !== facetVersion) return;
                    var available = new Set();
                    sources.forEach(function (tag) { getFacet(tag).tags.forEach(function (value) { available.add(value); }); });
                    // Atualiza sem recriar campos: preserva marcacoes e foco durante a carga.
                    bagFilters.render(facets, selected, Array.from(available), true);
                }
                facetStatus.textContent = pending.length ? 'Carregando mais opções… Você já pode aplicar os filtros disponíveis.' : '';
                renderAvailable();
                async function discover() {
                    while (pending.length && run === facetVersion) {
                        var tag = pending.shift();
                        var facet = getFacet(tag);
                        try {
                            // Ate tres modelos em paralelo; cada um retoma da pagina pendente.
                            while (facet.next && run === facetVersion) {
                                var url = checkedUrl(facet.next);
                                if (facet.visited.has(url.href)) throw new Error('Repeated facet page');
                                var feed = await fetchFeed(url, controller, tag);
                                if (run !== facetVersion) return;
                                var next = feed.dataset.last === '1' ? '' : feed.dataset.next;
                                if (feed.dataset.last !== '1' && !next) throw new Error('Missing facet pagination');
                                if (next) {
                                    next = checkedUrl(next, url);
                                    url.searchParams.forEach(function (value, key) { if (key !== 'page' && key !== 'results_only') next.searchParams.set(key, value); });
                                    next = next.href;
                                }
                                facet.visited.add(url.href);
                                facet.next = next;
                                renderAvailable();
                            }
                        } catch (_) {
                            if (run !== facetVersion) return;
                            failed = true;
                        }
                    }
                }
                await Promise.all(Array.from({length: Math.min(3, pending.length)}, discover));
                if (run !== facetVersion) return;
                if (!failed) pendingSelection = null;
                facetStatus.textContent = failed ? 'Não foi possível carregar todas as opções. Você pode aplicar os filtros disponíveis ou fechar e abrir para tentar novamente.' : '';
            }
            opener.addEventListener('click', function () {
                modelSelect.value = state.model;
                form.elements.min_price.value = state.filters.min_price || '';
                form.elements.max_price.value = state.filters.max_price || '';
                facetStatus.textContent = '';
                dialog.showModal();
                one('.be-filter-dialog__body').scrollTop = 0;
                loadFacets(state.model, state.filters);
            });
            one('[data-be-close-filters]').addEventListener('click', function () { dialog.close(); });
            dialog.addEventListener('close', function () { facetVersion++; if (facetRequest) facetRequest.abort(); opener.focus({preventScroll: true}); });
            dialog.addEventListener('click', function (event) {
                if (event.target !== dialog) return;
                var rect = dialog.getBoundingClientRect();
                if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) dialog.close();
            });
            one('[data-be-clear-filters]').addEventListener('click', function () { dialog.close(); activate('', {}, 'user', true); scrollToResults(); });
            modelSelect.addEventListener('change', function () {
                var selected = Object.create(null);
                new FormData(form).forEach(function (value, key) { if (String(value).trim()) selected[key] = selected[key] ? selected[key] + '|' + value : String(value); });
                loadFacets(modelSelect.value, selected);
            });
            form.addEventListener('submit', function (event) {
                event.preventDefault();
                if (submit.disabled) return;
                var filters = Object.create(null);
                new FormData(form).forEach(function (value, key) {
                    if (reserved.indexOf(key) === -1 && String(value).trim()) filters[key] = filters[key] ? filters[key] + '|' + value : String(value);
                });
                // Filtros ativos da URL podem pertencer a paginas ainda nao carregadas.
                // Conserva somente valores ainda sem campo; desmarcacoes visiveis prevalecem.
                Object.keys(pendingSelection || {}).forEach(function (key) {
                    if (reserved.indexOf(key) !== -1 || key.indexOf('be_') !== 0) return;
                    var rendered = all('input', facets).filter(function (input) { return input.name === key; });
                    pendingSelection[key].split('|').forEach(function (value) {
                        if (value && !rendered.some(function (input) { return input.value === value; })) {
                            filters[key] = filters[key] ? filters[key] + '|' + value : value;
                        }
                    });
                });
                if (filters.min_price && filters.max_price && Number(filters.min_price) > Number(filters.max_price)) {
                    facetStatus.textContent = 'O preço máximo deve ser maior ou igual ao mínimo.';
                    return;
                }
                dialog.close();
                activate(modelSelect.value, filters, state.sort, true);
                scrollToResults();
            });
        }
        fromLocation();
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init, {once: true});
    else init();
}());
