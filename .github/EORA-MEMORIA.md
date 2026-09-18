# Diagnostico de memoria — 18/09/2026

O usuario relatou Out of Memory ao abrir o editor autenticado da Nuvemshop, no Edge e no Chrome, com a versao de banners ja publicada.

## Evidencias

- Windows: evento 2004 do Microsoft-Windows-Resource-Exhaustion-Detector as 15:40:21, 16:01:34 e 16:11:14, indicando memoria virtual insuficiente. A captura do usuario mostra 16:13.
- Medicao local: 61,63 GiB comprometidos de um limite de 63,70 GiB (96%). Isso e memoria comprometida do sistema, nao quantidade de RAM fisica.
- A previa publica respondeu HTTP 200: home com aproximadamente 1 MB de HTML; Bolsas Eora com aproximadamente 356 KB. O HTML confirmava JS e CSS de banners na versao 20260918-6.
- Em Chromium novo, amostras aos 3/6/9/12 segundos depois de DOMContentLoaded: heap JavaScript da home entre 17 e 20 MiB, Bolsas Eora entre 16 e 17 MiB, sem erros JS. Essas medidas nao incluem toda a memoria do navegador e nao descartam vazamentos de longa duracao.
- A URL do editor redirecionou para login. O editor autenticado, suas extensoes e o iframe no contexto real nao foram reproduzidos. Nao atribuir a falha exclusivamente ao tema ou exclusivamente a um programa local.

## Reducao de consumo no tema

Antes, cada resposta completa de busca era processada por DOMParser, e seu template era guardado no cache. A referencia ao template mantinha o documento de busca associado; imagens fora do feed tambem podiam ser processadas.

Agora, somente o template controlado por `search-feed.tpl` e extraido e interpretado em um template inerte. O extrator depende do formato atual, com campos escapados e sem templates aninhados. O cache guarda texto serializado, sem documentos DOM, limitado a 40 paginas e 2 MiB estimados de texto, com expiracao de cinco minutos. Isso nao limita o consumo total da pagina nem diminui o tamanho da resposta transferida pela plataforma.

Validacao: `node .github/tests/bolsas-eora-memory.cjs`. Seis respostas com 30 mil elementos alheios ao feed resultaram em 377 nos DOM apos coleta no caso normal e 389 no caso de feeds grandes. Testados descarte por tamanho, expiracao, reaproveitamento, ausencia de execucao de scripts e de requisicoes de imagens externas ao feed. Testes de desempenho, filtros, banners e navegacao tambem passaram.

Publicar `static/js/bolsas-eora.js` e `snipplets/bolsas-eora/index.tpl` juntos (JS v20260918-7). Esta alteracao foi validada localmente; nao foi enviada para a loja durante o diagnostico.

## Proxima verificacao do erro original

Salvar o trabalho, reiniciar o computador e abrir somente o editor em um navegador. Conferir Memoria > Confirmado no Gerenciador de Tarefas. Se a falha persistir com memoria disponivel, medir a aba autenticada (Shift+Esc no navegador) e a previa separadamente para identificar qual processo cresce. Nao encerrar processos de outros projetos automaticamente.
