# Design QA — banners da página Bolsas Eora

## Evidências

- Referência fornecida: `C:\Users\rcalmeida\Downloads\WhatsApp Image 2026-09-21 at 10.30.21.jpeg` — 1152 × 2048 px. É uma foto de monitor e foi usada como evidência do problema de proporção, não como captura de fidelidade visual.
- Implementação desktop: `C:\Temp\eora-bolsas-validation\banners-by-model-1440.png` — captura do grid com 1354 × 2502 px, viewport 1440 × 1000, device scale factor 1.
- Implementação mobile: `C:\Temp\eora-bolsas-validation\banners-by-model-390.png` — captura do grid com 366 × 1908 px, viewport 390 × 1000, device scale factor 1.
- Comparação combinada: `C:\Temp\eora-bolsas-validation\design-qa-comparison.png` — 1600 × 1100 px.
- Estado avaliado: filtro `maxivertice` com dois banners vinculados à mesma tag. O cenário Todos com três banners marcados também foi coberto pelo teste automatizado.

As capturas têm enquadramentos e conteúdos diferentes: a referência é uma fotografia da loja, enquanto a implementação é uma captura limpa do harness com dados de teste. Por isso, a comparação é estrutural e não recebeu normalização de densidade.

## Verificação das superfícies

- Tipografia: sem alteração; preserva os estilos existentes do tema.
- Espaçamento e layout: aprovado. No desktop, banners sucessivos alternam direita/esquerda. A base de cada banner coincide com a base da imagem dos produtos da segunda linha e não inclui a área de nome/preço. No mobile, cada banner ocupa a largura do grid e entra entre grupos de produtos.
- Cores e tokens: sem alteração.
- Imagens e recorte: aprovado. Mantido `object-fit: cover`; a altura agora é calculada a partir do card da primeira linha, da imagem da segunda linha e do espaçamento entre linhas.
- Conteúdo e textos: sem alteração.

## Interações verificadas

- Todos exibe apenas os banners cujo novo campo individual **Filtro do banner** contém `| todos` depois da tag.
- Um modelo exibe todos os banners que possuem a mesma tag no campo **Filtro do banner**.
- O Link é novamente um destino de navegação e torna toda a imagem clicável. Título, Descrição, Botão e Cor continuam disponíveis para o conteúdo sobre o banner.
- Cadastros antigos sem o novo campo continuam usando Link como tag e Botão `SIM` como Todos até serem migrados.
- Banners alternam entre direita e esquerda no desktop.
- Paginação, troca de modelo, histórico, redimensionamento e painel lateral reposicionam os banners sem duplicação.
- Galeria vazia e reordenação não geram erros.
- Nenhum erro JavaScript foi registrado nos cenários testados.

## Achados

- P0: nenhum.
- P1: nenhum.
- P2: nenhum dentro do escopo da alteração.
- Diferenças esperadas: imagens, textos e dimensões dos cards do harness não são os dados reais da loja; a fotografia de referência também contém perspectiva e interferência do monitor.

## Histórico da comparação

1. Referência inicial: o banner ocupava a altura de duas linhas completas de cards, incorporando visualmente o espaço de nome/preço da segunda linha.
2. Ajuste: a altura passou a encerrar junto da segunda imagem de produto, e múltiplos banners passaram a usar posições alternadas.
3. Comparação pós-ajuste: a captura combinada confirma o limite inferior correto e a alternância dos dois banners do modelo.

final result: passed
