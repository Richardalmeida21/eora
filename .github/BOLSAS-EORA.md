# Bolsas Eora

Implementação local baseada no PDF **BRIEFING DE ESTRUTURA PARA PÁGINA DE BOLSAS DO SITE EORA — SET 2026**, com as alterações solicitadas: filtros por tag e galeria Quem usa sem 15 posições fixas.

## Estado

- Código implementado para a página fixa `/bolsas-eora/`.
- Nenhum envio FTP, push ou alteração no painel foi realizado.
- Validação local com Twig.js e Chromium. Isso não substitui o teste do parser e do editor da Nuvemshop.
- A prévia usa produtos e configurações demonstrativos, com imagens públicas de produtos da Eora. Nenhum dado de demonstração foi colocado no tema publicado.
- Os 20 arquivos `static/bolsas_eora_*_banner*.jpg` são imagens-base brancas de 1 pixel para registrar os campos de imagem do editor. Não são fotos de demonstração e não exibem banners: o TPL exige `has_custom_image` após um upload do administrador.
- `static/js/instatheme.js` restaura a integração já existente no arquivo com sufixo `instatheme-e17831ac275d2a8bf565d85c4d93021230.js`, usando o nome solicitado pelo editor da Nuvemshop.

## Configuração no painel

1. Crie uma página de conteúdo chamada **Bolsas Eora**, com a URL `/bolsas-eora/`.
2. Em **Personalizar layout → configurações avançadas → Bolsas Eora → Filtros por modelo**, adicione imagens e clique no lápis de cada imagem. Nos detalhes, o campo **Tag do produto** (a plataforma pode exibir **Link ao clicar na imagem**) recebe somente a tag: `maxivertice`, por exemplo. A imagem com tag vazia não aparece. Use uma tag por imagem, sem URL ou aspas. Arraste para ordenar e exclua para remover. A galeria exige `gallery_more_info = true` para abrir os campos adicionais.
3. No cadastro dos produtos, associe somente a tag específica de cada modelo. A seleção verifica a tag inteira, sem exigir categoria ou tag geral.
4. Em **Catálogo e banner 1–10**, ative os blocos desejados. Em **Organização dos produtos em destaque**, selecione e ordene os produtos nas seções **Bolsas Eora — Catálogo N** e **Bolsas Eora — Dividido N**. Os blocos divididos usam os primeiros quatro produtos selecionados.
5. Envie a imagem desktop de cada banner ativado; a versão mobile é opcional. Preencha título, subtítulo e link. Um bloco dividido sem imagem desktop fica oculto. Se não houver produtos selecionados, o banner ocupa a largura disponível.
6. Configure **Best sellers** e seus produtos na seção de destaque **Bolsas Eora — Best sellers**.
7. Em **Quem usa**, edite título, subtítulo e link geral. Adicione, reordene ou exclua fotos. Cada foto pode ter seu próprio link; sem link próprio, utiliza o link geral.
8. Em **Banners de categorias**, configure imagens, título, descrição, botão e link no editor da galeria, como na home.
9. Confira o conteúdo completo na prévia da Nuvemshop antes de publicar o tema.

As galerias de modelos, Quem usa e categorias não declaram `gallery_max` nem cortam a lista no TPL. Eventuais limites do editor/plataforma continuam sendo aplicáveis. As seções de produtos também respeitam o limite nativo de produtos destacados.

## Layout

| Bloco | Computador | Celular |
|---|---|---|
| Modelos | 4 visíveis em faixa de até 960 px; fotos sem corte | 2 inteiros e parte do próximo; rolagem sem gradiente |
| Catálogo | 4 colunas × 3 linhas | 2 colunas × 3 linhas |
| Dividido | 2 × 2 produtos + banner com a mesma altura | Banners em carrossel, com parte do próximo quando houver mais de um |
| Best sellers | 4 produtos visíveis | 2 produtos e parte do próximo |
| Quem usa | 5 fotos quadradas; fundo branco | 2 fotos quadradas e parte da próxima, como no feed do rodapé |
| Categorias | 4 banners visíveis | 1 banner e parte do próximo |

As grades possuem navegação quando houver mais de 12 produtos no desktop ou 6 no mobile. Assim os produtos adicionais permanecem acessíveis. Os dez pares catálogo/banner são independentes e desativáveis.

O clique em um modelo ou em Aplicar filtros rola ate os resultados, descontando a altura do cabecalho fixo e respeitando movimento reduzido. As fotos dos produtos, inclusive no hover, usam `object-fit: contain` para manter a imagem inteira. Produtos e galerias oferecem fontes de ate 1024 px; filtros usam fontes responsivas de ate 640 px. A nitidez final depende da resolucao do arquivo enviado. No mobile, os banners existentes sao agrupados sem duplicar imagens; ao voltar ao desktop, recuperam sua posicao original.

## Consulta por tag e filtros gerais

- Ao abrir sem selecionar um modelo, o catalogo abaixo dos filtros reune os produtos de todas as tags configuradas nas imagens. Cada tag possui sua propria paginacao, as consultas alternam entre modelos e um produto com varias tags aparece uma vez. Nao e necessario cadastrar uma tag geral nem selecionar produtos nas secoes manuais para essa listagem.
- O clique no modelo mantém o visitante na campanha e atualiza `?tag=...`. Voltar/Avançar e links compartilháveis restauram a seleção. Ver todas as bolsas/Limpar filtros restaura a uniao das tags. Ordenacao e filtros gerais continuam vinculados ao modelo escolhido.
- Com modelos configurados, a listagem automatica substitui as grades manuais do catalogo; os banners, produtos dos blocos divididos, Best sellers e galerias permanecem. Sem modelos configurados, as grades manuais e seus controles continuam funcionando.
- A consulta usa `store.search_url` com o termo entre aspas. A busca nativa pode incluir correspondências em outros campos; por isso, cada resultado é conferido contra `product.tags`, comparando a tag inteira (sem diferenciar maiúsculas/minúsculas; acentos são preservados).
- O card transforma as tags em um array JSON de textos no Twig, acessando `product_tag.tag`. A serializacao direta de `product.tags` na plataforma inclui detalhes internos e guarda o valor em `attributes.tag`, que tambem e aceito pelo JS para respostas anteriores mantidas em cache.
- Um `<template>` inerte, sem scripts, é acrescentado ao resultado da busca somente quando a consulta corresponde à tag de um modelo configurado. A apresentação e a paginação da busca normal permanecem intactas.
- O carregamento usa as URLs de paginação fornecidas pela plataforma, elimina IDs repetidos e limita cada ação a três requisições sequenciais. Se ainda houver páginas, o botão permite continuar; não existe um corte na primeira página de produtos.
- A página cancela consultas anteriores ao trocar de modelo, apresenta erro com opção de tentar novamente e só informa ausência definitiva de resultados depois de terminar a busca.
- O botão flutuante **Filtros** carrega `product_filters` da busca: preço, marca, variações e campos personalizados habilitados no administrador. Envia os parâmetros de filtro de volta ao servidor, preserva a tag e confere novamente a correspondência exata. Os modelos também aparecem nesse painel.
- As opções de filtros nativos vêm da busca ampla; uma opção pode ficar sem resultados após a conferência exata da tag. Contagens dessa busca ampla não são apresentadas como totais da campanha.
- O código usa somente consultas públicas da própria loja. Não exige token privado, backend externo ou download de todo o catálogo.

## Isolamento e publicação

- Arquivos novos: `snipplets/bolsas-eora/*.tpl`, `static/css/bolsas-eora.css`, `static/js/bolsas-eora.js`.
- Integrações: uma condição em `templates/page.tpl` e sua cópia em `snipplets/templates/page.tpl`; um include condicional em `templates/search.tpl`; configurações exclusivas em `settings.txt`, `defaults.txt` e `sections.txt`.
- CSS/JS da campanha carregam somente na página nova. As otimizacoes da previa estao nos dois snippets de video da home e na integracao de favoritos de `store.js.tpl`, descritas abaixo.
- **Um push na `main` dispara o FTP de produção**, conforme `.github/workflows/deploy.yml`. Não usar esse caminho para testar.
- Antes da publicação: verificar no editor que a galeria aceita e conserva a tag textual no segundo campo; testar o TPL real, as imagens configuradas, mais de uma página de resultados e os filtros habilitados na loja.
- Em envio manual, enviar primeiro os novos snippets/assets, depois configurações e por último os templates de entrada. Não ativar durante envio parcial.
- Para a correção do editor, enviar também `static/js/instatheme.js` e os 20 JPEGs-base, recarregar o painel e conferir se o 403 desse script desapareceu. Os testes locais não comprovam que o travamento do editor foi resolvido; a validação deve ser feita no painel real.

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
```

Testado: desktop/mobile, navegação das grades, listas com mais de 15 itens, tag exata versus prefixo/nome, seis páginas de resultados, deduplicação, filtros cor/preço, ordenação, histórico, zero resultados, erro/retry, páginas iniciais sem correspondências, troca rápida de modelo, fechamento por Escape, foco e ausência de overflow horizontal/erros JavaScript.

## Desempenho da previa do editor

Os videos dos snippets `home-franqueados.tpl` e `home-banner-video-horizontal.tpl` carregam o player quando ficam visiveis. A versao oculta por CSS nao carrega antecipadamente, e a reinicializacao nao duplica o player. Autoplay e reproducao por clique continuam disponiveis. Ha fallback por scroll/resize para navegadores sem IntersectionObserver.

Em `store.js.tpl`, a integracao dos favoritos passa a reagir a mudancas no DOM. A busca do modal a cada 100 ms e a busca do widget a cada segundo foram substituidas por observadores; o modo tela cheia, o reposicionamento no cabecalho e novas insercoes do aplicativo continuam atendidos.

Em `grid/item.tpl`, a descricao completa so acompanha o card nas paginas em que o JS extrai o resumo. Na home e nas paginas de conteudo, essa extracao ja estava desativada; deixar de incluir o HTML inerte nao muda o texto visivel. Categoria, busca e produtos relacionados conservam a descricao e o resumo. Em uma amostra publica da home com `?preview=true`, remover os 48 blocos inutilizados reduziu o HTML de 5.713.916 para 999.633 bytes (82,5%), preservando textos, links, imagens e dados de variantes. Isso mede o tamanho do HTML, nao o consumo de RAM do painel.

Em `layout.tpl`, `params.preview` impede somente o carregamento explicito de Clarity, TikTok e Martz durante a edicao. Na loja publica, os tres continuam carregando. `head_content`, scripts da plataforma, aplicativos de `store.assorted_js`, favoritos, quickshop, videos e popups permanecem disponiveis. `theme-preview-loading.cjs` renderiza os TPLs e verifica esses dois caminhos no Chromium com servicos externos simulados. Os testes de favoritos nao dependem mais de um `HEAD` anterior a correcao.

Essas alteracoes reduzem o trabalho do tema dentro da previa. Nao controlam o codigo interno do painel da Nuvemshop, os aplicativos externos ou o filtro de rede. O teste local nao comprova a resolucao de um Out of Memory no painel autenticado.
