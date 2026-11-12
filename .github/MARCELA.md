# Favoritos da Marcela

Página `/favoritosdamarcela/`, conforme briefing de outubro/2026. As configurações ficam em **Favoritos da Marcela**, no menu principal do editor do tema.

## Versão antiga no ar durante a preparação

- Nova versão: `/favoritosdamarcela/`.
- Versão antiga da campanha: `/favoritosdamarcela/?marcela_antiga=1`.
- Enquanto **Ativar nova versão no menu** estiver desmarcado, os links e imagens do menu apontam para a versão antiga. A nova não é indexada enquanto estiver em preparação.
- Quando estiver pronta, marque a opção e publique: o menu passa a apontar para o endereço normal. O endereço antigo continua disponível para conferência; removê-lo definitivamente será uma ação posterior.

## Cadastro

1. **Banner principal:** primeira foto das galerias desktop e mobile, ou vídeo MP4/Vimeo/YouTube. Foto desktop 2400 × 800 px; mobile 1600 × 2000 px. O vídeo respeita redução de movimento e tem botão reproduzir/pausar. Sem nova foto, mantém o banner da campanha original.
2. **Categorias visuais:** até 15 slots opcionais. Ative o slot e informe foto, nome e tag exata. Descrição, foto mobile, ordem e link são opcionais. O clique filtra o catálogo; o link é utilizado ao abrir em nova aba. São 3 categorias desktop, com continuação quando há mais de 3, e 2 mobile.
3. **Catálogo:** em Organização dos produtos em destaque, selecione e ordene os produtos de **Favoritos da Marcela — Catálogo 1 a 10**. Ative os respectivos slots no editor. Slots seguem a ordem numérica; a ordem dos produtos dentro do slot segue a seleção. Produtos repetidos aparecem uma vez. Começa com 12 desktop/6 mobile; Mostrar mais adiciona outras 3 fileiras.
4. **Shop the look:** até 10 fotos opcionais, com ordem, título e botão. Use imagens quadradas de 1600 × 1600 px. Em Organização dos produtos em destaque, cadastre **Favoritos da Marcela — Look 1 a 10**. A janela exibe somente os dois primeiros produtos, na ordem escolhida. Sem foto ou produtos, o look fica oculto.
5. **Conteúdos da Marcela:** até 10 fotos/GIFs opcionais de 1600 × 2400 px, com título acima, descrição e botão com link abaixo. Há 4 itens desktop com continuação e 1 mobile. Usa o arquivo original para preservar GIFs.

Cada galeria de foto usa apenas o primeiro arquivo. As fotos mobile são opcionais; sem elas, reutiliza a versão desktop. Os carrosséis de fotos usam ordem numérica crescente; em empate, permanece a ordem dos slots.

## Conteúdo anterior

Sem nenhum catálogo novo ativo, mantém a seleção dos quatro blocos de produtos da Página de campanha 4. A opção **Usar somente o catálogo abaixo** permite desativar esse fallback e deixar o catálogo vazio deliberadamente. Configurações antigas continuam preservadas.

Looks e conteúdos não têm imagens fictícias na loja: permanecem ocultos até serem cadastrados. A prévia local usa fotos reais da página atual apenas para demonstrar esses componentes; esse conteúdo demonstrativo não é enviado para o tema.

## Verificação local

- `node .github/tests/marcela-browser.cjs`: Twig real, configurações, fontes legadas, paginação, categorias, filtros, ordenação, histórico, looks, vídeo, GIF e layouts desktop/mobile.
- `node .github/tests/marcela-harness.cjs`: prévia local na porta 4178. Usa arquivos de validação em `C:/Temp/eora-marcela-validation` (configurável com `MARCELA_VALIDATION_DIR`).
- Regressão Best Sellers: harness `--check --serve`, `best-sellers-browser.cjs`, `best-sellers-category.cjs`.

Os testes de navegador usam as dependências já instaladas em `C:/Temp/eora-bolsas-validation/node_modules` via `NODE_PATH` e o Chromium local. Nenhum endpoint de compra ou checkout é chamado.
