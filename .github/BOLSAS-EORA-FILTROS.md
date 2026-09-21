# Filtros da pagina Bolsas Eora

Ordem do painel: Modelo, Ocasiao, Tamanho, Cor, O que cabe, Textura, Ferragem e Preco.

## Modelos

O seletor usa somente as tags configuradas nas imagens de **Bolsas Eora > Filtros por modelo**, na mesma ordem do carrossel. Nao inclui modelos fixos, desabilitados ou um grupo artificial de Outros modelos. Uma tag repetida aparece uma vez. Todos os modelos e apenas a opcao para limpar a selecao.

## Opcoes da lateral

Ocasiao, Tamanho, Cor, O que cabe, Textura e Ferragem sao montados a partir das tags dos produtos que pertencem aos modelos cadastrados. Ao escolher um modelo, a lateral usa apenas as tags dos produtos daquele modelo. Grupos e valores sem tags nao aparecem.

A consulta percorre todas as paginas de cada modelo, sem os filtros de preco ou caracteristicas, e verifica a tag exata do modelo para excluir correspondencias amplas da busca. Ate tres modelos sao consultados em paralelo. As opcoes ja conhecidas aparecem imediatamente e as demais entram conforme cada pagina chega, preservando marcacoes e foco. Aplicar filtros fica disponivel durante o carregamento e tambem em caso de falha parcial.

As tags descobertas e o progresso de cada modelo ficam em memoria ate recarregar a pagina. Fechar o painel ou trocar o modelo cancela as consultas; reabrir retoma das paginas pendentes, sem descartar as anteriores. O cache compartilhado guarda somente o HTML do feed, sem documentos DOM, limitado a 40 paginas e 2 MiB estimados de texto (dois bytes por caractere), por cinco minutos. A chave usa a URL completa (modelo, preco, ordenacao e previa). O HTML da busca normal nao e transformado em DOM: apenas o template da campanha e processado. O painel indica enquanto ainda carrega opcoes e permite tentar novamente apos uma falha.

Os nomes e a ordem das opcoes conhecidas sao apenas rotulos de apresentacao. Uma tag nova com prefixo reconhecido, como `cor:terracota`, tambem pode aparecer. Nenhuma opcao e criada a partir do nome do produto, propriedades ou variacoes. Preco continua usando os valores reais e os parametros nativos da loja, sem tag.

Os valores sao livres em todos os grupos. Por exemplo, `cor:rosa` em uma bolsa e `cor:amarelo` em outra fazem aparecer Rosa e Amarelo. Tambem funcionam `textura:matelasse`, `cabe:garrafa`, `ocasiao:passeio`, `tamanho:compacta` e `ferragem:cobre`, sem alterar o codigo. As tabelas abaixo sao sugestoes de cadastro, nao uma lista de valores permitidos.

## Tags para cadastrar nos produtos

Adicionar estas tags no cadastro do produto, alem da tag do modelo. Pode cadastrar mais de uma ocasiao ou capacidade. Use somente classificacoes confirmadas pelo cliente.

| Grupo | Opcao | Tag exata |
|---|---|---|
| Ocasiao | Trabalho | `ocasiao:trabalho` |
| Ocasiao | Dia a dia | `ocasiao:dia-a-dia` |
| Ocasiao | Noite e eventos | `ocasiao:noite-eventos` |
| Ocasiao | Viagem | `ocasiao:viagem` |
| Tamanho | Mini | `tamanho:mini` |
| Tamanho | Pequena | `tamanho:pequena` |
| Tamanho | Media | `tamanho:media` |
| Tamanho | Grande | `tamanho:grande` |
| O que cabe | Essenciais | `cabe:essenciais` |
| O que cabe | Tablet | `cabe:tablet` |
| O que cabe | Notebook ate 14 polegadas | `cabe:notebook-14` |
| O que cabe | Notebook ate 16 polegadas | `cabe:notebook-16` |
| O que cabe | Notebook ate 17 polegadas | `cabe:notebook-17` |

Exemplo de produto: `maxivertice`, `cor:azul`, `ocasiao:trabalho`, `ocasiao:dia-a-dia`, `tamanho:grande`, `cabe:essenciais`, `cabe:tablet`, `cabe:notebook-14`.

O codigo nao deduz capacidade por dimensoes, nome, foto ou modelo. Cada capacidade precisa de sua propria tag: `cabe:notebook-17` nao adiciona automaticamente Tablet ou Notebook ate 14. Sem as tags, o produto continua aparecendo no catalogo, mas nao corresponde a esses novos criterios.

## Cor: somente por tags

O filtro Cor usa exclusivamente as tags cadastradas no produto. Nao interpreta a cor pelo nome da variacao. Mesmo que a variacao se chame Pony Hair Azul / Prata, cadastrar `cor:azul` para que ela apareca ao escolher Azul.

| Cor no filtro | Tag exata |
|---|---|
| Preto | `cor:preto` |
| Marrom | `cor:marrom` |
| Bordo | `cor:bordo` |
| Bege / Creme | `cor:bege-creme` |
| Cinza | `cor:cinza` |
| Verde | `cor:verde` |
| Azul | `cor:azul` |
| Rosa | `cor:rosa` |
| Outras cores | `cor:outras` |

Um produto pode ter mais de uma tag de cor. Sem tag, continua no catalogo, mas nao aparece ao filtrar por cor. Outras cores tambem exige sua tag; nao e um agrupamento automatico de produtos sem cadastro.

Todas as tags classificam o produto inteiro. Em produtos com varias cores/variantes, elas nao indicam qual cor pertence a cada ferragem; o filtro nao seleciona uma variante para a compra.

## Textura e ferragem

Textura e ferragem tambem usam exclusivamente as tags. Por exemplo, a variacao Pony Hair Azul / Prata exige `cor:azul`, `textura:pony-hair` e `ferragem:prata` no produto para corresponder aos tres filtros. Os nomes das variacoes permanecem intactos e nao sao interpretados.

| Grupo | Tags aceitas |
|---|---|
| Textura | `textura:liso`, `textura:croco`, `textura:camurca`, `textura:verniz`, `textura:pony-hair`, `textura:lizard`, `textura:piton`, `textura:avestruz` |
| Ferragem | `ferragem:prata`, `ferragem:dourado`, `ferragem:mix` |

Cadastrar somente as caracteristicas confirmadas para cada produto. Nenhuma textura, ferragem, ocasiao, tamanho ou capacidade e deduzida automaticamente.

## Combinacao e publicacao

Opcoes dentro do mesmo grupo usam OU; grupos diferentes usam E. Exemplo: Preto ou Marrom, combinado com Croco e Prata. Preco usa os filtros nativos da busca e aceita somente minimo, somente maximo ou ambos. Os demais filtros e Ordenar por funcionam em Todos os modelos ou em um modelo especifico, com URL compartilhavel e Limpar filtros. Quando existe qualquer modelo, caracteristica, faixa de preco ou ordenacao selecionada, o catalogo percorre automaticamente todas as paginas e mostra o resultado completo sem exigir **Mostrar mais produtos**. Em Todos, preco, A-Z e mais novos sao ordenados globalmente depois de reunir as tags; mais vendidos intercala a ordem nativa de cada modelo.

Publicar juntos as configuracoes, `snipplets/bolsas-eora/banners.tpl`, `snipplets/bolsas-eora/product-card.tpl`, `static/js/bolsas-eora-filters.js`, `static/js/bolsas-eora.js`, `static/css/bolsas-eora.css` e `snipplets/bolsas-eora/index.tpl`. O JS principal e o CSS usam `20260921-15`, o script de opcoes usa `20260918-5` e a busca permanece em `be_feed=4`. O feed continua usando as tags reais ja serializadas por `product-card.tpl`; nao precisa de metadados de variantes.

O cadastro de tags e a publicacao na loja nao sao realizados pelos testes locais.

## Verificacao

Com a previa local na porta 4175 e NODE_PATH apontando para as dependencias de validacao:

```powershell
node .github/tests/bolsas-eora-filters.cjs
node .github/tests/bolsas-eora-browser.cjs
node .github/tests/bolsas-eora-all-models.cjs
node .github/tests/bolsas-eora-performance.cjs
node .github/tests/bolsas-eora-memory.cjs
```
