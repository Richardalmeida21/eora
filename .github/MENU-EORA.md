# Menu e busca EORA — prévia de outubro de 2026

Implementa o briefing de menu no computador e no celular. Branch `feat/menu-preview`, isolada em `.worktrees/menu-preview`. Não foi integrada à `main` nem enviada à loja.

## Abrir a prévia

```powershell
$env:NODE_PATH='C:\Temp\eora-best-sellers-validation\node_modules;C:\Temp\eora-bolsas-validation\node_modules'
node .github/tests/menu-harness.cjs
```

Abra **http://localhost:4183/**. A navegação e o carrossel usam os mesmos Twig, CSS e JavaScript da produção. Cabeçalho, formulário de busca e fundo são uma moldura simplificada de demonstração. Os links levam à loja atual. Os seis produtos e as fotos demonstram a composição; a seleção final será feita no painel. A prévia depende das fotos já disponíveis neste computador em `C:\Temp\eora-sobre-preview\assets`.

O teste `menu-native-browser.cjs` também verifica os componentes no HTML do cabeçalho real e nas folhas compiladas do tema, obtidos de uma captura pública. Ele usa apenas a abertura/fechamento visual do modal legado: foco, Escape e navegação pertencem ao novo script. Não reproduz o painel autenticado da Nuvemshop.

## Configurar no painel

Em **Menu e busca EORA**:

- Textos e URLs das quatro entradas principais e de todos os links das cinco seções. Os campos de URL vazios usam os destinos da loja definidos no template.
- **Quatro fotos padrão:** imagens para a tela inicial e a lista de seções no celular. Sem cadastro novo, reaproveita `desktop_menu_images_first`.
- **Galeria de cada seção:** até quatro imagens, com título e link próprios. A primeira aparece ao lado dos links no computador; as quatro aparecem ao abrir a seção no celular. Sem imagens novas, reaproveita a galeria antiga configurada com o mesmo nome e depois as imagens padrão. Uploads vazios são ignorados; galerias com menos de quatro fotos exibem somente as cadastradas.
- Fotos recomendadas: **1200 × 1500 px**, com conteúdo central seguro para o recorte quadrado do celular. Arraste para reordenar e use o lápis para título e link.
- Título do carrossel da busca.

Em **Organização dos produtos em destaque → Busca — Menu EORA**, escolha e ordene os seis produtos. O template limita a seis produtos válidos e preserva a ordem. Sem seleção, o bloco fica oculto. Produtos, imagens e URLs não são gravados no catálogo por esta alteração.

## Destinos que precisam de revisão antes de publicar

As rotas de Óculos, Bolsas, Acessórios, Cintos, Best Sellers, Sobre, Personal Shopper, Favoritos, Gifts, Quem usa e Política de troca seguem os destinos já existentes. Cuidados usa a âncora `#cuidados-com-a-peca` em Garantia; Press usa `#se-press` em Sobre.

Lançamentos e Pré-venda não têm uma categoria identificada no sitemap público consultado: usam uma busca pelo termo como destino provisório. Conserto usa Garantia EORA como destino provisório. Cadastre os destinos definitivos nos respectivos campos antes de publicar. Os destinos são configuráveis, sem mudanças no código.

## Verificação

```powershell
node .github/tests/menu.cjs
node .github/tests/menu-browser.cjs
node .github/tests/menu-php.cjs
node .github/tests/menu-native-browser.cjs
node .github/tests/theme-editor-settings.cjs
node .github/tests/theme-preview-loading.cjs
git diff --check
```

PHP/Twig reais disponíveis em `C:\Temp\eora-sobre-php`. Os testes aceitam `SOBRE_PHP_BIN`, `SOBRE_TWIG_AUTOLOAD` e `BE_BROWSER` para outros caminhos. O teste nativo usa `MENU_NATIVE_SNAPSHOT` (padrão: captura em `C:\Temp\eora-best-sellers-validation\current.html`) e os CSS `native-*.css` em `C:\Temp\eora-menu-preview`. As capturas de desktop/mobile e busca ficam nessa mesma pasta. A pasta `.github` é excluída pelo deploy FTP.

O painel desktop é montado diretamente no body para evitar o contexto de posicionamento criado pelo `transform: scale(1)` do cabeçalho original. O modal móvel continua sendo aberto pelo script legado; o novo código gerencia os níveis, foco, Escape, retorno ao acionador e limite do Tab.
