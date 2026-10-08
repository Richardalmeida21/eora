# Auditoria de adicionar ao carrinho — 08/10/2026

O pedido foi revisar as páginas de produto, especialmente Maxi Vértice, a partir da gravação enviada pelo usuário. A gravação mostra uma reprodução de sessão do Clarity, trocas de cor, um formulário de aviso para uma opção indisponível e tentativas de compra. Não há mensagem de erro legível no vídeo; o diagnóstico abaixo veio da reprodução na loja e da análise do código.

## Erro compartilhado do carrinho

Foi reproduzido `Cannot read properties of null (reading 'style')` no componente `TotalWithPaymentDiscount` da biblioteca pública `linkedstore.js` da Nuvemshop. O item era incluído no carrinho, mas a atualização posterior tentava acessar `.js-payment-discount-price-cart-container`, ausente no carrinho personalizado.

`snipplets/cart-totals.tpl` agora preserva esse container e os filhos `.js-payment-discount-price-cart` e `.js-payment-discount-name-cart`, mesmo com os totais padrão desabilitados. Os hooks ficam em um wrapper oculto; os preços, descontos e a apresentação atual do PIX não foram alterados.

## Proteção da compra e troca de referência

- `static/js/store.js.tpl`: a imagem da notificação passa a ser opcional. A busca prioriza a variante ativa dentro do produto e aceita `data-srcset`, `srcset`, `data-src` ou `src`. A falta de imagem não interrompe a chamada de compra. Cada formulário bloqueia cliques repetidos durante sua requisição e libera o botão em sucesso ou erro; a animação não volta a escondê-lo após uma falha imediata. Contato, catálogo e indisponíveis preservam seus caminhos próprios.
- `maxivertice.html`: a navegação entre referências atualiza `LS.variants` pelo `data-variants` do novo produto, pois `LS.product` publicado não contém as variantes. A sincronização de campos propaga `change` aos listeners delegados, valida as opções antes de atribuir selects e identifica a variante pelo produto e ID atuais. Uma compra agendada é cancelada se o formulário mudar durante a espera.

## Outros problemas encontrados na revisão

- `snipplets/header/header-modals.tpl`: o título do carrinho tinha uma contagem estática, permanecendo em `(0)` mesmo com o item incluído. O número agora usa `.js-cart-widget-amount`, que a plataforma já atualiza ao adicionar, alterar quantidade ou remover.
- `snipplets/grid/item.tpl`: os cards reduzidos de recomendações omitiam o marcador nativo de estoque porque não mostram os labels visuais. O app Cheguei/Avise-me procura `.hidden[data-store]` nesses cards e acessa `getAttribute` sem verificar se o elemento existe. O erro foi observado em uma execução prolongada após abrir recomendações. O marcador `stock-product-ID-ESTOQUE` agora está presente também nos cards reduzidos, com a mesma expressão de estoque dos cards normais. O script externo não foi modificado.

Na loja sem o patch da descrição, a troca Berinjela → Croco deixava `LS.variants` com Berinjela. O botão flutuante podia esvaziar `variation[0]`; nos dois testes o servidor ainda aceitou Croco pelo `variant_id` correto. Isso demonstra inconsistência no formulário, não prova que todas as compras anteriores adicionaram a cor errada.

## Verificação

Os testes locais usam Chromium, Twig e a implementação real de `jQueryNuvem`. A chamada de compra é uma fixture de contrato nos testes locais; eles não simulam uma confirmação real de checkout.

- `product-add-to-cart.cjs`: 39 cenários, incluindo imagens ausentes/blur, variante ativa, quantidade, formulários independentes, cliques repetidos, recuperação de erro, quickshop, recomendações e 16 combinações de totais com/sem desconto. A versão anterior reproduziu `undefined.split` e `null.style`.
- `product-maxi-variants.cjs`: funções reais da descrição, troca Berinjela → Croco, atualização das variantes, eventos delegados, preservação de seleção/ID ao rejeitar uma opção antiga, estoque indisponível, escolha disponível quando a anterior está esgotada e cancelamento de compra durante a troca. O ID é sincronizado depois dos selects, sem copiar o ID antigo do clone.
- `product-cart-hooks.cjs`: nove cenários com o parser real de estoque do app Cheguei em cards normais/reduzidos, estoque zero/finito/infinito e atualizações do contador do modal para 1, 2 e 0 com `jQueryNuvem` real. As versões anteriores reproduziram `null.getAttribute` e o título preso em `(0)`.
- `theme-editor-settings.cjs`: estrutura do editor e renderização dos banners preservadas.

Na loja pública, sete cenários foram testados em sessões anônimas independentes: Maxi Berinjela no computador e celular, Maxi Croco no computador, Clutch Turquesa no celular, Hobo Berinjela no computador, Mini Marrom Café no celular e Onyx Preto/Marrom no celular. Com os hooks de desconto aplicados **somente ao HTML recebido pelo navegador de teste**, todos retornaram HTTP 200 ao adicionar, exibiram item/cor corretos, contador 1 e carrinho aberto, sem a exceção de desconto. Algumas páginas abrem primeiro as recomendações; o carrinho foi conferido pelo controle normal da loja. Nenhum pedido foi finalizado.

A primeira execução com identificação `HeadlessChrome` recebeu HTTP 403 genérico. O SDK traduz respostas sem `error_code` como `out_of_stock`; isso não comprova falta de estoque. Os testes com identificação padrão do Chrome permitiram a inclusão.

Na conferência final, três cenários usaram a seção de compra real de `store.js.tpl` renderizada por Twig, o script local corrigido de `maxivertice.html` quando aplicável e os hooks locais, substituindo o HTML **apenas no navegador**. Maxi Berinjela → Croco passou tanto pelo botão principal quanto pelo flutuante, com `LS.variants` atualizado, `variation[0]` preenchida, ID da Croco correto, HTTP 200, `success:true`, quantidade 1, cor correta, contador/título 1 e carrinho aberto, sem `pageerror`. Clutch também passou, com o app Cheguei carregado e espera de 33 segundos após adicionar. Seus oito marcadores inseridos no teste usaram valores nativos de estoque da mesma página, sem valores inventados. Nenhum script externo foi removido.

Evidências locais: `C:/Temp/eora-product-cart-validation/live-cart-summary.json`, `final-local-patch-live-report.json`, `product-add-to-cart-regression.json` e `product-cart-hooks-regression.json`. As respostas finais preservam a propriedade `success` antes de descartar o HTML volumoso. Em parte da amostra inicial a resposta salva foi truncada e essa propriedade não ficou disponível; ali a confirmação usa HTTP 200 e o estado real do carrinho. Mensagens de rede de terceiros também foram registradas, sem impedir as inclusões observadas; os testes não comprovam ausência de todo erro em todas as páginas ou sessões.

## Publicação

As mudanças foram feitas e verificadas localmente. Não houve envio por FTP, push, alteração do cadastro dos produtos nem publicação na loja.

Os arquivos `.tpl` pertencem ao tema e são publicados pelo fluxo normal do projeto. `maxivertice.html` é conteúdo da descrição dos produtos Maxi Vértice; enviar esse arquivo ao FTP não substitui automaticamente a descrição no cadastro. A parte corrigida do script deve ser incorporada às descrições que usam esse layout, preservando os textos, fotos e tabelas de cada referência.

## Nome automático da variação — 08/10/2026

O script de `maxivertice.html` agora prioriza o texto das opções selecionadas no formulário nativo do produto, por exemplo `Marrom Cacau / Dourado`. Quando não há select, usa as variantes daquele mesmo produto e o ID selecionado. A extração também funciona no documento de outra referência recebido por fetch, sem usar os dados globais da referência anterior.

O nome é recalculado ao iniciar o layout, trocar de referência ou alterar uma opção nativa. O cache deixa de prevalecer sobre o cadastro, e o prefetch atualiza apenas o nome da miniatura correspondente, sem mudar o nome do produto ainda exibido. O texto é inserido com `textContent` e não altera os campos enviados ao carrinho.

A tabela de exemplo `nome_variacao` foi removida do arquivo. Nos produtos que já têm essa tabela, o cadastro da variação passa a ter prioridade após atualizar o bloco `<script>...</script>`; a tabela pode ser apagada. Textos, fotos e outras tabelas de cada referência devem ser preservados. Para descrições antigas sem opções disponíveis, os fallbacks de tabela/nome/tags continuam limitados ao produto atual.

Validação: `product-maxi-variation-name.cjs` passou 13 cenários, incluindo tabela manual incorreta, produto/quickshop distintos, metadados por ID, documento recebido por fetch, cache antigo, alteração nativa, prefetch e texto literal. A versão anterior reproduziu a prioridade indevida da tabela. `product-maxi-variants.cjs` e a sintaxe do script também passaram.

A conferência na loja, substituindo somente o script da descrição pelo arquivo local no navegador, passou em 390 e 1440 px: `Berinjela / Prata` mudou para `Croco Marrom / Prata`, permaneceu estável após os timers e manteve produto, variante e selects corretos, sem `pageerror`. Um nome manual incorreto simulado no DOM não prevaleceu sobre o cadastro. A tentativa opcional de adicionar nessa última conferência foi interceptada pelo popup de newsletter antes do POST; a validação de compra permanece a da auditoria anterior e dos testes locais, sem atribuir uma nova inclusão a esse teste de nome. Evidência: `C:/Temp/eora-product-cart-validation/auto-variation-summary.json`. Estas mudanças continuam locais e precisam ser incorporadas à descrição no cadastro.

## Executar os testes

São necessários Node.js, `playwright`, `twig` e Chromium. Neste computador as dependências estão em `C:/Temp/eora-best-sellers-validation/node_modules`. `BE_BROWSER` permite indicar outro executável Chromium. O teste de carrinho guarda evidências em `PRODUCT_CART_VALIDATION_DIR` (padrão `C:/Temp/eora-product-cart-validation`) e usa a biblioteca pública da plataforma disponível em `PRODUCT_CART_PLATFORM_ASSET`, baixando-a se faltar.

```powershell
$env:NODE_PATH = 'C:/Temp/eora-best-sellers-validation/node_modules'
node .github/tests/product-add-to-cart.cjs
node .github/tests/product-maxi-variants.cjs
node .github/tests/product-maxi-variation-name.cjs
node .github/tests/product-cart-hooks.cjs
node .github/tests/theme-editor-settings.cjs
git diff --check
```
