# Imagens responsivas e campos mobile

Atualização: os campos fixos da Sobre descritos neste registro foram substituídos pelas galerias nativas do [plano de simplificação](2026-10-23-sobre-galleries.md), a pedido do usuário. Medidas e correções de qualidade permanecem.

Objetivo: permitir fotos mobile na página Sobre e corrigir limites de resolução e descritores incorretos nos banners do tema, mantendo o layout existente.

Decisões: usar os thumbnails nativos da Nuvemshop (480, 640, 1024, 1400 e 1920 px), `srcset`/`sizes` e `<picture>` até 767 px. As 34 fotos editoriais terão desktop 1920 × 2400 e mobile opcional 1600 × 2000 (4:5), suficientes para 2× na maior largura de exibição atual. Sem upload mobile, manter desktop. Não criar conteúdo editorial ou reprocessar os uploads existentes.

Fonte dos thumbnails: https://docs.tiendanube.com/help/webp-y-thumbnails — `original` é limitado a 1024 px; a plataforma reduz imagens e não amplia fontes menores.

## Plano de implementação

- [x] 1. Testar o comportamento atual e adicionar regressão que detecte ausência de seleção mobile, fallback e resolução em telas de alta densidade.
- [x] 2. Adicionar 34 campos mobile, suportes de upload, orientações e seleção responsiva compartilhada em `snipplets/sobre-eora/image.tpl`. Ajustar os `sizes` por seção e documentar as medidas.
- [x] 3. Revisar os banners do tema: corrigir descritores, remover largura original inventada, disponibilizar candidatos maiores onde hoje faltam e conservar dimensões/metadados reais quando disponíveis.
- [x] 4. Executar testes Twig e browser em 320, 390, 767, 768, 1440 e 1920 px, com e sem imagens mobile e sem JS. Inspecionar capturas, revisar o diff e registrar limites da validação.

Revisão: campos opcionais nunca devem apontar para suportes de 1 pixel; itens desativados e sem foto desktop continuam ocultos; novas imagens mantêm proporção 4:5; tamanhos declarados devem corresponder aos thumbnails; uploads de baixa resolução continuam exigindo substituição por uma fonte maior.

Execução: alterações locais na branch `fix/mobile-images-banner-quality`, sem publicação. A suíte Sobre passou antes das alterações. Documentação fica em `.github`, já excluída do deploy FTP.

## Evidências

- `sobre-eora.cjs`: passou; conteúdo, itens desativados, rotas, carrosséis, produtos e modo sem JS. Captura real em `C:/Temp/eora-sobre-preview/sobre-390.png` inspecionada.
- `sobre-eora-images.cjs`: passou; 34 pares, seis larguras, DPR 2, com e sem upload mobile. A fixture respeita o limite de 1600 px da fonte mobile sugerida.
- `banner-image-quality.cjs`: 25 testes passaram, incluindo renderização de 12 componentes nos dois modos e carregamento pelo lazysizes real do tema em 390/1440 px e DPR 2.
- `theme-editor-settings.cjs`: passou, 2054 campos nomeados e 289 campos de imagem; cadastro vazio, legado, upload, desativação e vídeo.
- Best Sellers: validação Twig e suíte browser passaram nas seis larguras. Bolsas e Óculos: suítes browser passaram, com filtros, galerias e layout mobile.
- Revisão independente: sem defeitos funcionais restantes; corrigido `sizes` do primeiro banner de campanha e categoria, e refinado teto mobile da fixture.
- Limitação anterior: `bolsas-eora-harness.cjs --check` falha na linha 183 porque exige igualdade textual entre `templates/page.tpl` e `snipplets/templates/page.tpl`. As cópias já diferem em HEAD antes deste trabalho; os dois arquivos permanecem sem alteração. Os testes funcionais de Bolsas passaram.
- Limite: testes locais usam fixtures e não confirmam o processamento do CDN da loja. Uploads existentes de baixa resolução exigem fonte maior. Sem push ou publicação.
