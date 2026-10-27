# Página Sobre EORA

Implementação para `/sobre1/`, com base no briefing de setembro de 2026. Ajustes locais na branch `fix/mobile-images-banner-quality`. Não publicar na `main` antes da revisão da prévia.

## Edição na loja

No personalizador, abra **Sobre EORA**. A configuração é independente da home e das páginas de produtos.

Os nomes dos campos e conteúdos cadastrados foram mantidos na correção de 26/10. Acessos dinâmicos a configurações devem usar `attribute(settings, chave)`: no Twig PHP da loja, Settings é um objeto e `settings[chave]` pode ocultar seções ativadas. O teste com Twig.js sozinho não detecta essa diferença. `.github/tests/sobre-eora-php.cjs` cobre configurações como objeto e array; execute com `SOBRE_PHP_BIN` e `SOBRE_TWIG_AUTOLOAD` apontando para PHP e o autoload de Twig.

1. **Apresentação:** título e texto. Se o texto estiver vazio, mantém o conteúdo já cadastrado na página.
2. **Fundadores:** imagem desktop, imagem mobile opcional, título e texto.
3. **Press:** galeria com “+ Adicionar imagem”, na quantidade necessária. Arraste para ordenar e use o lápis de cada imagem para editar título, descrição, link e botão.
4. **Frase / Missão:** título opcional, texto e autoria opcional. O título fica acima do texto e usa o mesmo estilo dos demais tópicos.
5. **Sustentabilidade:** galeria com os mesmos campos de Press.
6. **Linha do tempo:** até dez etapas. A foto e o texto pertencem ao mesmo slide e avançam juntos.
7. **Valores:** galeria de blocos de imagem e texto, com links opcionais. A grade forma novas linhas no computador; no celular, os itens formam um carrossel com toque, teclado e controles.
8. **Favoritos da comunidade:** título e ativação. Escolha e ordene os produtos em **Organização dos produtos em destaque → Sobre EORA — Favoritos da comunidade**.

Todas as seções podem ser desativadas. Remova uma imagem da galeria para remover aquele item da página. Itens sem imagem não aparecem. Fundadores só aparece quando há foto e texto; frase e comunidade precisam de conteúdo. Não há espaço reservado para blocos vazios.

Nos textos de apresentação, fundadores e frase, use `<strong>negrito</strong>` e `<em>itálico</em>`. Uma linha em branco separa os parágrafos. A fonte é herdada do tema.

Foto dos Fundadores: **desktop 2400 × 1920 px (5:4, horizontal) e mobile 1600 × 2000 px (4:5)**. Fundadores tem apenas o par de fotos fixo. Imagens de Press, Sustentabilidade, História e Valores: **desktop 1920 × 2400 px e mobile 1600 × 2000 px**, ambos na proporção 4:5. Essas quatro seções usam oito galerias no total: uma desktop e uma mobile opcional por seção. Sem posições numeradas fixas ou limite de dez itens no template.

Até 767 px, a página seleciona a foto da mesma posição na galeria mobile. **Se usar imagens mobile separadas, mantenha a mesma quantidade e ordem da desktop**, inclusive ao remover/reordenar fotos. Para um item que não precisa de recorte diferente, repita a respectiva foto desktop na galeria mobile. Os textos e links vêm da desktop. Se o enquadramento for o mesmo em toda a seção, deixe a galeria mobile vazia. Enquanto a lista mobile estiver incompleta, a seção usa desktop em todas as posições, evitando deslocar fotos para outros textos/links.

O navegador escolhe entre thumbnails de 480, 640, 1024, 1400 e 1920 px conforme a largura real da seção e a densidade da tela. As medidas recomendadas cobrem 2× na maior largura atual das fotos editoriais; não garantem nitidez ilimitada em qualquer densidade ou zoom. `original` na Nuvemshop é um thumbnail de até 1024 px, por isso não deve ser usado sozinho para as fotos maiores. Fontes menores não ganham detalhes: substitua uploads antigos com baixa resolução. Os arquivos fixos `static/sobre_eora_*.jpg` são suportes de 1 pixel; não são conteúdo da loja. As galerias não precisam de suportes fixos.

Press e Sustentabilidade mostram três itens completos e parte do próximo no computador. Linha do tempo mostra uma etapa e parte da próxima. Produtos mostram quatro itens e parte do próximo. No celular, todos esses carrosséis mostram um item completo e uma pequena prévia do seguinte, assim como Valores (que mantém três colunas no computador). As barras de rolagem ficam ocultas; os marcadores usam 7 px e o ativo, preto, 9 px. Rolagem por toque, teclado e controles; sem avanço automático. As imagens permanecem acessíveis sem JavaScript.

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
