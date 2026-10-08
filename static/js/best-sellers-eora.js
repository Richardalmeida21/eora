(function () {
    'use strict';
    function init() {
        var root = document.querySelector('[data-bs-page]');
        if (!root || root.dataset.bsReady) return;
        root.dataset.bsReady = '1';
        var all = function (selector, parent) { return Array.from((parent || root).querySelectorAll(selector)); };
        var one = function (selector) { return root.querySelector(selector); };
        var normalize = function (value) { return String(value || '').trim().toLocaleLowerCase('pt-BR'); };
        var reduced = window.matchMedia('(prefers-reduced-motion: reduce)');
        var grid = one('[data-bs-grid]');
        var status = one('[data-bs-status]');
        var more = one('[data-bs-more]');
        var sort = one('[data-bs-sort]');
        var dialog = one('#bs-filter-dialog');
        var form = one('[data-bs-filter-form]');
        var engines = [window.EoraBagFilters, window.EoraEyewearFilters].filter(Boolean);
        var macros = all('[data-bs-category]').sort(function (a, b) { return Number(a.dataset.bsOrder) - Number(b.dataset.bsOrder); });
        macros.forEach(function (item) { item.parentNode.appendChild(item); });
        var macroNav = one('.bs-macros');
        macroNav.style.setProperty('--bs-macro-count', String(Math.max(1, macros.length)));
        macroNav.classList.toggle('bs-macros--overflow', macros.length > 4);
        macroNav.hidden = !macros.length;
        var byId = new Map(macros.map(function (item) { return [item.dataset.bsCategory, item]; }));
        var seen = new Set();
        var products = [];
        var categoryBase = new URL(root.dataset.bsCategoryUrl, window.location.href);
        var nextUrl = new URL(categoryBase);
        nextUrl.searchParams.set('bs_category_feed', '1');
        var preview = new URL(window.location.href).searchParams.get('preview');
        if (preview) nextUrl.searchParams.set('preview', preview);
        var visited = new Set();
        var catalogLoading = false;
        var catalogError = false;
        var category = 'all';
        var filters = {};
        var sorting = 'user';
        var pageSize = 24;
        var limit = pageSize;
        var renderedProducts = [];
        var pendingMoreIndex = null;
        var communityId = null;
        var disposeCommunity = function () {};
        var previousFocus;
        var modelOptions = form ? all('select[name="bs_model"] option', form).filter(function (option) { return option.value; }).map(function (option) { return {value: normalize(option.value), label: option.textContent}; }) : [];
        var knownModels = ['vertice', 'maxivertice', 'minivertice', 'clutchvertice', 'hobovertice', 'iris', 'nova', 'astra', 'luna', 'luar', 'onyx', 'sparky', 'aura', 'prism'];
        function discoverModels() {
            knownModels.forEach(function (value) {
                if (!modelOptions.some(function (item) { return item.value === value; }) && products.some(function (product) { return product.tags.indexOf(value) !== -1; })) modelOptions.push({value: value, label: value.toUpperCase()});
            });
        }
        function checkedCategoryUrl(value) {
            var url = new URL(value, categoryBase);
            var basePath = categoryBase.pathname.replace(/\/+$/, '');
            var path = url.pathname.replace(/\/+$/, '');
            if (url.origin !== categoryBase.origin || (path !== basePath && !(path.indexOf(basePath + '/page/') === 0 && /^[1-9]\d*$/.test(path.slice((basePath + '/page/').length))))) throw new Error('Invalid Best Sellers category URL');
            url.searchParams.set('bs_category_feed', '1');
            if (preview) url.searchParams.set('preview', preview);
            return url;
        }
        function appendProducts(feed) {
            all('[data-be-product]', feed.content).forEach(function (card) {
                if (seen.has(card.dataset.beProduct)) return;
                seen.add(card.dataset.beProduct);
                var tags;
                try { tags = JSON.parse(card.dataset.beTags); } catch (_) { tags = []; }
                products.push({card: card, tags: Array.isArray(tags) ? tags.map(normalize) : [], price: Number(card.dataset.bePrice), order: products.length});
            });
        }
        function requestCategoryPage(url) {
            var controller = new AbortController();
            var timeout = setTimeout(function () { controller.abort(); }, 20000);
            var promise = (async function () {
                try {
                    var response = await fetch(url, {credentials: 'same-origin', signal: controller.signal, headers: {'Accept': 'text/html'}});
                    if (!response.ok) throw new Error('Category HTTP ' + response.status);
                    checkedCategoryUrl(response.url || url);
                    return await response.text();
                } finally { clearTimeout(timeout); }
            }());
            // A próxima resposta pode falhar enquanto a página atual é exibida.
            // O await do carregador continua responsável por tratar esse erro.
            promise.catch(function () {});
            return {promise: promise, controller: controller};
        }
        async function loadCatalog() {
            if (catalogLoading || !nextUrl) return;
            catalogLoading = true; catalogError = false; render();
            var pending;
            try {
                pending = requestCategoryPage(checkedCategoryUrl(nextUrl));
                while (nextUrl) {
                    var url = checkedCategoryUrl(nextUrl);
                    if (visited.has(url.href)) throw new Error('Repeated category page');
                    var html = await pending.promise;
                    // Somente o feed inerte vira DOM; cabecalho, scripts e vitrines
                    // da resposta completa nunca entram no catalogo da campanha.
                    var match = html.match(/<template\b[^>]*\bdata-bs-category-feed\b[^>]*>[\s\S]*?<\/template\s*>/i);
                    if (!match) throw new Error('Missing Best Sellers category feed');
                    var container = document.createElement('template');
                    container.innerHTML = match[0];
                    var feed = container.content.querySelector('[data-bs-category-feed]');
                    if (!feed || !['0', '1'].includes(feed.dataset.last)) throw new Error('Invalid category feed');
                    var following = null;
                    if (feed.dataset.last !== '1') {
                        if (!feed.dataset.next) throw new Error('Missing category pagination');
                        following = checkedCategoryUrl(feed.dataset.next);
                        if (following.href === url.href || visited.has(following.href)) throw new Error('Repeated category page');
                    }
                    // Começa a próxima requisição antes de montar os cards atuais.
                    pending = following ? requestCategoryPage(following) : null;
                    appendProducts(feed);
                    visited.add(url.href); nextUrl = following;
                    render();
                }
                discoverModels();
                root.dataset.bsCatalogReady = '1';
            } catch (_) { catalogError = true; }
            finally {
                if (pending) pending.controller.abort();
                catalogLoading = false; render();
            }
        }

        function initCarousel(section) {
            var track = section.querySelector('[data-bs-track],[data-be-track]');
            var controls = section.querySelector('[data-be-controls]');
            if (!track || !controls) return function () {};
            var previous = controls.querySelector('[data-be-prev]');
            var next = controls.querySelector('[data-be-next]');
            var dots = controls.querySelector('[data-be-dots]');
            var offsets = [];
            var current = 0;
            var gallery = section.classList.contains('be-gallery');
            function go(index) { track.scrollTo({left: offsets[Math.max(0, Math.min(offsets.length - 1, index))], behavior: reduced.matches ? 'auto' : 'smooth'}); }
            function layout() {
                if (gallery) {
                    var visible = Number(getComputedStyle(section).getPropertyValue('--be-visible')) || 1;
                    var overflow = track.children.length > visible;
                    section.classList.toggle('bs-gallery--overflow', overflow);
                    var last = track.lastElementChild;
                    // O espaco final permite centralizar somente a ultima foto.
                    track.style.setProperty('--bs-end-space', overflow && last ? Math.max(0, (track.clientWidth - last.getBoundingClientRect().width) / 2) + 'px' : '0px');
                }
                var maximum = Math.max(0, track.scrollWidth - track.clientWidth);
                var first = track.children[0];
                offsets = [0];
                Array.from(track.children).slice(1).forEach(function (item) {
                    if (gallery && item === track.lastElementChild) return;
                    var left = item.offsetLeft - first.offsetLeft;
                    if (left < maximum - 2) offsets.push(left);
                });
                if (maximum > 2) offsets.push(maximum);
                update();
            }
            function update() {
                current = offsets.reduce(function (closest, left, index) { return Math.abs(left - track.scrollLeft) < Math.abs(offsets[closest] - track.scrollLeft) ? index : closest; }, 0);
                controls.hidden = offsets.length < 2;
                previous.disabled = current === 0;
                next.disabled = current === offsets.length - 1;
                if (dots.children.length !== offsets.length) {
                    dots.replaceChildren();
                    offsets.forEach(function (_, index) {
                        var button = document.createElement('button');
                        button.className = 'be-dot'; button.type = 'button';
                        button.setAttribute('aria-label', 'Ir para posição ' + (index + 1));
                        button.addEventListener('click', function () { go(index); });
                        dots.appendChild(button);
                    });
                }
                Array.from(dots.children).forEach(function (button, index) { if (index === current) button.setAttribute('aria-current', 'true'); else button.removeAttribute('aria-current'); });
            }
            previous.addEventListener('click', function () { go(current - 1); });
            next.addEventListener('click', function () { go(current + 1); });
            track.addEventListener('scroll', update, {passive: true});
            track.addEventListener('keydown', function (event) {
                if (event.target !== track || !['ArrowLeft', 'ArrowRight'].includes(event.key)) return;
                event.preventDefault(); go(current + (event.key === 'ArrowRight' ? 1 : -1));
            });
            var observer = window.ResizeObserver ? new ResizeObserver(layout) : null;
            if (observer) observer.observe(track);
            else window.addEventListener('resize', layout);
            layout();
            return function () { if (observer) observer.disconnect(); else window.removeEventListener('resize', layout); };
        }
        all('[data-bs-carousel],.bs-categories [data-be-carousel]').forEach(initCarousel);

        function initGallery(gallery) {
            var track = gallery.querySelector('[data-be-product-slides]');
            var slides = all('[data-be-product-slide]', gallery);
            var previous = gallery.querySelector('[data-be-gallery-prev]');
            var next = gallery.querySelector('[data-be-gallery-next]');
            var counter = gallery.querySelector('[data-be-gallery-counter]');
            if (!track || slides.length < 2) return;
            var current = 0;
            var start = null;
            var dragged = false;
            function load(index) {
                slides.slice(Math.max(0, index - 1), index + 2).forEach(function (slide) {
                    var image = slide.querySelector('img[data-be-src]');
                    if (image) {
                        if (image.dataset.beSrcset) { image.srcset = image.dataset.beSrcset; image.removeAttribute('data-be-srcset'); }
                        image.src = image.dataset.beSrc; image.removeAttribute('data-be-src');
                    }
                });
            }
            function update() {
                current = Math.max(0, Math.min(slides.length - 1, Math.round(track.scrollLeft / Math.max(1, track.clientWidth))));
                counter.textContent = (current + 1) + ' / ' + slides.length;
                previous.disabled = current === 0; next.disabled = current === slides.length - 1;
                load(current);
            }
            function go(index) { index = Math.max(0, Math.min(slides.length - 1, index)); load(index); track.scrollTo({left: index * track.clientWidth, behavior: reduced.matches ? 'auto' : 'smooth'}); }
            previous.addEventListener('click', function () { go(current - 1); });
            next.addEventListener('click', function () { go(current + 1); });
            track.addEventListener('scroll', update, {passive: true});
            track.addEventListener('pointerdown', function (event) { start = event.clientX; dragged = false; load(current); }, {passive: true});
            track.addEventListener('pointermove', function (event) { if (start !== null && Math.abs(event.clientX - start) > 8) dragged = true; }, {passive: true});
            track.addEventListener('pointerup', function () { start = null; }, {passive: true});
            track.addEventListener('pointercancel', function () { start = null; dragged = false; }, {passive: true});
            track.addEventListener('click', function (event) { if (dragged) { event.preventDefault(); dragged = false; } });
            track.addEventListener('keydown', function (event) {
                if (!['ArrowLeft', 'ArrowRight'].includes(event.key)) return;
                event.preventDefault(); go(current + (event.key === 'ArrowRight' ? 1 : -1));
            });
            gallery.addEventListener('mouseenter', function () { load(current); }, {once: true});
            gallery.addEventListener('focusin', function () { load(current); }, {once: true});
        }
        function categoryProducts(id) {
            var macro = byId.get(id);
            return macro ? products.filter(function (product) { return product.tags.indexOf(normalize(macro.dataset.bsTag)) !== -1; }) : products;
        }
        function productType(product) {
            if (product.tags.indexOf('bolsa') !== -1 || /^bolsa\b/i.test(product.card.dataset.beName)) return 'bag';
            if (product.tags.indexOf('oculos') !== -1 || /^óculos\b/i.test(product.card.dataset.beName)) return 'eyewear';
            return '';
        }
        function refreshCommunity() {
            if (communityId === category) return;
            communityId = category;
            disposeCommunity();
            var container = one('[data-bs-community]');
            if (!container) return;
            container.replaceChildren();
            var template = all('[data-bs-community-template]').find(function (item) { return item.dataset.bsCommunityTemplate === category; });
            if (template) {
                container.appendChild(template.content.cloneNode(true));
                disposeCommunity = initCarousel(container.firstElementChild);
            }
        }
        function renderProducts(list) {
            var visible = list.slice(0, limit);
            if (visible.length === renderedProducts.length && visible.every(function (product, index) { return product === renderedProducts[index]; })) return;
            var wanted = new Set(visible.map(function (product) { return product.card; }));
            Array.from(grid.children).forEach(function (card) { if (!wanted.has(card)) card.remove(); });
            var next = grid.firstElementChild;
            var fragment = document.createDocumentFragment();
            visible.forEach(function (product) {
                if (!product.galleryReady) {
                    all('[data-be-product-gallery]', product.card).forEach(initGallery);
                    product.galleryReady = true;
                }
                if (product.card === next) next = next.nextElementSibling;
                else if (next) grid.insertBefore(product.card, next);
                else fragment.appendChild(product.card);
            });
            grid.appendChild(fragment);
            renderedProducts = visible;
        }
        function render() {
            macros.forEach(function (macro) {
                var active = macro.dataset.bsCategory === category;
                macro.setAttribute('aria-expanded', String(active));
                if (active) macro.setAttribute('aria-current', 'true'); else macro.removeAttribute('aria-current');
                var description = macro.querySelector('.bs-macro__description');
                if (description) description.hidden = !active;
            });
            one('[data-bs-reset]').setAttribute('aria-pressed', String(category === 'all'));
            var macro = byId.get(category);
            one('[data-bs-result-title]').textContent = macro ? macro.querySelector('.bs-macro__title').textContent : 'Todos os best sellers';
            var filterKeys = Object.keys(filters);
            var list = categoryProducts(category);
            if (filterKeys.length) list = list.filter(function (product) {
                var type = productType(product);
                if (type === 'bag' && filterKeys.some(function (key) { return key.indexOf('oe_') === 0; })) return false;
                if (type === 'eyewear' && filterKeys.some(function (key) { return key.indexOf('be_') === 0; })) return false;
                if (filters.bs_model && product.tags.indexOf(normalize(filters.bs_model)) === -1) return false;
                if (filters.min_price && product.price < Number(filters.min_price) * 100) return false;
                if (filters.max_price && product.price > Number(filters.max_price) * 100) return false;
                return engines.every(function (engine) { return engine.matches(product.card, filters, product.tags); });
            });
            if (sorting !== 'user') list = list.slice().sort(function (a, b) {
                if (sorting === 'price-ascending') return a.price - b.price || a.order - b.order;
                if (sorting === 'price-descending') return b.price - a.price || a.order - b.order;
                if (sorting === 'alpha-ascending') return a.card.dataset.beName.localeCompare(b.card.dataset.beName, 'pt-BR') || a.order - b.order;
                if (sorting === 'created-descending') return String(b.card.dataset.beCreated).localeCompare(a.card.dataset.beCreated, 'pt-BR', {numeric: true}) || a.order - b.order;
                return a.order - b.order;
            });
            renderProducts(list);
            if (pendingMoreIndex !== null && grid.children[pendingMoreIndex]) {
                if (document.activeElement === more) grid.children[pendingMoreIndex].querySelector('h3 a').focus({preventScroll: true});
                pendingMoreIndex = null;
            }
            status.textContent = catalogLoading ? (list.length ? '' : 'Carregando produtos da categoria Best Sellers…') : catalogError ? 'Não foi possível carregar todos os produtos de Best Sellers. Tente novamente.' : !list.length ? 'Nenhum produto encontrado. Experimente outra categoria ou limpe os filtros.' : filterKeys.length ? list.length + (list.length === 1 ? ' produto encontrado' : ' produtos encontrados') : '';
            one('.bs-catalog').setAttribute('aria-busy', String(catalogLoading));
            one('[data-bs-retry]').hidden = !catalogError;
            sort.disabled = !!nextUrl;
            var openFilters = one('[data-bs-open-filters]');
            if (openFilters) openFilters.disabled = !!nextUrl;
            more.hidden = list.length <= limit && (!nextUrl || catalogError || !products.length);
            var waitingMore = catalogLoading && list.length < limit;
            more.setAttribute('aria-disabled', String(waitingMore));
            more.textContent = waitingMore && products.length ? 'Carregando…' : 'Mostrar mais produtos';
            sort.value = sorting;
            refreshCommunity();
        }
        function resetLimit() { limit = pageSize; pendingMoreIndex = null; }
        function writeUrl() {
            var url = new URL(window.location.href);
            ['bs_category', 'bs_filters', 'bs_sort'].forEach(function (key) { url.searchParams.delete(key); });
            if (category !== 'all') url.searchParams.set('bs_category', category);
            if (Object.keys(filters).length) url.searchParams.set('bs_filters', JSON.stringify(filters));
            if (sorting !== 'user') url.searchParams.set('bs_sort', sorting);
            if (url.href !== window.location.href) window.history.pushState(null, '', url);
        }
        function readUrl() {
            var params = new URL(window.location.href).searchParams;
            category = byId.has(params.get('bs_category')) ? params.get('bs_category') : 'all';
            sorting = Array.from(sort.options).some(function (option) { return option.value === params.get('bs_sort'); }) ? params.get('bs_sort') : 'user';
            filters = {};
            try {
                var value = JSON.parse(params.get('bs_filters') || '{}');
                if (value && typeof value === 'object' && !Array.isArray(value)) Object.keys(value).forEach(function (key) {
                    if (/^(bs_model|be_[a-z_]+|oe_[a-z_]+|min_price|max_price)$/.test(key) && typeof value[key] === 'string' && value[key].length < 500) filters[key] = value[key];
                });
            } catch (_) {}
            filters = engines.reduce(function (value, engine) { return engine.normalizeFilters(value); }, filters);
            resetLimit();
            render();
        }
        macros.forEach(function (macro) {
            macro.addEventListener('click', function (event) {
                if (event.ctrlKey || event.metaKey || event.shiftKey || event.altKey || event.button) return;
                event.preventDefault(); category = macro.dataset.bsCategory; filters = {}; resetLimit(); render(); writeUrl();
            });
        });
        one('[data-bs-reset]').addEventListener('click', function () { category = 'all'; filters = {}; resetLimit(); render(); writeUrl(); });
        sort.addEventListener('change', function () { sorting = sort.value; resetLimit(); render(); writeUrl(); });
        more.addEventListener('click', function () {
            if (more.getAttribute('aria-disabled') === 'true') return;
            pendingMoreIndex = grid.children.length;
            limit += pageSize; render();
        });
        function collect() {
            var values = {};
            new FormData(form).forEach(function (value, key) {
                value = String(value).trim();
                if (value && key !== 'bs_category') values[key] = values[key] ? values[key] + '|' + value : value;
            });
            return engines.reduce(function (value, engine) { return engine.normalizeFilters(value); }, values);
        }
        function fillForm(id, selected) {
            form.reset();
            form.elements.bs_category.value = id;
            var candidates = categoryProducts(id);
            var facets = form.querySelector('[data-be-facets]');
            facets.replaceChildren();
            engines.forEach(function (engine) {
                var eyewear = engine === window.EoraEyewearFilters;
                var tags = Array.from(new Set([].concat.apply([], candidates.filter(function (product) { return productType(product) !== (eyewear ? 'bag' : 'eyewear'); }).map(function (product) {
                    return eyewear ? engine.facetTags(product.card, product.tags) : product.tags;
                }))));
                engine.render(facets, selected, tags, true);
            });
            ['be_size', 'oe_size'].forEach(function (key) {
                var fieldset = facets.querySelector('[data-be-facet="' + key + '"]');
                if (fieldset) fieldset.querySelector('legend').textContent = key === 'be_size' ? 'Tamanho das bolsas' : 'Tamanho dos óculos';
            });
            var model = form.elements.bs_model;
            model.replaceChildren(new Option('Todos os modelos', ''));
            modelOptions.filter(function (option) { return candidates.some(function (product) { return product.tags.indexOf(option.value) !== -1; }); }).forEach(function (option) { model.appendChild(new Option(option.label, option.value)); });
            model.value = selected.bs_model || '';
            ['min_price', 'max_price'].forEach(function (key) { form.elements[key].value = selected[key] || ''; });
            form.elements.max_price.setCustomValidity('');
        }
        if (form) {
            macros.forEach(function (macro) { form.elements.bs_category.appendChild(new Option(macro.querySelector('.bs-macro__title').textContent, macro.dataset.bsCategory)); });
            one('[data-bs-open-filters]').addEventListener('click', function () {
                previousFocus = document.activeElement; fillForm(category, filters); dialog.showModal();
            });
            function close() { dialog.close(); }
            one('[data-bs-close-filters]').addEventListener('click', close);
            dialog.addEventListener('close', function () { if (previousFocus) previousFocus.focus({preventScroll: true}); });
            dialog.addEventListener('click', function (event) { if (event.target === dialog) { var rect = dialog.getBoundingClientRect(); if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) close(); } });
            form.elements.bs_category.addEventListener('change', function () { fillForm(form.elements.bs_category.value, {}); });
            one('[data-bs-clear-filters]').addEventListener('click', function () { fillForm('all', {}); });
            ['min_price', 'max_price'].forEach(function (key) { form.elements[key].addEventListener('input', function () { form.elements.max_price.setCustomValidity(''); }); });
            form.addEventListener('submit', function (event) {
                event.preventDefault();
                var values = collect();
                if (values.min_price && values.max_price && Number(values.min_price) > Number(values.max_price)) { form.elements.max_price.setCustomValidity('O preço máximo deve ser maior ou igual ao mínimo.'); form.reportValidity(); return; }
                category = form.elements.bs_category.value; filters = values; resetLimit(); render(); writeUrl(); close();
            });
        }
        window.addEventListener('popstate', readUrl);
        readUrl();
        one('[data-bs-retry]').addEventListener('click', loadCatalog);
        loadCatalog();
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init, {once: true}); else init();
}());
