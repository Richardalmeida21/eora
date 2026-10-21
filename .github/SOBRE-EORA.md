# Página Sobre EORA

Implementação para `/sobre1/`, com base no briefing de setembro de 2026. Trabalho na branch `feat/sobre-eora-preview`. Não publicar na `main` antes da revisão da prévia.

## Edição na loja

No personalizador, abra **Sobre EORA**. A configuração é independente da home e das páginas de produtos.

1. **Apresentação:** título e texto. Se o texto estiver vazio, mantém o conteúdo já cadastrado na página.
2. **Fundadores:** uma imagem, título e texto.
3. **Press:** até dez itens numerados, cada um com ativação, imagem, título, texto e link.
4. **Frase:** texto e autoria opcional.
5. **Sustentabilidade:** até dez itens, com os mesmos campos de Press.
6. **Linha do tempo:** até dez etapas. A foto e o texto pertencem ao mesmo slide e avançam juntos.
7. **Valores:** três blocos de imagem e texto.
8. **Favoritos da comunidade:** título e ativação. Escolha e ordene os produtos em **Organização dos produtos em destaque → Sobre EORA — Favoritos da comunidade**.

Todas as seções podem ser desativadas. Itens sem imagem não aparecem. Fundadores só aparece quando há foto e texto; frase e comunidade precisam de conteúdo. Não há espaço reservado para blocos vazios.

Nos textos de apresentação, fundadores e frase, use `<strong>negrito</strong>` e `<em>itálico</em>`. Uma linha em branco separa os parágrafos. A fonte é herdada do tema.

Imagens: originais sugeridos de 1400 × 1750 pixels. Os arquivos `static/sobre_eora_*.jpg` são suportes de 1 pixel para o campo de upload; não são conteúdo da loja. As imagens só aparecem depois de um upload no personalizador. Os cartões editoriais usam proporção 4:5; confira o enquadramento ao escolher as fotos.

Press e Sustentabilidade mostram três itens no computador e aproximadamente um e meio no celular. Linha do tempo mostra uma etapa no computador e aproximadamente uma e meia no celular. Valores ficam lado a lado no computador e empilhados no celular. Produtos mostram quatro no computador e aproximadamente um e meio no celular. Rolagem por toque, teclado e controles; sem avanço automático. As imagens permanecem acessíveis sem JavaScript.

## Prévia local

O renderizador de prévia fica em `.github/tests/sobre-eora-harness.cjs` e usa os mesmos templates Twig, CSS e JavaScript da produção. `.github` é excluído do envio FTP.

Dependências: Node.js, `twig`, `playwright`. Neste computador já estão disponíveis em `C:\Temp\eora-best-sellers-validation\node_modules`.

```powershell
$env:NODE_PATH='C:\Temp\eora-best-sellers-validation\node_modules;C:\Temp\eora-bolsas-validation\node_modules'
node .github/tests/sobre-eora-harness.cjs
```

Abra `http://localhost:4181/`. O link **Sem materiais** demonstra a página sem conteúdo nos novos campos. `PORT` altera a porta; `SOBRE_PREVIEW_ASSETS` aponta para a pasta local de fotos. O arquivo opcional `mapping.json` nessa pasta associa os nomes de upload da prévia às fotos locais.

Os textos e os produtos demonstrativos são dados locais do harness; não são defaults de produção. As imagens da prévia vêm da própria EORA. Materiais de Press, políticas de sustentabilidade, datas, valores, frase e a seleção final de produtos precisam ser cadastrados/revisados pela marca. A prévia usa cabeçalho e rodapé simplificados para revisão da página; o tema publicado mantém o cabeçalho e o rodapé atuais.

## Verificação

```powershell
node .github/tests/sobre-eora.cjs
node .github/tests/theme-editor-settings.cjs
```

O teste renderiza o Twig real e verifica blocos vazios/desativados, limite de itens, formatação, ordem dos produtos, proporções de visualização, carrosséis em 1440/390/320 pixels, reinicialização e acesso sem JavaScript.

## Publicação futura

Somente depois de aprovar a prévia: integrar a branch na `main`, que aciona o workflow FTP existente. O pacote inclui a rota em `templates/page.tpl`, os snippets em `snipplets/sobre-eora`, CSS/JS, os três arquivos de configuração e os suportes de upload. Não é necessário colar HTML na página Sobre.
