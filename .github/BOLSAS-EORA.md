# Bolsas Eora

Implementação local baseada no PDF **BRIEFING DE ESTRUTURA PARA PÁGINA DE BOLSAS DO SITE EORA — SET 2026**, com as alterações solicitadas: filtros por tag e galeria Quem usa sem 15 posições fixas.

## Estado

- Código implementado para a página fixa `/bolsas-eora/`.
- Nenhum envio FTP, push ou alteração no painel foi realizado.
- Validação local com Twig.js e Chromium. Isso não substitui o teste do parser e do editor da Nuvemshop.
- A prévia usa produtos e configurações demonstrativos, com imagens públicas de produtos da Eora. Nenhum dado de demonstração foi colocado no tema publicado.
- Os antigos campos Catálogo e banner 1–10 e as respectivas seções de produtos destacados foram removidos. Seus JPEGs-base não são mais usados pela página.
- `static/js/instatheme.js` restaura a integração já existente no arquivo com sufixo `instatheme-e17831ac275d2a8bf565d85c4d93021230.js`, usando o nome solicitado pelo editor da Nuvemshop.

## Configuração no painel

1. Crie uma página de conteúdo chamada **Bolsas Eora**, com a URL `/bolsas-eora/`.
2. Em **Personalizar layout → configurações avançadas → Bolsas Eora → Filtros por modelo**, adicione imagens e clique no lápis de cada imagem. Nos detalhes, o campo **Tag do produto** (a plataforma pode exibir **Link ao clicar na imagem**) recebe somente a tag: `maxivertice`, por exemplo. A imagem com tag vazia não aparece. Use uma tag por imagem, sem URL ou aspas. Arraste para ordenar e exclua para remover. A galeria exige `gallery_more_info = true` para abrir os campos adicionais.
3. No cadastro dos produtos, associe somente a tag específica de cada modelo. A seleção verifica a tag inteira, sem exigir categoria ou tag geral.
4. Em **Banners**, logo abaixo de **Filtros por modelo**, adicione as imagens. No campo **Link** de cada imagem, informe a tag do modelo, como `maxivertice`. Esse campo associa o banner ao modelo e não abre outra página. A mesma imagem atende computador e celular; proporção sugerida 1000 × 1300.
5. Arraste as imagens para ordenar. Sem modelo selecionado, aparece a primeira imagem válida da galeria. Ao selecionar um modelo, aparece a primeira imagem com a tag correspondente, ignorando maiúsculas/minúsculas e espaços nas pontas. Sem correspondência, ficam somente os produtos. As imagens antigas precisam ser cadastradas nessa nova galeria.
6. Configure **Best sellers** e seus produtos na seção de destaque **Bolsas Eora — Best sellers**.
7. Em **Quem usa**, edite título, subtítulo e link geral. Adicione, reordene ou exclua fotos. Cada foto pode ter seu próprio link; sem link próprio, utiliza o link geral.
8. Em **Banners de categorias**, configure imagens, título, descrição, botão e link no editor da galeria, como na home.
9. Confira o conteúdo completo na prévia da Nuvemshop antes de publicar o tema.

As galerias de modelos, Banners, Quem usa e categorias não declaram `gallery_max` nem cortam a lista no TPL. Eventuais limites do editor/plataforma continuam sendo aplicáveis. Best sellers respeita o limite nativo de produtos destacados.

## Layout

| Bloco | Computador | Celular |
|---|---|---|
| Modelos | 4 visíveis em faixa de até 960 px; fotos sem corte | 2 inteiros e parte do próximo; rolagem sem gradiente |
| Catálogo | 4 colunas; até 12 novos produtos por ação | 2 colunas; até 6 novos produtos por ação |
| Banner por modelo | Após 8 produtos, ocupa as duas colunas da direita e a altura de 2 linhas; antecipado em listas menores | Largura total entre os produtos, após os primeiros 4 ou ao final em listas menores |
| Best sellers | 4 produtos visíveis | 2 produtos e parte do próximo |
| Quem usa | 5 fotos quadradas; fundo branco | 2 fotos quadradas e parte da próxima, como no feed do rodapé |
| Categorias | 4 banners visíveis | 1 banner e parte do próximo |

Mostrar mais produtos conserva os itens carregados e acrescenta os próximos, sem duplicar o banner nem contá-lo como produto. A troca de modelo, o painel de filtros e o histórico atualizam produtos e banner juntos.

O clique em um modelo ou em Aplicar filtros rola ate os resultados, descontando a altura do cabecalho fixo e respeitando movimento reduzido. As fotos dos produtos, inclusive no hover, usam `object-fit: contain` para manter a imagem inteira. O banner usa `object-fit: cover` para preencher seu espaço. Somente o banner selecionado sai do template inerte para a grade; as demais imagens não carregam antecipadamente. A nitidez final depende da resolução do arquivo enviado.

## Consulta por tag e filtros gerais

- Ao abrir sem selecionar um modelo, o catalogo abaixo dos filtros reune os produtos de todas as tags configuradas nas imagens. Cada tag possui sua propria paginacao, as consultas alternam entre modelos e um produto com varias tags aparece uma vez. Nao e necessario cadastrar uma tag geral nem selecionar produtos nas secoes manuais para essa listagem.
- O clique no modelo mantém o visitante na campanha e atualiza `?tag=...`. Voltar/Avançar e links compartilháveis restauram a seleção. Ver todas as bolsas/Limpar filtros restaura a uniao das tags. Ordenacao continua vinculada ao modelo escolhido; filtros por caracteristicas e preco tambem funcionam em Todos os modelos.
- Ver todas as bolsas permanece visivel, inclusive na entrada sem filtro, com botao de 16 px e altura minima de 48 px. A rolagem conserva a barra de acoes abaixo do cabecalho fixo. Ordenacao aparece somente quando ha modelo selecionado.
- A listagem automática usa os modelos configurados, sem grades manuais. Sem modelos, a página informa que não há modelos disponíveis e conserva o primeiro banner, Best sellers e as galerias cadastradas.
- A consulta usa `store.search_url` com o termo entre aspas. A busca nativa pode incluir correspondências em outros campos; por isso, cada resultado é conferido contra `product.tags`, comparando a tag inteira (sem diferenciar maiúsculas/minúsculas; acentos são preservados).
- O card transforma as tags em um array JSON de textos no Twig, acessando `product_tag.tag`. A serializacao direta de `product.tags` na plataforma inclui detalhes internos e guarda o valor em `attributes.tag`, que tambem e aceito pelo JS para respostas anteriores mantidas em cache.
- Um `<template>` inerte, sem scripts, é acrescentado ao resultado da busca somente quando a consulta corresponde à tag de um modelo configurado. A apresentação e a paginação da busca normal permanecem intactas.
- O carregamento usa as URLs de paginação fornecidas pela plataforma, elimina IDs repetidos e limita cada ação a três requisições sequenciais. Se ainda houver páginas, o botão permite continuar; não existe um corte na primeira página de produtos.
- A página cancela consultas anteriores ao trocar de modelo, apresenta erro com opção de tentar novamente e só informa ausência definitiva de resultados depois de terminar a busca.
- O painel **Filtros** usa os mesmos modelos cadastrados no carrossel. Ocasiao, Tamanho, Cor, O que cabe, Textura e Ferragem aparecem somente conforme as tags reais dos produtos. A descoberta percorre todas as paginas dos modelos cadastrados ao abrir/trocar modelo no painel; nao cria opcoes a partir de variacoes ou de uma lista fixa. A tabela e as instrucoes estao em [BOLSAS-EORA-FILTROS.md](BOLSAS-EORA-FILTROS.md).
- Preco continua usando os parametros nativos da busca. As demais caracteristicas sao verificadas nos cards de cada pagina consultada, inclusive quando nenhum modelo foi escolhido. A consulta continua paginada e nao apresenta contagens da busca ampla como totais da campanha.
- O código usa somente consultas públicas da própria loja. Não exige token privado, backend externo ou download de todo o catálogo.

## Isolamento e publicação

- Arquivos novos: `snipplets/bolsas-eora/*.tpl`, `static/css/bolsas-eora.css`, `static/js/bolsas-eora.js`.
- Integrações: uma condição em `templates/page.tpl` e sua cópia em `snipplets/templates/page.tpl`; um include condicional em `templates/search.tpl`; configurações exclusivas em `settings.txt`, `defaults.txt` e `sections.txt`.
- CSS/JS da campanha carregam somente na página nova. As otimizacoes da previa estao nos dois snippets de video da home e na integracao de favoritos de `store.js.tpl`, descritas abaixo.
- **Um push na `main` dispara o FTP de produção**, conforme `.github/workflows/deploy.yml`. Não usar esse caminho para testar.
- O CSS e o JS principal usam `?v=20260918-6`; o script de opções usa `?v=20260918-5`. Publicar juntos configurações, `banners.tpl`, CSS, scripts e `index.tpl` para atualizar também as URLs do cache.
- Antes da publicação: verificar no editor que a galeria aceita e conserva a tag textual no segundo campo; testar o TPL real, as imagens configuradas, mais de uma página de resultados e os filtros habilitados na loja.
- Em envio manual, enviar primeiro os novos snippets/assets, depois configurações e por último os templates de entrada. Não ativar durante envio parcial.
- Para a correção do editor, enviar também `static/js/instatheme.js`, recarregar o painel e conferir se o 403 desse script desapareceu. Os testes locais não comprovam que o travamento do editor foi resolvido; a validação deve ser feita no painel real.

## Verificações locais

Arquivos de teste ficam dentro de `.github/`, pasta excluída do envio FTP atual. Dependências e imagens de teste ficam fora do tema.

```powershell
npm.cmd install --prefix C:/Temp/eora-bolsas-validation --no-audit --no-fund twig @playwright/test
$env:NODE_PATH = 'C:/Temp/eora-bolsas-validation/node_modules'
node .github/tests/bolsas-eora-harness.cjs --check
node --check static/js/bolsas-eora.js
node .github/tests/theme-editor-performance.cjs
node .github/tests/theme-preview-loading.cjs
git diff --check
```

O harness verifica a compilação/renderização dos novos TPLs, galerias com 20 itens, busca comum, paginação e 32 comparações de rotas anteriores/precedência. Não altera arquivos da loja.

Para repetir os testes visuais, o harness `--serve` usa seis imagens locais de demonstração em `C:/Temp/eora-bolsas-validation/assets/image-0.webp` até `image-5.webp`. Use imagens locais próprias nesse diretório. Configure `BE_VALIDATION_DIR` para outro diretório e `BE_BROWSER` para o executável Chromium de teste, se necessário.

```powershell
node .github/tests/bolsas-eora-harness.cjs --serve
# Em outro terminal com NODE_PATH configurado:
node .github/tests/bolsas-eora-browser.cjs
node .github/tests/bolsas-eora-all-models.cjs
node .github/tests/bolsas-eora-feedback.cjs
node .github/tests/bolsas-eora-banners.cjs
```

Testado: desktop/mobile, navegação das grades, listas com mais de 15 itens, tag exata versus prefixo/nome, seis páginas de resultados, deduplicação, filtros cor/preço, ordenação, histórico, zero resultados, erro/retry, páginas iniciais sem correspondências, troca rápida de modelo, fechamento por Escape, foco e ausência de overflow horizontal/erros JavaScript.

## Desempenho da previa do editor

Os videos dos snippets `home-franqueados.tpl` e `home-banner-video-horizontal.tpl` carregam o player quando ficam visiveis. A versao oculta por CSS nao carrega antecipadamente, e a reinicializacao nao duplica o player. Autoplay e reproducao por clique continuam disponiveis. Ha fallback por scroll/resize para navegadores sem IntersectionObserver.

Em `store.js.tpl`, a integracao dos favoritos passa a reagir a mudancas no DOM. A busca do modal a cada 100 ms e a busca do widget a cada segundo foram substituidas por observadores; o modo tela cheia, o reposicionamento no cabecalho e novas insercoes do aplicativo continuam atendidos.

Em `grid/item.tpl`, a descricao completa so acompanha o card nas paginas em que o JS extrai o resumo. Na home e nas paginas de conteudo, essa extracao ja estava desativada; deixar de incluir o HTML inerte nao muda o texto visivel. Categoria, busca e produtos relacionados conservam a descricao e o resumo. Em uma amostra publica da home com `?preview=true`, remover os 48 blocos inutilizados reduziu o HTML de 5.713.916 para 999.633 bytes (82,5%), preservando textos, links, imagens e dados de variantes. Isso mede o tamanho do HTML, nao o consumo de RAM do painel.

Em `layout.tpl`, `params.preview` impede somente o carregamento explicito de Clarity, TikTok e Martz durante a edicao. Na loja publica, os tres continuam carregando. `head_content`, scripts da plataforma, aplicativos de `store.assorted_js`, favoritos, quickshop, videos e popups permanecem disponiveis. `theme-preview-loading.cjs` renderiza os TPLs e verifica esses dois caminhos no Chromium com servicos externos simulados. Os testes de favoritos nao dependem mais de um `HEAD` anterior a correcao.

Essas alteracoes reduzem o trabalho do tema dentro da previa. Nao controlam o codigo interno do painel da Nuvemshop, os aplicativos externos ou o filtro de rede. O teste local nao comprova a resolucao de um Out of Memory no painel autenticado.
