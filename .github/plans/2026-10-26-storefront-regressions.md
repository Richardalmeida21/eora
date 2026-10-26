# Correções da loja — Sobre e Vértice

- Sobre: HTML público só mostra introdução e fundadores. Reproduzido em PHP/Twig com Settings objeto: acessos dinâmicos `settings[...]` ocultam frase/galerias. Trocar por `attribute`, sem alterar nomes ou conteúdos salvos; verificar PHP real, Twig.js e storefront após deploy.
- Vértice: slugs antigos (`vertice`, `vertice1`, `vertice3`, `vertice4`, `vertice6`, `vertice-detog`) mudaram. A ordenação do tema depende deles. Manter aliases anteriores, incluir atuais e ligar referências aos IDs nativos dos produtos para sobreviver a novas mudanças de URL. Preservar nós/listeners/seleção e limitar à família correta.
- Still: galeria customizada usa 1024 × 1389 sem srcset; originais confirmados 2560 × 3472. Expor metadados nativos do produto em JSON e ajustar somente fotos principais da galeria customizada, mantendo thumbnails leves e fallback se o original falhar. Não adivinhar extensão nem inventar thumbnails CDN (1920/2048 retornam403).

Preservar a alteração local prévia de `vertice.html` (vídeo e descrição), não incluí-la no commit. Sem mudanças em uploads, dados de produtos ou configurações do personalizador.

- [x] Regressões RED/GREEN das três causas: Settings objeto em PHP/Twig 1.44.8, URLs atuais e IDs estáveis, seleção de originais com DPR 1/2/3 e fallback sem repetição.
- [x] QA no navegador com páginas reais e tamanhos desktop/mobile, seleção/navegação e erro do original. Sobre validada com PHP real e carrosséis; Vértice com os nove produtos atuais. CDN real confirmou originais 2560 × 3472 e carregamento apenas da foto visível.
- [ ] Revisão, testes relevantes, integrar na main e acompanhar deploy; conferir conteúdo publicado.

Validação local: 36 testes de Sobre/Twig e banners, suítes de ordem Vértice, qualidade das fotos, carrinho, links da descrição, layout/preview e performance passaram. Evidências de navegador em `C:/Temp/eora-regressions-20261026/` (`order-fixed.json`, `quality-helper-live-report.json`, capturas desktop/mobile).
