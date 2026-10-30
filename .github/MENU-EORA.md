# Menu e busca EORA — prévia de outubro de 2026

Implementa o briefing de menu no computador e no celular. A revisão segura foi ativada em 9ba45a1, após validação opt-in na Nuvemshop. A retirada dos controles antigos foi aplicada separadamente em bbeda0d e confirmada com HTTP 200 nas páginas e na prévia. Ver `.github/plans/2026-10-29-menu-safe.md`.

No desktop, abre ao passar o mouse em Menu e fecha ao sair do acionador/painel, com breve tolerância para atravessar o espaço entre os dois. O painel ocupa aproximadamente a metade superior da tela e dispõe os cinco grupos em duas linhas (três e dois), com até duas fotos à direita de cada grupo. Clique e teclado continuam disponíveis. No celular, Best Sellers, Sobre e Personal Shopper ficam ao lado de Menu no cabeçalho, e os cinco tópicos aparecem abaixo. O painel se revela do canto superior esquerdo para a direita e para baixo em 350 ms e fecha em 240 ms, respeitando movimento reduzido. O próprio botão Menu fecha o painel ao tocar novamente; não há X separado, e os atalhos navegam normalmente. A reabertura cancela o efeito de temporizadores antigos de ocultação do modal.

Na home, o cabeçalho transparente usa inversão de cores e uma versão branca do logo. Enquanto o menu estiver aberto, a barra recebe o fundo e a cor configurados para o cabeçalho, a inversão é desativada e a versão do logo usada no hover é exibida. Ao fechar, o cabeçalho volta ao comportamento configurado. O teste `menu-header-contrast.cjs` verifica o cursor dentro do painel, inclusive com o cabeçalho comprimido após rolagem.

O cabeçalho principal no celular reserva uma área para a wishlist antes de o Selly carregar. `eora-header.css` distribui menu, logo e ações conforme a largura disponível, sem os recuos globais que faziam o coração cobrir o logo em telas menores. O contador permanece dentro do botão. As posições explícitas da grade permitem notificações opcionais; se habilitado, o seletor de idiomas ocupa uma linha própria. O desktop mantém a disposição nativa. `header-wishlist-browser.cjs` usa o Twig e os SCSS reais e verifica 12 larguras entre 320 e 1199 px, rotação, DPR 1/3, carregamento/reinserção do widget, contadores, versões do logo, clique e configurações opcionais. Requer `sass`, `twig`, `jquery` e `playwright`; `EORA_HEADER_ENGINE=webkit` seleciona WebKit, e `BE_BROWSER` pode indicar o executável local.

## Abrir a prévia

```powershell
$env:NODE_PATH='C:\Temp\eora-best-sellers-validation\node_modules;C:\Temp\eora-bolsas-validation\node_modules'
node .github/tests/menu-harness.cjs
```

Abra **http://localhost:4183/**. A navegação e o carrossel usam os mesmos Twig, CSS e JavaScript da produção. Cabeçalho, formulário de busca e fundo são uma moldura simplificada de demonstração. Os links levam à loja atual. Os seis produtos e as fotos demonstram a composição; a seleção final será feita no painel. A prévia depende das fotos já disponíveis neste computador em `C:\Temp\eora-sobre-preview\assets`.

O teste `menu-native-browser.cjs` também verifica os componentes no HTML do cabeçalho real e nas folhas compiladas do tema, obtidos de uma captura pública. Ele usa apenas a abertura/fechamento visual do modal legado: foco, Escape e navegação pertencem ao novo script. Não reproduz o painel autenticado da Nuvemshop.

## Configurar no painel

Em **Menu e busca EORA**:

- **Ordem do menu no celular:** arraste os cinco tópicos e os três links principais para mudar sua sequência. A ordem relativa dos tópicos é aplicada à lista; a dos três links é aplicada ao cabeçalho. A ordem do computador permanece independente.
- Textos e URLs das quatro entradas principais e de todos os links das cinco seções. Os campos de URL vazios usam os destinos da loja definidos no template.
- **Quatro fotos padrão:** imagens para a tela inicial e a lista de seções no celular. Sem cadastro novo, usa as fotos preservadas da versão anterior.
- **Galeria de cada seção:** até quatro imagens, com título e link próprios. As duas primeiras aparecem ao lado dos links no computador; as quatro aparecem ao abrir a seção no celular. Sem imagens novas, usa as fotos preservadas daquela seção e depois as imagens padrão. Uploads vazios são ignorados; galerias com menos de quatro fotos exibem somente as cadastradas.
- Fotos recomendadas: **1200 × 1500 px**, com conteúdo central seguro para o recorte quadrado do celular. Arraste para reordenar e use o lápis para título e link.
- Título do carrossel da busca.

Os antigos blocos Imagem do Menu de Navegação, Imagens do menu desktop e Menu Secundário A–D foram retirados do editor: 42 campos nomeados e 17 campos de imagem. Permanecem as configurações gerais de Cabeçalho. As dez fotos já utilizadas foram preservadas em cópias nativas de 640 px, com títulos, links e ordem anteriores; o renderizador não depende mais dos campos removidos. As cópias são servidas diretamente, sem pedir miniaturas que a plataforma não gera para imagens copiadas por FTP. As galerias novas têm prioridade. Para removê-las sem substituição, desative “Manter fotos anteriores nas galerias vazias”. Isso não cria registros nas galerias novas do painel: cadastre as imagens nessas galerias para passar a editá-las por lá.

Em **Organização dos produtos em destaque → Busca — Menu EORA**, escolha e ordene os seis produtos. O template limita a seis produtos válidos e preserva a ordem. Sem seleção, o bloco fica oculto. Produtos, imagens e URLs não são gravados no catálogo por esta alteração.

## Destinos

As rotas de Óculos, Bolsas, Acessórios, Cintos, Best Sellers, Sobre, Personal Shopper, Favoritos, Gifts, Quem usa e Política de troca seguem os destinos já existentes. Cuidados usa a âncora `#cuidados-com-a-peca` em Garantia; Press usa `#se-press` em Sobre.

Lançamentos abre Best Sellers com `bs_filters={"bs_new":"1"}`. O filtro New in seleciona somente produtos da categoria Best Sellers com a tag exata `novo`, ignorando caixa/espaços. O filtro aparece selecionado no formulário e funciona com Aplicar, limpar e histórico do navegador. Não confundir ordenação por data com a tag novo.

Pré-venda abre `/search/?eora_preorder=1`, uma página dedicada de aviso, sem resultados vazios de busca. Esse endereço funciona sem criar um cadastro no painel. O mesmo conteúdo também está preparado para uma página nativa com identificador `pre-venda`, se ela for cadastrada depois. O aviso é: “Os produtos de pré-venda serão disponibilizados aqui em breve.”

Consertos aponta para `/garantia-eora/#reparos-e-consertos`, a seção final da Garantia, mantendo o botão de WhatsApp já cadastrado. De volta ao estoque continua no destino existente. URLs personalizadas no painel continuam tendo prioridade sobre os padrões.

## Verificação

```powershell
node .github/tests/menu.cjs
node .github/tests/menu-cleanup.cjs
node .github/tests/menu-preorder.cjs
node .github/tests/menu-new-in.cjs
node .github/tests/menu-browser.cjs
node .github/tests/menu-mobile-browser.cjs
node .github/tests/menu-php.cjs
node .github/tests/menu-native-browser.cjs
node .github/tests/theme-editor-settings.cjs
node .github/tests/theme-preview-loading.cjs
git diff --check
```

PHP/Twig reais disponíveis em `C:\Temp\eora-sobre-php`. Os testes aceitam `SOBRE_PHP_BIN`, `SOBRE_TWIG_AUTOLOAD` e `BE_BROWSER` para outros caminhos. O teste nativo usa `MENU_NATIVE_SNAPSHOT` (padrão: captura em `C:\Temp\eora-best-sellers-validation\current.html`) e os CSS `native-*.css` em `C:\Temp\eora-menu-preview`. As capturas de desktop/mobile e busca ficam nessa mesma pasta. A pasta `.github` é excluída pelo deploy FTP.

O teste `menu-mobile-browser.cjs` requer `twig`, `playwright` e `jquery` no caminho de módulos de teste. Ele renderiza o embed real do menu e executa os handlers nativos extraídos de `store.js.tpl`, além dos assets de menu. Verifica encaixe entre 320 e 1199 px, links, movimento, Escape/foco e reabertura rápida. Aceita `MENU_TEST_OUTPUT` para as capturas; por padrão usa a pasta temporária do sistema.

O painel desktop é montado diretamente no body para evitar o contexto de posicionamento criado pelo `transform: scale(1)` do cabeçalho original. O modal móvel continua sendo aberto pelo script legado; o novo código gerencia os níveis, foco, Escape, retorno ao acionador e limite do Tab.
