# Links nas imagens da descricao de produtos

O editor da Nuvemshop salva a imagem dentro de um link (`a > img`). Alguns scripts antigos colados nas descricoes de Maxi Vertice e Hobo, e os extratores compartilhados de banners, recriam apenas a imagem. A correcao central preserva os destinos sem substituir o HTML cadastrado em cada produto.

## Arquivos de producao

- `layouts/layout.tpl`: inclui a correcao somente em paginas de produto, imediatamente depois de `template_content` e antes da limpeza da descricao pelos scripts antigos.
- `static/js/product-description-image-links.js.tpl`: guarda apenas enderecos e atributos dos links; associa a foto ao destino dentro do mesmo tipo de bloco. Nao duplica a descricao, baixa imagens, consulta APIs ou adiciona bibliotecas.

Blocos atendidos: Clientes Eora, Banners Experiencia Eora, Banners alternados, banner de imagem full, banner foto/video e tres banners de video quando exibem imagens. Os aliases usados pelos scripts atuais sao preservados. Links existentes em banners, imagens de zoom, botoes e formularios nao sao substituidos.

O script acompanha alteracoes diretas nos pais dos blocos e mudancas dentro dos blocos atendidos. Nao observa a arvore completa do body, nao usa polling e nao reconstroi o Swiper. Mantem o elemento original de imagem, `src`, `srcset`, dimensoes e lazy loading. Imagens responsivas atualizam o destino conforme `currentSrc`.

Se a mesma imagem tiver destinos concorrentes dentro do mesmo bloco, o script nao escolhe um destino arbitrario. Na navegacao dinamica, os novos links precisam estar presentes na descricao recebida no DOM. O fluxo legado pode substituir apenas `#single-product` e omitir a descricao de largura total que fica fora dele; nesses casos nao e possivel recuperar os destinos omitidos, e os links antigos da correcao sao removidos.

## Testes

Dependencias locais de teste: Node.js, Playwright, Twig e Chromium. Nenhuma dependencia foi adicionada ao tema.

```powershell
$env:NODE_PATH = 'C:/Temp/eora-best-sellers-validation/node_modules;C:/Temp/eora-bolsas-validation/node_modules'
node .github/tests/product-description-image-links.cjs
node .github/tests/product-description-image-links-performance.cjs
node .github/tests/product-add-to-cart.cjs
node .github/tests/product-maxi-variants.cjs
node .github/tests/product-maxi-variation-name.cjs
node .github/tests/product-cart-hooks.cjs
node .github/tests/theme-editor-settings.cjs
node .github/tests/theme-preview-loading.cjs
node .github/tests/theme-editor-performance.cjs
git diff --check
```

Os testes novos exercitam funcoes reais de Maxi/Hobo e dos extratores compartilhados, com o Swiper do tema. Verificam cliques, nova janela, arraste por mouse/toque, fotos sem link, destinos diferentes para a mesma imagem em blocos distintos, remontagem, fotos alteradas, largura total, produto sem descricao, picture responsivo, foco por teclado e igualdade de geometria/atributos antes/depois.

Medicao local com 20 imagens: mediana inicial de aproximadamente 0,6 ms em 25 amostras; 5.000 insercoes alheias aos blocos geraram um callback de aproximadamente 3,4 ms sem reexaminar as fotos; 30 trocas com coleta de lixo cresceram aproximadamente 46 KB. O arquivo acrescenta aproximadamente 9,9 KB sem compressao ou 2,9 KB em gzip. Sao medidas de fixtures locais, nao garantias de tempo de carregamento ou memoria total da loja.

Evidencias ficam em `C:/Temp/eora-image-links-validation/`. Os testes nas paginas publicas interceptam e alteram somente o HTML recebido pelo navegador de teste. Nenhum produto, tema ou pedido da loja e modificado por esses testes. Os testes locais de carrinho validam contratos; nao equivalem a confirmar um checkout real.

## Publicacao e rollback

Publicar os dois arquivos de producao juntos. O workflow `.github/workflows/deploy.yml` publica automaticamente por FTP quando ha push na `main`. Um commit na branch de trabalho nao publica a loja.

Para reverter, executar `git revert` no commit da correcao e publicar o revert pelo mesmo fluxo. O rollback remove a inclusao do script e restaura o comportamento anterior; as descricoes dos produtos permanecem intactas.
