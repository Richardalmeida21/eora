# Best Sellers Eora — briefing outubro de 2026

A rota existente `/best-sellers1/` usa uma campanha dedicada. A sequência é filtros com fotos, catálogo, Quem usa e banners de categorias. O cadastro fica em **Personalizar tema → Página Best Sellers Eora**.

## Configuração

O painel tem quatro abas na mesma ordem das partes do briefing:

| Aba | Campos |
| --- | --- |
| Filtro Best Sellers | Botão de filtros e imagem, nome, tag, descrição, ordem e link de cada opção |
| Catálogo | Endereço e título da página, origem e orientações dos produtos |
| Carrossel Quem usa | Opções padrão, fotos de Ver todos e fotos de cada filtro |
| Banners de categorias | Ativação, título e galeria de banners |

Os 15 filtros são grupos internos da aba **Filtro Best Sellers**. Suas galerias ficam juntas em **Carrossel Quem usa**, com a mesma numeração. As orientações de imagens aparecem uma vez por tipo de conteúdo. Os 191 campos mantêm seus identificadores, tipos, arquivos de imagem e dimensões, preservando a compatibilidade com os cadastros existentes. A organização usa `collapse` para as abas e `title` para os grupos internos, conforme a [documentação da Nuvemshop](https://docs.nuvemshop.com.br/help/layout-avancado-settings).

1. Em **Filtro Best Sellers**, ative o botão de filtros e as opções desejadas, até 15. Cadastre foto, nome, tag exata, descrição e posição de cada filtro. A tag deve existir nos produtos da categoria Best Sellers. O clique normal filtra somente esses produtos na página. A descrição abre somente no filtro selecionado. Sem link personalizado, abrir a imagem em outra aba mantém a campanha com o filtro selecionado; sem JavaScript, há um link para a categoria nativa. O botão **Filtros** usa os atributos existentes de Óculos Eora e Bolsas Eora, além de Categoria, Modelo e Preço. As opções vêm das tags e variantes dos produtos de Best Sellers. Quando a seleção contém apenas óculos, atributos exclusivos de bolsas ficam ocultos, e vice-versa. A lista de modelos usa os modelos cadastrados nas duas páginas e os modelos conhecidos que existem nessa categoria.
2. Em **Catálogo**, edite o endereço e o título da campanha. Cadastre e ordene os produtos na categoria **Best Sellers**, em `/best-sellers/`. A campanha lê todas as páginas dessa categoria e preserva sua ordem. Produtos repetidos aparecem uma vez. A aba reúne as orientações de cadastro e fotos dos produtos.
3. Em **Carrossel Quem usa**, cadastre as **Fotos de Ver todos** e as galerias independentes de cada filtro, usando a mesma numeração de **Filtro Best Sellers**. Cada galeria exibe até 15 fotos; remova fotos para desativá-las e arraste para ordenar. Título, subtítulo e link em branco usam os valores padrão dessa aba. Fotos sem link próprio usam o link configurado da galeria, ou `/quem-usa/`. Um filtro sem fotos cadastradas não exibe a galeria de outro filtro.
4. Em **Banners de categorias**, cadastre os banners como na home: imagem, título, descrição, botão e destino. Ative ou desative a seção pelo painel.

A categoria Best Sellers é a única fonte de produtos. Produtos da home, de destaques ou de carrosséis de outras campanhas não entram no catálogo. O primeiro lote de até 24 produtos aparece assim que a primeira página está disponível, no computador e no celular. O restante do catálogo carrega em segundo plano. Ordenação e filtros completos ficam disponíveis quando todas as páginas terminam de carregar. Se houver falha, **Tentar novamente** retoma a página pendente, preservando os produtos já recebidos. A paginação aceita tanto `?page=N` quanto `/best-sellers/page/N/`.

A próxima página começa a ser solicitada antes da montagem dos cards atuais. O catálogo reutiliza os cards e inicializa cada galeria uma vez; respostas em segundo plano não recriam os produtos já visíveis. Na ordem padrão e sem filtros, ele evita processar variantes e ordenar novamente. **Mostrar mais** acrescenta até 24 produtos; se o próximo lote ainda estiver carregando, o botão indica essa espera e preenche o lote assim que estiver disponível, sem aceitar pedidos repetidos. O foco acompanha os novos produtos apenas se o usuário permanecer nesse botão.

## Imagens e qualidade

As medidas estão indicadas no painel, nos textos de ajuda e nos campos de upload. Todas são largura × altura em pixels.

| Imagem | Recomendado | Mínimo | Proporção |
| --- | --- | --- | --- |
| Filtro Best Sellers — computador | 2160 × 960 | 1080 × 480 | 9:4 |
| Filtro Best Sellers — celular (opcional) | 1920 × 2560 | 960 × 1280 | 3:4 |
| Quem usa — todas as galerias | 1920 × 1920 | 1024 × 1024 | 1:1 |
| Banners de categorias | 1920 × 2560 | 960 × 1280 | 3:4 |
| Fotos dos produtos | 1200 × 1600 | 1024 px de largura | Preferir 3:4 |

Envie fotos originais nítidas em JPG ou PNG, de preferência até 1 MB por arquivo. Ampliar uma foto pequena não recupera detalhes. Mantenha o rosto e o produto na área central; nos banners, reserve espaço na parte inferior para o título e o botão. As fotos dos produtos são editadas no cadastro do produto.

Cada opção do Filtro Best Sellers tem uma foto opcional para celular. Quando cadastrada, o `<picture>` usa essa versão até 767 px; sem ela, preserva a foto do computador com recorte central. Banners e Quem usa mantêm sua proporção e oferecem versões de 480, 640, 1024, 1400 e 1920 px, selecionadas pelo navegador conforme a largura e a densidade da tela. Esses tamanhos seguem os [thumbnails documentados pela Nuvemshop/Tiendanube](https://docs.tiendanube.com/help/webp-y-thumbnails).

As fotos principais e adicionais dos produtos usam versões responsivas até 1024 px. As adicionais recebem o `srcset` ao interagir com a galeria; não ficam limitadas a uma thumb de 640 px. As imagens continuam com carregamento progressivo.

## Layout

| Elemento | Computador | Celular |
| --- | --- | --- |
| Filtro Best Sellers | Até 4 dividem a largura igualmente; acima de 4, 3 e parte da quarta com rolagem | Até 4 dividem a largura igualmente; acima de 4, 2 com rolagem |
| Catálogo inicial | Até 24 produtos, 6 linhas de 4 | Até 24 produtos, 12 linhas de 2 |
| Mostrar mais | Acrescenta até 24 produtos | Acrescenta até 24 produtos |
| Quem usa | 5 fotos e parte da próxima | 1 foto e parte da próxima |
| Banners de categorias | 4 banners e parte do próximo | 1 banner e parte do próximo |

As fotos dos filtros dividem a linha conforme a quantidade ativa: 2 usam metade cada, 3 usam um terço e 4 usam um quarto, considerando os espaçamentos, no computador e no celular. Títulos e descrições ficam centralizados abaixo das fotos. O filtro selecionado recebe contorno ao redor da foto e mantém o título sublinhado; somente sua descrição abre.

Os carrosséis usam rolagem nativa, setas, teclado e bolinhas. Quem usa e os banners alinham os itens ao início durante a navegação e centralizam o último ao chegar ao fim. O trecho do próximo item aparece somente quando existem mais imagens do que cabem na tela; sem rolagem, os itens ficam centralizados e os controles são ocultos. Quem usa tem fundo branco; a campanha substitui o Instagram preto do rodapé nessa rota. Os cards mantêm links, preços, situação de estoque e galeria existentes da EORA, incluindo o redirecionamento de variantes do Luar.

Filtros e ordenação ficam na URL e são restaurados ao recarregar ou navegar pelo histórico. Preços inválidos são rejeitados. Galerias de comunidade dos filtros não selecionados ficam em templates inertes; somente as fotos do catálogo visível e da comunidade ativa são carregadas. A foto secundária do produto é carregada ao interagir com a galeria.

## Prévia e verificação

As dependências de verificação estão fora do projeto, em `C:/Temp/eora-best-sellers-validation/node_modules`.

```powershell
$env:NODE_PATH = 'C:\Temp\eora-best-sellers-validation\node_modules'
node .github/tests/best-sellers-harness.cjs --check
node .github/tests/bolsas-eora-harness.cjs --check
node --check static/js/best-sellers-eora.js
node .github/tests/best-sellers-harness.cjs --serve
```

Em outro terminal, com a prévia ativa:

```powershell
$env:NODE_PATH = 'C:\Temp\eora-best-sellers-validation\node_modules'
node .github/tests/best-sellers-browser.cjs
node .github/tests/best-sellers-category.cjs
```

Prévia: `http://127.0.0.1:4176/best-sellers1/`. O endereço padrão lê os produtos reais da categoria publicada Best Sellers por um adaptador exclusivo da prévia. Opções de Filtro Best Sellers, fotos de Quem usa e banners são demonstrações com imagens públicas da EORA. Para os dados de teste, use `?fixture_demo=1`; fixtures e adaptador não são publicados no tema.

Foram verificados 320, 390, 767, 768, 1440 e 1920 px, trecho do próximo item, último item centralizado, item único, filtros combinados, ordenação, histórico, Escape e foco, galerias, limite de 15 fotos, 3/15 categorias e estados vazios. A fonte de produtos foi verificada com 137 produtos em seis páginas, as duas formas de paginação, falha com retomada e rejeição de URLs externas à categoria. A prévia real carregou 32 produtos em duas páginas. Capturas e comparação com o PDF: `C:/Temp/eora-best-sellers-validation/`.

Na atualização de 08/10/2026, os testes também bloquearam as páginas seguintes em 390 e 1440 px: os primeiros 24 produtos apareceram antes do catálogo completo, **Mostrar mais** passou de 24 para 48 e depois 72, e todos os 24 cards iniciais mantiveram sua identidade, a foto selecionada e a galeria Quem usa. A retomada após erro preservou os cards recebidos. Os testes de navegador, feed e campos do editor passaram.

Os ajustes dos áudios de 08/10/2026 foram verificados na mesma rota `/best-sellers1/`, em 320, 390, 767, 768, 1440 e 1920 px. Também passaram 30 combinações com 1, 2, 3, 4, 6 e 15 filtros: largura, centralização, contorno somente na foto, sublinhado, troca de seleção, reset e histórico. A seleção por teclado manteve foco visível e não deslocou as imagens. Feed, paginação e lotes de 24 produtos passaram. A validação foi local, sem publicação.

## Arquivos para publicação

Publicar juntos `config/settings.txt`, `config/defaults.txt`, `templates/page.tpl`, `snipplets/templates/page.tpl`, `templates/category.tpl`, `snipplets/templates/category.tpl`, `layouts/layout.tpl`, `snipplets/footer/footer.tpl`, `static/js/store.js.tpl`, `snipplets/best-sellers/*.tpl`, `snipplets/bolsas-eora/product-card.tpl`, `snipplets/bolsas-eora/gallery.tpl`, `static/css/best-sellers-eora.css` e `static/js/best-sellers-eora.js`. A campanha reutiliza os arquivos já existentes de cards, controles, galerias, CSS e filtros de Bolsas/Óculos Eora. Os novos parâmetros de qualidade são ativados pela campanha Best Sellers.

As imagens finais e as tags dos filtros visuais devem ser preenchidas no painel. Os produtos são administrados na categoria Best Sellers. O PDF fornece estrutura e exemplos visuais de outras marcas, sem o cadastro final da EORA. A implementação e os testes locais não equivalem a uma publicação na loja.
