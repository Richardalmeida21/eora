# Design QA — página Bolsas Eora

## Clone Óculos Eora — 23/09/2026

### Evidências

- Fonte visual: `C:\Temp\eora-bolsas-validation\mobile.png`, página Bolsas Eora existente, captura em 390 px CSS e device scale factor 1.
- Implementação: `C:\Temp\eora-bolsas-validation\oculos-eora-mobile.png`, página Óculos Eora, captura em 390 px CSS e device scale factor 1.
- Comparação normalizada: `C:\Temp\eora-bolsas-validation\oculos-eora-comparison.png`, recorte superior de 844 px das duas páginas lado a lado, sem redimensionamento.
- Comparação focada: `C:\Temp\eora-bolsas-validation\oculos-eora-filters-comparison.png`, filtros abertos em 390 × 844 px.
- Estado: catálogo Todos, ordenação Destaques, filtro fechado na comparação principal e aberto na comparação focada.

### Superfícies verificadas

- Tipografia: mesma família, pesos, tamanhos, caixa alta e hierarquia. Mudam somente os substantivos e nomes de modelos solicitados.
- Espaçamento e layout: mesma largura, grid de duas colunas, toolbar, carrossel, controles, cards e botão flutuante; sem overflow horizontal.
- Cores e tokens: idênticos, pois a nova página reutiliza a folha de estilos de Bolsas Eora.
- Imagens: estrutura, proporções, carregamento progressivo e galerias idênticos. Os fixtures usam imagens de bolsas apenas como dados de demonstração; a produção consumirá as imagens reais dos óculos.
- Conteúdo: Todos os óculos, IRIS/NOVA/ASTRA/LUNA/LUAR/ONYX/SPARKY e as sete famílias de facetas aparecem na ordem definida. Preço permanece no final.
- Interações: categoria manual, lotes de 24, carregamento automático, modelo, ordenação, filtros combinados, limpar, histórico, Escape e retorno de foco passaram no navegador sem erros JavaScript.

### Achados

- P0: nenhum.
- P1: nenhum.
- P2: nenhum.
- Diferenças esperadas: nomes, facetas, quantidade inicial e imagens de demonstração são dados de conteúdo, não divergências visuais.

final result: passed

---

## Carrossel de imagens nos cards — 22/09/2026

### Evidências

- Verdade visual: `/workspace/scratch/eaaee0a7de06/upload/5164edf2-78eb-4c1c-93b0-34283fb686d6.mov`, vídeo mobile de 384 × 848 px. O frame de comparação está em `/workspace/scratch/eaaee0a7de06/gallery-preview/reference-carousel.jpg`.
- Implementação renderizada: `http://terminal.local:4173/`, prévia aberta e capturada no navegador em um iframe de 384 × 848 CSS px, `devicePixelRatio: 1`, estado da primeira galeria na foto `2 / 3`.
- Comparação combinada: referência e implementação foram renderizadas lado a lado na mesma página do navegador. O chrome do Instagram/Safari presente na referência foi desconsiderado; a região comparada foi a grade com dois cards, fotos e contador.
- Dimensões normalizadas: fonte 384 × 848 px; implementação 384 × 848 CSS px e 384 × 848 px na captura do iframe. Não houve redimensionamento de densidade.

### Verificação das superfícies

- Tipografia: o contador mantém texto pequeno, preto e alinhado ao canto superior direito como na referência. Nomes e preços preservam a tipografia já usada pela EORA, em vez de copiar a identidade da loja de referência.
- Espaçamento e layout: a grade permanece com duas colunas no mobile. Cada foto ocupa integralmente a área existente do card, sem alterar altura, espaçamento, nome ou preço.
- Cores e tokens: mantidos fundo claro, texto preto e o tratamento neutro existente na página. O contador usa fundo branco translúcido discreto para continuar legível sobre fotos claras ou escuras.
- Imagens: `object-fit: contain` preserva a bolsa inteira. Somente a primeira foto tem `src/srcset` no carregamento inicial; fotos adjacentes são hidratadas quando há interação.
- Conteúdo: contador no formato `posição / total`, usando a quantidade real de fotos cadastradas no produto.

### Interações verificadas

- Navegação pela seta seguinte e anterior no desktop atualizou `1 / 3 → 2 / 3 → 3 / 3` e retornou para `2 / 3`.
- Navegação por teclado com `ArrowRight` atualizou o slide ativo e o contador.
- No mobile, as setas ficam ocultas e a trilha usa rolagem nativa horizontal com `scroll-snap`, preservando o gesto mostrado no vídeo.
- O carregamento inicial manteve quatro imagens secundárias sem `src` em dois cards; ao interagir apenas com o primeiro card, somente suas imagens adjacentes foram carregadas.
- Nenhum erro ou aviso de `terminal.local` foi registrado no console.

### Achados

- P0: nenhum.
- P1: nenhum.
- P2: nenhum.
- Diferenças esperadas: imagens, textos, preços e identidade visual permanecem os da EORA; a referência foi usada somente para reproduzir o comportamento do carrossel e o contador.

### Histórico da comparação

1. A implementação inicial foi renderizada com duas colunas e contador, mantendo o layout atual da EORA.
2. A prévia foi normalizada em 384 × 848 px e colocada lado a lado com um frame do vídeo na mesma página.
3. O estado `2 / 3`, as setas desktop, o teclado e a hidratação progressiva foram testados após a comparação visual, sem novos desvios P0/P1/P2.

final result: passed

---

## Revisão dos controles e consentimento mobile — 21/09/2026

### Evidências

- Referências visuais: `/workspace/scratch/eaaee0a7de06/upload/IMG_1697.jpeg` e `/workspace/scratch/eaaee0a7de06/upload/IMG_1698.jpeg`, capturas Retina de um iPhone após a primeira publicação. A interface do navegador foi desconsiderada.
- Alvo de implementação: viewport de 393 CSS px, estado `Todas as bolsas`, filtro fechado.
- Implementação alterada: `static/css/bolsas-eora.css` e `snipplets/bolsas-eora/index.tpl`, restrita à página de bolsas, com cache atualizado.
- Captura renderizada pós-alteração: indisponível. O navegador remoto recusou a URL local de preview e a ferramenta local de navegador não está instalada neste ambiente.

### Achados

- P0: nenhum identificado na inspeção do código.
- P1: nenhum identificado na inspeção do código.
- P2 bloqueante para aprovação visual: falta a captura renderizada pós-alteração na mesma largura da referência.
- Tipografia e cores: mantidas; o rótulo visual “Ordenar por” é ocultado somente no mobile e preservado semanticamente no HTML.
- Espaçamento e layout: a toolbar usa duas colunas iguais; botão e select passam a 42 px de altura. O botão flutuante passa de 220 × 52 px para até 180 × 44 px.
- Imagens e conteúdo: sem alteração.
- Compatibilidade Nuvemshop: o botão flutuante recebe a classe nativa `js-btn-fixed-bottom`, já usada pelo tema para acrescentar a altura real do banner de cookies e restaurar a posição após o aceite. Nenhum JavaScript novo foi adicionado.

### Histórico da iteração

1. A primeira publicação confirmou os dots compactos e colocou os controles na mesma linha.
2. Os novos prints mostraram larguras diferentes, rótulo “Ordenar por” desnecessário e sobreposição do botão flutuante sobre “Entendi”.
3. A segunda correção iguala as colunas, oculta o rótulo no mobile, reduz o botão flutuante e integra seu deslocamento ao mecanismo nativo de cookies da Nuvemshop.

### Checklist para liberação

- Renderizar a rota `/bolsas-eora` com o CSS alterado em 393 × 852 CSS px.
- Confirmar ausência de overflow e larguras iguais entre “Ver todas as bolsas” e o select, sem o texto “Ordenar por”.
- Confirmar os dots com 8 px e o ativo com 10 px, sem herdar fundo ou tamanho do tema.
- Com o consentimento aberto, confirmar o botão “Filtros” acima do banner e o link “Entendi” totalmente clicável.
- Após aceitar os cookies, confirmar que o botão volta à margem inferior normal.

final result: blocked

---

## Revisão mobile, categoria e carregamento — 21/09/2026

### Evidências

- Referência: captura mobile anexada pelo usuário na conversa, com 738 × 1600 px. A área do navegador foi desconsiderada; foram comparados toolbar, catálogo, grade e botão flutuante.
- Implementação: `C:\Temp\eora-bolsas-validation\mobile.png`, viewport 390 × 844 CSS px, device scale factor 1, estado Todos e filtro fechado.
- Filtros: `C:\Temp\eora-bolsas-validation\mobile-filters.png`, viewport 390 × 844 CSS px, painel aberto e uma cor selecionada.
- Breakpoints adicionais: 320, 767, 768, 1440 e 1920 px, capturados e verificados pelo teste de feedback responsivo.

### Verificação

- Toolbar mobile: aprovada. Em 390 px, “Ver todas as bolsas” e “Ordenar por” ocupam linhas completas, sem compressão ou overflow; select e botão têm 52 px de altura.
- Catálogo: aprovado. Mantém duas colunas no mobile, espaçamento consistente entre cards e tipografia legível sem ampliar excessivamente os nomes.
- Controles: aprovados. Setas e fechar têm pelo menos 44 px; selects, ações primárias e botão flutuante têm pelo menos 52 px; dots conservam aparência compacta com área de toque de 28 px.
- Filtros: aprovados. O diálogo vira bottom sheet, respeita 90dvh e safe area, preserva cabeçalho e rodapé de ações, e não apresenta overflow horizontal.
- Botão flutuante: aprovado. Largura limitada a 220 px, margem reservada para a barra social e posicionamento com safe area.
- Carregamento: aprovado. O primeiro lote contém até 24 produtos em todas as larguras; o lote seguinte é carregado por `IntersectionObserver` quando o botão se aproxima da viewport, mantendo o botão como fallback acessível.
- Categoria: aprovada. O estado Todos consome a categoria configurada, preserva a ordem manual do painel e continua além de 40 produtos em páginas de 24. Filtros por modelo continuam usando as tags existentes.
- Desempenho: aprovado. O feed interno da categoria devolve somente os cartões necessários; consultas de facetas têm concorrência máxima de três, cache e retomada de requisições abortadas.

### Achados desta revisão

- P0: nenhum.
- P1: nenhum.
- P2: nenhum.
- Diferenças esperadas: a implementação local usa produtos e imagens de demonstração; a referência mostra dados reais e a interface do navegador do aparelho.

final result: passed

---

## Revisão anterior — banners

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
- Imagens e recorte dos banners: aprovado. O banner carrega diretamente o arquivo original, sem `srcset` de 480/640 px, e usa `object-fit: cover` centralizado. A imagem preenche toda a área sem distorção ou faixas vazias; quando a proporção do bloco difere do arquivo, ocorre um recorte central nas bordas. A captura atualizada está em `C:\Temp\eora-bolsas-validation\desktop-split.png`.
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
6. Ajuste de qualidade: removidas as variantes redimensionadas de 480/640/1920 px do banner. O banner usa o arquivo original com `object-fit: cover` e `object-position: 50% 50%`, preenchendo o bloco em 1440, 768, 390 e 320 px.

final result: passed
