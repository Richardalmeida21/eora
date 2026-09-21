# Design QA — banners da página Bolsas Eora

## Evidências

- Referência fornecida: `C:\Users\rcalmeida\Downloads\WhatsApp Image 2026-09-21 at 10.30.21.jpeg` — 1152 × 2048 px. É uma foto de monitor e foi usada como evidência do problema de proporção, não como captura de fidelidade visual.
- Implementação desktop: `C:\Temp\eora-bolsas-validation\banners-by-model-1440.png` — captura do grid com 1354 × 2502 px, viewport 1440 × 1000, device scale factor 1.
- Implementação mobile: `C:\Temp\eora-bolsas-validation\banners-by-model-390.png` — captura do grid com 366 × 1908 px, viewport 390 × 1000, device scale factor 1.
- Comparação combinada: `C:\Temp\eora-bolsas-validation\design-qa-comparison.png` — 1600 × 1100 px.
- Estado avaliado: filtro `maxivertice` com dois banners vinculados à mesma tag. O cenário Todos com três banners marcados também foi coberto pelo teste automatizado.
- Referência adicional do CTA: captura anexada na conversa com o botão flutuante da home, faixa escura translúcida, texto à esquerda e seta diagonal à direita.
- Implementação do CTA: `C:\Temp\eora-bolsas-validation\desktop-split.png`, captura do banner no estado Todos. O fixture preenche também o campo Título, por isso mostra um título acima da faixa; no cadastro real com Título vazio aparece somente o Botão.

As capturas têm enquadramentos e conteúdos diferentes: a referência é uma fotografia da loja, enquanto a implementação é uma captura limpa do harness com dados de teste. Por isso, a comparação é estrutural e não recebeu normalização de densidade.

## Verificação das superfícies

- Tipografia: sem alteração; preserva os estilos existentes do tema.
- Espaçamento e layout: aprovado. No desktop, banners sucessivos alternam direita/esquerda. A base de cada banner coincide com a base da imagem dos produtos da segunda linha e não inclui a área de nome/preço. No mobile, cada banner ocupa a largura do grid e entra entre grupos de produtos.
- Cores e tokens: sem alteração.
- CTA do banner: aprovado. Reutiliza os tokens `--banner-floating-background` e `--banner-floating-text` da home, largura máxima de 440 px, padding de 16 px, blur de 8 px, texto de 16 px/500 com 3,2 px de espaçamento e o mesmo símbolo `#chevron-diagonal` de 12 px. A seta agora é sempre renderizada com `href` e `xlink:href`, inclusive durante a migração do cadastro.
- Imagens e recorte dos banners: aprovado. O banner carrega diretamente o arquivo original, sem `srcset` de 480/640 px, e usa `object-fit: contain` centralizado. A imagem mantém a proporção inteira, sem zoom, distorção ou recorte; sobras de proporção recebem o fundo `#f3f3f3`. A captura atualizada está em `C:\Temp\eora-bolsas-validation\desktop-split.png`.
- Filtros de modelo: aprovado. Todos os cards usam base `#eee` e `object-fit: contain`, mantendo a imagem inteira, sem zoom ou corte. A captura desktop pós-ajuste está em `C:\Temp\eora-bolsas-validation\desktop.png`.
- Conteúdo e textos: sem alteração.

## Interações verificadas

- Todos exibe apenas os banners cuja **Descrição** contém `,todos` depois da tag.
- Um modelo exibe todos os banners que possuem a mesma tag antes da vírgula no campo **Descrição**.
- O Link é somente o destino de navegação e torna toda a imagem clicável. Título, Botão e Cor continuam disponíveis para o conteúdo sobre o banner; a Descrição fica reservada à configuração do filtro e não é exibida.
- Cadastros antigos com Descrição vazia continuam usando Link como tag e Botão `SIM` como Todos até serem migrados.
- Banners alternam entre direita e esquerda no desktop.
- Paginação, troca de modelo, histórico, redimensionamento e painel lateral reposicionam os banners sem duplicação.
- Galeria vazia e reordenação não geram erros.
- Nenhum erro JavaScript foi registrado nos cenários testados.
- O CTA foi verificado em 1440, 768, 390 e 320 px; ocupa até 440 px no desktop e a largura disponível com margens de 16 px no mobile.
- Ordenar por fica disponível em Todos; preço decrescente foi verificado sobre 29 produtos agregados de quatro tags, em desktop e mobile, sem duplicação e com persistência na URL.

## Achados

- P0: nenhum.
- P1: nenhum.
- P2: nenhum dentro do escopo da alteração.
- Diferenças esperadas: imagens, textos e dimensões dos cards do harness não são os dados reais da loja; a fotografia de referência também contém perspectiva e interferência do monitor.

## Histórico da comparação

1. Referência inicial: o banner ocupava a altura de duas linhas completas de cards, incorporando visualmente o espaço de nome/preço da segunda linha.
2. Ajuste: a altura passou a encerrar junto da segunda imagem de produto, e múltiplos banners passaram a usar posições alternadas.
3. Comparação pós-ajuste: a captura combinada confirma o limite inferior correto e a alternância dos dois banners do modelo.
4. Ajuste do CTA: o botão simples foi substituído pela mesma composição visual do botão flutuante da home. A captura pós-ajuste confirma largura, espaçamento, tipografia e seta; os valores computados também foram validados no navegador.
5. Ajuste final: os filtros voltaram a `contain` para preservar a imagem inteira sobre uma base única `#eee`; a seta passou a ser incondicional no CTA; e Ordenar por foi liberado e validado no estado Todos com ordenação global.
6. Ajuste de qualidade: removidas as variantes redimensionadas de 480/640/1920 px do banner. A captura pós-ajuste confirma o arquivo inteiro centralizado, sem corte; o navegador computou `object-fit: contain` e `object-position: 50% 50%` em 1440 px, e os mesmos estados passaram em 768, 390 e 320 px.

final result: passed
