# Galerias da página Sobre

Pedido: trocar os muitos campos de imagem fixos por “+ Adicionar imagem”, para cadastrar apenas os itens necessários e reduzir a poluição do painel. Usuário confirmou que ainda não há imagens/textos preenchidos; não é necessária migração de conteúdo.

Decisão: usar `gallery` nativa em Press, Sustentabilidade, História e Valores, cada uma com uma galeria desktop e uma mobile opcional. O título/descrição/link/botão vêm dos metadados nativos de cada imagem (`gallery_more_info`). Ao usar mobile separado, manter a mesma quantidade e ordem da desktop; uma galeria mobile vazia/incompleta usa desktop na seção inteira, evitando deslocar pares durante o cadastro. Fundadores mantém duas fotos, pois é um único bloco, com título/texto existentes. Mantêm-se as medidas, proporções e carregamento responsivo já validados.

Referências: https://docs.nuvemshop.com.br/help/settings-txt e https://nuvemshop.dev/themes/classic-themes/theme-features/homepage . A galeria nativa tem uma imagem por item; por isso desktop/mobile são galerias distintas, como no restante do tema.

## Execução

- [x] Testar cadastro com 1/11 itens, ordem e metadados, exclusão, lista vazia e foto mobile opcional.
- [x] Substituir 33 pares fixos por oito galerias, remover defaults de slots e os 33 suportes mobile ainda não publicados; manter o par Fundadores.
- [x] Ler as galerias nos templates, receber `image_mobile` explícita e atualizar fixtures/testes de responsividade.
- [x] Executar suítes da Sobre, imagens, schema e banners; inspecionar captura e revisar diff/documentação.

Sem publicação, sem mudanças adicionais nos banners de outras páginas.

Verificação: galerias 9/9, banners 25/25, Sobre funcional e fotos em seis larguras/DPR 2 passaram. Schema validado com 1903 campos nomeados e 223 campos de imagem no tema inteiro (antes desta simplificação: 2054/289). Captura `C:/Temp/eora-sobre-preview/sobre-1440.png` inspecionada. Revisão independente aprovou, incluindo o teste de galeria mobile incompleta que deve usar desktop integralmente. Limitação anterior de comparação textual entre os dois roteadores de Bolsas permanece como registrada no plano de imagens; nenhum roteador foi alterado.
