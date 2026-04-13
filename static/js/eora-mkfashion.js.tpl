(function () {
    function init() {
        console.log('EORA: Inicializando Provador Virtual Nativo (v4 - Safe Isolation)...');

        var ancora = document.querySelector('#single-product');
        
        // --- TRAVA DE SEGURANÇA PARA A PÁGINA DE PRODUTO ---
        if (ancora) {
            var targetSkuForPdp = (typeof LS !== 'undefined' && LS.variants && LS.variants[0] ? LS.variants[0].sku : '').toUpperCase();
            var isLuarPdp = (targetSkuForPdp.indexOf('LUAPC') > -1 || targetSkuForPdp.indexOf('LUAPREP') > -1 || targetSkuForPdp.indexOf('LUADM') > -1);
            
            if (!isLuarPdp) {
                console.log('EORA: Produto não pertence à linha LUAR. Mantendo layout nativo.');
                document.body.classList.add('eora-native-layout');
                return; // INTERROMPE TUDO PARA ESTE PRODUTO
            }
        }
        // --------------------------------------------------

        function getSrc(el) {
            if (!el) return '';
            var s = el.getAttribute('data-srcset') || el.getAttribute('srcset') || el.getAttribute('data-src') || el.src || '';
            if (s.indexOf(' ') !== -1) s = s.split(' ')[0];
            return s;
        }

        function getDados() {
            var d = {};
            var ts = document.querySelectorAll('.js-product-description-base table');
            ts.forEach(function (t) {
                var td = t.querySelector('tbody > tr:first-child td:first-child');
                if (td) d[td.textContent.trim().toLowerCase()] = t;
            });
            return d;
        }
        var dados = getDados();

        // --- LÓGICA GLOBAL (VITRINE/HOME) ---
        function eoraInjectGridIcons() {
            try {
                var items = document.querySelectorAll('.js-item-product, .product-item, .item, .js-grid-item');
                items.forEach(function(item) {
                    if (item.querySelector('.eora-grid-tryon')) return;
                    var link = item.querySelector('a');
                    if (!link) return;
                    var href = link.href.toLowerCase();
                    var dataSku = (item.getAttribute('data-sku') || '').toUpperCase().trim();
                    var targetSku = '';
                    
                    // Whitelist rigorosa: apenas a linha LUAR e seus satélites
                    if (dataSku.indexOf('LUAPC') > -1) targetSku = 'LUAPC';
                    else if (dataSku.indexOf('LUAPREP') > -1) targetSku = 'LUAPREP';
                    else if (dataSku.indexOf('LUADM') > -1) targetSku = 'LUADM';
                    
                    // Fallback por URL (Satélites antigos)
                    if (!targetSku) {
                        if (href.indexOf('prata') > -1 || href.indexOf('cinza') > -1 || href.indexOf('luapc') > -1) targetSku = 'LUAPC';
                        else if (href.indexOf('preto') > -1 || href.indexOf('fosco') > -1 || href.indexOf('luaprep') > -1) targetSku = 'LUAPREP';
                        else if (href.indexOf('dourado') > -1 || href.indexOf('marrom') > -1 || href.indexOf('luadm') > -1) targetSku = 'LUADM';
                    }
                    
                    if (targetSku) {
                        var imgCont = item.querySelector('.js-item-image-padding, .js-item-image-container, .item-image-container, .grid-item-image, .product-image-container');
                        if (!imgCont) {
                            var img = item.querySelector('img');
                            imgCont = img ? img.parentNode : item;
                        }
                        
                        var btn = document.createElement('div');
                        btn.className = 'eora-grid-tryon';
                        btn.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"></path><circle cx="12" cy="13" r="3.5"></circle><path d="M20 2v4m-2-2h4" stroke-width="2"></path></svg>';
                        btn.onclick = function(e) {
                            e.preventDefault();
                            e.stopPropagation();
                            console.log('EORA: Abrindo provador para:', targetSku);
                            if (typeof mkfashion !== 'undefined') {
                                mkfashion.open('69bbd36a44b548ccd0f965f4', targetSku);
                            } else {
                                console.error('EORA: SDK mkfashion não encontrado!');
                            }
                        };
                        if (getComputedStyle(imgCont).position === 'static') imgCont.style.position = 'relative';
                        imgCont.appendChild(btn);
                    }
                });
            } catch(e) {}
        }
        
        var gridInterval = setInterval(eoraInjectGridIcons, 1000);
        eoraInjectGridIcons();

        var ancora = document.querySelector('#single-product');
        if (!ancora) return;

        function injectHero() {
            if (document.getElementById('eora-hero')) return;
            var d = getDados();
            
            // SÓ ativa o Hero se a tabela 'banner_produto' existir.
            // A trava de segurança já filtrou o LUAR acima, mas aqui garantimos o conteúdo.
            if (!d['banner_produto']) {
                document.body.classList.add('eora-native-layout');
                return;
            }
            document.body.classList.remove('eora-native-layout');
                if (!value) return false;
                var v = value.trim();
                if (!v) return false;
                if (v.indexOf('data:image/') === 0) return true;
                var hasProtocol = /^https?:\/\//i.test(v) || v.indexOf('//') === 0;
                var hasImageExt = /\.(avif|webp|png|jpe?g|gif|svg)(\?.*)?$/i.test(v);
                return hasProtocol && hasImageExt;
            }

            function getImageFromCell(cell) {
                if (!cell) return '';
                var cellImg = cell.querySelector('img');
                if (cellImg) return getSrc(cellImg);
                var raw = (cell.textContent || '').trim();
                if (raw && raw.indexOf('[') !== 0 && isLikelyImageUrl(raw)) return raw;
                return '';
            }

            function normalizeCloudfront(url) {
                if (!url) return '';
                if (url.indexOf('cloudfront.net') !== -1) {
                    return url
                        .replace('/thumbnail/', '/original/')
                        .replace('/small/', '/original/')
                        .replace('/medium/', '/original/')
                        .replace('/large/', '/original/')
                        .replace('/huge/', '/original/');
                }
                return url;
            }

            var bpRows = d['banner_produto'] ? d['banner_produto'].rows : null;
            function getBannerCellFromRowKey(keys) {
                if (!bpRows) return null;
                for (var r = 0; r < bpRows.length; r++) {
                    var firstCell = bpRows[r].cells && bpRows[r].cells[0];
                    if (!firstCell) continue;
                    var rowKey = (firstCell.textContent || '').trim().toLowerCase();
                    if (keys.indexOf(rowKey) !== -1) return bpRows[r].cells;
                }
                return null;
            }

            var bannerDeskRow = bpRows ? bpRows[0].cells : [];
            var bLabel = bannerDeskRow && bannerDeskRow[1] ? bannerDeskRow[1].textContent.trim() : '';
            var bDet1 = bannerDeskRow && bannerDeskRow[2] ? bannerDeskRow[2].textContent.trim() : '';
            var bDet2 = bannerDeskRow && bannerDeskRow[3] ? bannerDeskRow[3].textContent.trim() : '';
            var btnTx = bannerDeskRow && bannerDeskRow[4] ? bannerDeskRow[4].textContent.trim() : 'VER DETALHES';
            var bDesc = (bpRows && bpRows[1]) ? bpRows[1].cells[0].innerHTML.trim() : '';
            var imgD = (bpRows && bpRows[2]) ? getImageFromCell(bpRows[2].cells[0]) : '';
            
            var mobileRowCells = getBannerCellFromRowKey(['banner_mobile', 'banner_mob']);
            var imgM = mobileRowCells ? getImageFromCell(mobileRowCells[1] || mobileRowCells[0]) : '';
            if(!imgM) imgM = imgD;

            var hero = document.createElement('section');
            hero.id = 'eora-hero';
            var isMobile = window.innerWidth <= 767;
            var finalImg = (isMobile && imgM) ? normalizeCloudfront(imgM) : normalizeCloudfront(imgD);
            var prodName = ancora.querySelector('h1') ? ancora.querySelector('h1').textContent : '';

            hero.innerHTML = '<img class="eora-hero-img" src="' + finalImg + '" alt="Hero">' +
                '<div id="eora-banner-overlay" style="position:absolute; bottom:0; left:0; width:100%; padding:0 40px 60px; box-sizing:border-box; background:linear-gradient(to top, rgba(0,0,0,0.3), transparent); color:#fff; display:flex; flex-direction:column; align-items:center; text-align:center;">' +
                    '<span class="eora-pp-label">' + bLabel + '</span>' +
                    '<h2 style="font-size:32px; letter-spacing:8px; text-transform:uppercase; margin:10px 0; font-weight:700;">' + prodName + '</h2>' +
                    '<div style="display:flex; gap:20px; margin-bottom:20px;">' +
                        '<span class="eora-pp-detalhe">' + bDet1 + '</span>' +
                        '<span class="eora-pp-detalhe">' + bDet2 + '</span>' +
                    '</div>' +
                    '<div id="eora-hero-actions">' +
                        '<button id="eora-btn-detalhes" class="eora-pp-btn" style="color:#fff!important; border-color:#fff!important;">' + btnTx + '</button>' +
                        '<div id="eora-static-provador-container" style="display:none; margin-top:10px;">' +
                            '<div class="eora-provador-btn js-eora-static-btn">' +
                                '<div class="eora-provador-icon">' +
                                    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"></path><circle cx="12" cy="13" r="3.5"></circle><path d="M20 2v4m-2-2h4" stroke-width="2"></path></svg>' +
                                '</div>' +
                                '<span class="eora-provador-text">Experimente agora</span>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                    '<div id="eora-hero-desc-content" style="display:none; width:100%; max-width:600px; margin-top:30px; opacity:0; transition:opacity 0.4s ease;">' +
                        '<div style="background:rgba(255,255,255,0.9); padding:30px; border-radius:4px; color:#111; text-align:left;">' +
                            '<div id="eora-hero-desc-text" style="font-size:14px; line-height:1.6; margin-bottom:25px;">' + bDesc + '</div>' +
                            '<div class="eora-spec-container">' +
                                '<span class="eora-blocking-title">Capacidade de Bloqueio</span>' +
                                '<div class="eora-blocking-bar-ui">' +
                                    '<div class="eora-blocking-segment js-blocking-low"></div>' +
                                    '<div class="eora-blocking-segment js-blocking-med"></div>' +
                                    '<div class="eora-blocking-segment js-blocking-high"></div>' +
                                '</div>' +
                                '<div class="eora-blocking-labels">' +
                                    '<span class="js-lbl-low">Baixa</span>' +
                                    '<span class="js-lbl-med">Média</span>' +
                                    '<span class="js-lbl-high">Alta</span>' +
                                '</div>' +
                                '<button id="js-toggle-medidas" class="eora-toggle-btn">' +
                                    '<span>Medidas do óculos</span>' +
                                    '<svg viewBox="0 0 24 24"><path d="M6 9l6 6 6-6"/></svg>' +
                                '</button>' +
                                '<div id="js-content-medidas" class="eora-toggle-content"></div>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                '</div>';

            setTimeout(function() {
                function eoraInjectActions() {
                    try {
                        var targetSkuForTryon = window.eoraCurrentSKU || (typeof LS !== 'undefined' && LS.variants && LS.variants[0] ? LS.variants[0].sku : '');
                        var href = window.location.href.toLowerCase();
                        var isSatellite = false;

                        if (href.indexOf('prata') > -1 || href.indexOf('cinza') > -1 || href.indexOf('luapc') > -1) { targetSkuForTryon = 'LUAPC'; isSatellite = true; }
                        else if (href.indexOf('preto') > -1 || href.indexOf('fosco') > -1 || href.indexOf('luaprep') > -1) { targetSkuForTryon = 'LUAPREP'; isSatellite = true; }
                        else if (href.indexOf('dourado') > -1 || href.indexOf('marrom') > -1 || href.indexOf('luadm') > -1) { targetSkuForTryon = 'LUADM'; isSatellite = true; }

                        var disponivel = true;
                        if (typeof mkfashion !== 'undefined') {
                            var isAv = mkfashion.isAvailable('69bbd36a44b548ccd0f965f4', targetSkuForTryon);
                            if (isAv === false) disponivel = false;
                        }

                        var provContainer = document.getElementById('eora-static-provador-container');
                        if (provContainer) {
                            provContainer.style.display = disponivel ? 'flex' : 'none';
                            var provBtn = provContainer.querySelector('.js-eora-static-btn');
                            if (provBtn) provBtn.onclick = function() {
                                if (isSatellite) {
                                    if (typeof mkfashion !== 'undefined') mkfashion.open('69bbd36a44b548ccd0f965f4', targetSkuForTryon);
                                } else {
                                    if (typeof abrirPopupChanel === 'function') abrirPopupChanel('tryon');
                                }
                            };
                        }
                    } catch (e) {
                        console.log('Eora error:', e);
                    }
                }

                window.eoraUpdateProvadorSku = function(newSku) {
                    window.eoraCurrentSKU = newSku;
                    eoraInjectActions();
                };

                var count = 0;
                var interval = setInterval(function() {
                    eoraInjectActions();
                    count++;
                    if (count > 100) clearInterval(interval);
                }, 1000);
                eoraInjectActions();
            }, 500);

            var header = document.querySelector('header, .header, #header');
            if (header && header.parentNode) {
                if (header.nextSibling) header.parentNode.insertBefore(hero, header.nextSibling);
                else header.parentNode.appendChild(hero);
            } else {
                document.body.insertBefore(hero, document.body.firstChild);
            }

            function fitHero() {
                var rect = hero.getBoundingClientRect();
                hero.style.setProperty('margin-left', (-rect.left) + 'px', 'important');
                hero.style.setProperty('width', '100vw', 'important');
                hero.style.setProperty('max-width', '100vw', 'important');
            }
            fitHero();
            window.addEventListener('resize', fitHero);

            setTimeout(function () {
                var btn = document.getElementById('eora-btn-detalhes');
                var descContent = document.getElementById('eora-hero-desc-content');
                if (btn && descContent) {
                    btn.addEventListener('click', function () {
                        if (descContent.style.display === 'none') {
                            descContent.style.display = 'block';
                            setTimeout(function () { descContent.style.opacity = '1'; }, 50);
                            btn.textContent = 'FECHAR O DETALHE';
                            setupSpecs();
                        } else {
                            descContent.style.opacity = '0';
                            setTimeout(function () { descContent.style.display = 'none'; }, 400);
                            btn.textContent = btnTx || 'VER DETALHES';
                        }
                    });

                    function setupSpecs() {
                        var nivelLuz = 'alta'; 
                        var foundBlocking = false;
                        var allTables = document.querySelectorAll('.js-product-description-base table');
                        allTables.forEach(function(t) {
                            if (foundBlocking) return;
                            var rows = Array.from(t.querySelectorAll('tr'));
                            rows.forEach(function(row) {
                                if (foundBlocking) return;
                                var cells = Array.from(row.querySelectorAll('td'));
                                var rowHasKey = false;
                                cells.forEach(function(td) {
                                    var txt = td.textContent.trim().toLowerCase();
                                    if (txt.indexOf('bloqueio') > -1 || txt === 'valor' || txt.indexOf('capacidade') > -1) rowHasKey = true;
                                });
                                if (rowHasKey) {
                                    cells.forEach(function(td) {
                                        var val = td.textContent.trim().toLowerCase();
                                        if (val.indexOf('baixa') > -1 || val === '1') { nivelLuz = 'baixa'; foundBlocking = true; }
                                        else if (val.indexOf('media') > -1 || val.indexOf('média') > -1 || val === '2') { nivelLuz = 'media'; foundBlocking = true; }
                                        else if (val.indexOf('alta') > -1 || val === '3') { nivelLuz = 'alta'; foundBlocking = true; }
                                    });
                                }
                            });
                        });

                        var medTable = getDados()['medidas_do_oculos'];
                        var medidasHtml = 'Medidas não informadas.';
                        if (medTable) {
                            var mCells = medTable.querySelectorAll('td');
                            var rawHtml = (mCells.length >= 2) ? mCells[1].innerHTML : (mCells.length === 1 ? mCells[0].innerHTML : '');
                            if (rawHtml) {
                                var tempDiv = document.createElement('div');
                                tempDiv.innerHTML = rawHtml;
                                var items = Array.from(tempDiv.querySelectorAll('li'));
                                if (items.length > 0) {
                                    var filtered = items.filter(function(li) {
                                        return li.textContent.toLowerCase().indexOf('altura total') === -1;
                                    }).slice(0, 3);
                                    medidasHtml = '<ul style="display:flex!important;justify-content:space-between!important;gap:12px!important;width:100%!important;padding:0!important;margin:0!important;list-style:none!important;">' + 
                                        filtered.map(function(li) { 
                                            return '<li style="flex:1!important;font-size:11px!important;color:#666!important;">' + li.innerHTML + '</li>';
                                        }).join('') + '</ul>';
                                } else { medidasHtml = rawHtml; }
                            }
                        }

                        var sLow = document.querySelector('.js-blocking-low');
                        var sMed = document.querySelector('.js-blocking-med');
                        var sHigh = document.querySelector('.js-blocking-high');
                        if (sLow) sLow.style.setProperty('background', (nivelLuz === 'baixa' || nivelLuz === 'media' || nivelLuz === 'alta' ? '#000' : '#efefef'), 'important');
                        if (sMed) sMed.style.setProperty('background', (nivelLuz === 'media' || nivelLuz === 'alta' ? '#000' : '#efefef'), 'important');
                        if (sHigh) sHigh.style.setProperty('background', (nivelLuz === 'alta' ? '#000' : '#efefef'), 'important');

                        var lLow = document.querySelector('.js-lbl-low');
                        var lMed = document.querySelector('.js-lbl-med');
                        var lHigh = document.querySelector('.js-lbl-high');
                        [lLow, lMed, lHigh].forEach(function(l) { if(l) { l.style.background = ''; l.style.color = ''; } });
                        var activeL = (nivelLuz === 'baixa') ? lLow : (nivelLuz === 'media' ? lMed : lHigh);
                        if (activeL) {
                            activeL.style.setProperty('background', '#000', 'important');
                            activeL.style.setProperty('color', '#fff', 'important');
                            activeL.style.setProperty('padding', '2px 8px', 'important');
                            activeL.style.setProperty('border-radius', '2px', 'important');
                        }

                        var mContent = document.getElementById('js-content-medidas');
                        if (mContent) mContent.innerHTML = medidasHtml;
                        var mToggle = document.getElementById('js-toggle-medidas');
                        if (mToggle && !mToggle.hasAttribute('data-init')) {
                            mToggle.setAttribute('data-init', 'true');
                            mToggle.addEventListener('click', function(e) {
                                e.preventDefault(); e.stopPropagation();
                                var isOpen = mContent.style.display === 'block';
                                mContent.style.display = isOpen ? 'none' : 'block';
                                this.classList.toggle('eora-open', !isOpen);
                            });
                        }
                    }
                }
            }, 200);
        }
        injectHero();

        window.abrirPopupChanel = function(mode) {
             var modal = document.getElementById('eora-pu-layer');
             if (modal) modal.classList.add('eora-pu-open');
        };
        
        document.body.style.setProperty('padding', '0', 'important');
        document.body.style.setProperty('margin', '0', 'important');
    }

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
    else init();
})();
