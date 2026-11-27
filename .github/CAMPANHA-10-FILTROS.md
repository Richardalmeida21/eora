# Campanha 10 com filtros
No editor do tema, abra **Página de campanha 10 com filtros**.
1. Crie uma página de conteúdo na Nuvemshop e informe o caminho no campo Página associada, sem barras (ex.: colecao-verao). Se a campanha 10 já possui página associada, o endereço existente continua válido.
2. Crie uma categoria de produtos para a campanha e inclua nela somente os óculos e bolsas dessa coleção. Informe seu caminho em Caminho da categoria da coleção (ex.: /colecao-verao-produtos/). A categoria de produtos e a página de conteúdo devem ter endereços diferentes.
3. Defina título, apresentação e banners do computador e celular. Somente a primeira imagem de cada campo é exibida; o banner de computador é usado no celular se não houver imagem específica.
4. Configure nomes dos botões, ativação dos filtros, colunas, tamanho dos lotes e ordenação.
5. Modelos das páginas de bolsas e óculos são aproveitados. Cadastre modelos adicionais com título e tag exata em Modelos extras. Os filtros só apresentam modelos encontrados na coleção.
6. Salve o editor e confira a página no celular e computador antes de divulgar.

O catálogo usa exclusivamente a categoria configurada e percorre suas páginas; não completa resultados com produtos de busca ou destaques. Seleções Óculos/Bolsas usam as tags oculos/bolsa e os nomes dos produtos. Características seguem as mesmas tags e variantes usadas nas vitrines atuais. Ordenação inicial, preço, lançamentos, modelos e características são combinados dentro da coleção. Sem categoria configurada, aparece Em breve.

Validação: node --test .github/tests/campaign-catalog.cjs (Twig e jsdom), além da validação completa dos campos do editor. O deploy executa ambos antes de enviar arquivos ao tema.
