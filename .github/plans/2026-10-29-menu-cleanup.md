# Limpeza do painel e ajustes do menu

Autorizado pelo usuário como continuação da publicação em main. Trabalhar em fix/menu-panel-cleanup e enviar o pacote validado pelo fluxo existente.

- Remover os controles antigos de imagem única, galeria desktop e grupos A–D do Cabeçalho; manter dados antigos como compatibilidade interna, sem controles duplicados. Não alterar nem apagar fotos/links salvos da loja.
- Remover o banner único do modal e seu CSS sem uso.
- Corrigir recuo esquerdo do menu desktop, com teste no cabeçalho real em 1440 e 1920 px.
- Pedido adicional: desktop até aproximadamente metade da tela; abrir por hover, fechar ao sair, manter clique/teclado e toque no celular. Cinco grupos em uma linha para caber na altura pedida.
- Áudio local de 29/10, transcrito com faster-whisper local: Lançamentos abre Best Sellers com filtro da tag novo; Pré-venda exibe aviso de produtos em breve; Consertos no plural aponta para a seção Reparos e Consertos da Garantia, mantendo o WhatsApp já existente.
- Para Pré-venda, oferecer página do tema tanto em um cadastro nativo /pre-venda/ quanto no endereço funcional /search/?eora_preorder=1, que dispensa criar conteúdo no painel. O link do menu continua configurável.
- Cobrir esquema do editor, destinos e aviso, filtro novo (URL, formulário, limpar e histórico), PHP Twig e navegador. Comparar fotos/títulos/links da prévia antes/depois do deploy para comprovar preservação.
- Usar revisão independente e manter os PDFs alterados no checkout original intactos.

## Progresso

- Prévia anterior salva em C:/Temp/eora-menu-cleanup/before.html, com galerias exportadas em previous-galleries.json. São quatro fotos padrão, duas de Garantia e quatro da comunidade; demais grupos usam as padrão.
- Áudio transcrito em C:/Temp/eora-menu-cleanup/audio-transcript.json.
- RED→GREEN: controles antigos no editor (59→0), recuo do desktop (0→36/48 px), abertura por hover e fechamento ao sair, painel até metade da tela, filtro novo no URL/formulário/histórico/limpar.
- Implementados aviso Pré-venda em rota funcional do tema e âncora Reparos e Consertos. Não há conexão ao painel para criar uma página nativa; o aviso funciona sem esse cadastro.
- Decisão: remover controles sem regravar as preferências do lojista. Ler internamente os valores antigos é compatibilidade e não é cópia para os registros das galerias novas. Verificar fotos renderizadas após deploy antes de concluir.
- Revisão independente: corrigidos o fechamento ao entrar em outro link do cabeçalho e Escape/foco após hover. Testes reproduziram as falhas antes das correções e passaram depois. Geometria 1200×700 conferida sem overflow.
- Regressões Best Sellers: navegador em 320/390/767/768/1440/1920 px; filtros combinados, ordenação, histórico, galerias e 137 produtos em seis páginas passaram.
