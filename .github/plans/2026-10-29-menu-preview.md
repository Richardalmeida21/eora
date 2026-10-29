# Menu EORA — plano e decisões

**Objetivo:** aplicar o briefing de outubro de 2026 e entregar uma prévia local navegável, antes de integrar na main.
**Fonte:** PDF `BRIEFING DE ESTRUTURA PARA MENU DO SITE -  OUT 2026.pdf`, páginas 2–6, lido e renderizado em C:/Temp/eora-menu-briefing.
**Arquitetura:** manter cabeçalho, busca nativa, conta e carrinho da Nuvemshop; substituir somente a navegação por um componente Twig compartilhado entre desktop e mobile, com CSS/JS próprios. A prévia renderiza esses mesmos arquivos com conteúdo de demonstração.
**Stack:** Twig Nuvemshop, CSS, JavaScript sem dependências. Twig.js e Playwright somente para validação local.

## Escopo e decisões

- Quatro entradas: Menu, Best Sellers, Sobre, Personal Shopper.
- Cinco grupos: Shop (Óculos, Bolsas, Acessórios, Cintos); Favoritos Marcela (Favoritos, Gifts); Garantia EORA (Cuidados, Conserto, Política de troca); New in (Lançamentos, Pré-venda, De volta ao estoque); Quem usa (Quem usa, Press).
- Desktop ocupa toda a largura com grupos e uma foto à direita de cada grupo. Usar as cores e fontes do tema; a primeira foto da galeria de cada grupo será a imagem desktop, conforme a especificação textual do PDF, apesar de o diagrama esboçar dois retângulos.
- Mobile usa telas primária, secundária e terciária, com voltar. Quatro imagens padrão nas duas primeiras; até quatro imagens próprias ao abrir um grupo, com fallback para as padrão. Reaproveitar as fotos antigas quando possível.
- Busca mantém formulário e sugestões nativas; adicionar seis produtos escolhidos e ordenados na seção menu_search, três visíveis no desktop e dois no mobile.
- Textos, URLs e galerias editáveis no personalizador. Preservar URLs nativas já conhecidas. Lançamentos/Pré-venda, ausentes no sitemap atual, usam busca por termo até cadastro de seus destinos; Conserto usa Garantia EORA até cadastro específico.
- Trabalho isolado em `.worktrees/menu-preview`, branch `feat/menu-preview`. Não integrar, publicar na loja ou enviar para main nesta tarefa. PDFs alterados no checkout original pertencem ao usuário.

## Abordagem

Um componente dedicado permite respeitar o desenho sem reaproveitar os handlers legados de hover e subpainéis, que impõem outra hierarquia. Reorganizar apenas o menu do painel não atende às galerias por nível nem à busca; refazer todo o cabeçalho ampliaria o escopo e arriscaria conta/carrinho.

## Tarefas

- [x] 1. Escrever teste de renderização que falhe com a navegação atual; criar componente compartilhado e configurações. Verificar quatro entradas, quinze destinos, galerias ausentes/parciais e URLs personalizadas.
- [x] 2. Implementar interação e CSS. Testar abrir/fechar, voltar, fotos por seção, Escape, foco e mudança de largura, inclusive 320/390/768/1440 px.
- [x] 3. Adicionar carrossel da busca e prévia, usando os arquivos reais. Testar limite de seis produtos, ordem, deslocamento, três/duas fotos visíveis e ausência de conteúdo vazio.
- [x] 4. Executar regressões pertinentes, revisar imagens e diff, documentar como editar e iniciar a prévia. Deixar servidor local ativo para revisão.

## Foco de revisão

Galerias vazias e parciais; menu via teclado; integração com modal legado; breakpoint em 1200 px; busca vazia e mais de seis produtos. Toda configuração dinâmica usa attribute(settings, chave), compatível com Settings como objeto na loja.

## Progresso

- Briefing lido e inspecionado visualmente; baseline de campos do editor passou (1904 campos nomeados, 223 imagens).
- Worktree criado a partir de b39d77e. Autorização do usuário cobre implementação e preview; revisão final acontece antes de main.
- Testes RED→GREEN da hierarquia e dos seis produtos. Regressão de reabertura da busca (primeiro produto) também falhou antes da correção e passou depois.
- Revisão independente identificou dois problemas de integração: contexto transformado do cabeçalho e ausência de foco/Escape no modal legado. Ambos corrigidos e cobertos por testes que falharam antes da correção. O painel desktop é montado no body; o mobile usa o fechamento nativo, com gerenciamento próprio de foco.
- Fallback de galeria vazia passou a usar teste explícito `is empty`, por diferença entre Twig.js e PHP Twig. Imagens ausentes, cadastro parcial e fallback padrão verificados.
- Verificação final: menu.cjs, menu-browser.cjs, menu-php.cjs, menu-native-browser.cjs, theme-editor-settings.cjs, theme-preview-loading.cjs e git diff --check passaram. Capturas revisadas em C:/Temp/eora-menu-preview.
- Limites: moldura da prévia simplificada; testes nativos usam captura pública e CSS reais, sem painel autenticado. Fotos/produtos finais e três destinos provisórios devem ser configurados antes da publicação. Nenhuma alteração na loja ou main.
