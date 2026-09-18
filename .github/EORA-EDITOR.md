# Correção de campos inválidos no editor — 18/09/2026

O console enviado pelo usuário contém quatro falhas de imagem com caminho `themes/baires/undefined` e uma exceção `Uncaught TypeError: Must specify an id` durante a inicialização da comunicação do editor. O HAR em Downloads estava vazio (0 bytes); não foi possível analisar requisições, respostas ou o bundle do painel por esse arquivo.

## Defeitos encontrados e correção local

- Na seção Página de inicio, abaixo de Carrusel de imágenes, existia um checkbox com descrição e sem `name`. Era um controle órfão: o checkbox válido `banner_horizontal` já existe na seção própria. O controle incompleto foi removido.
- Quatro campos `image` usavam apenas `name`, sem `original`: os dois banners duplos, a imagem alternativa do banner de vídeo da home e a imagem do banner de produto. Agora usam arquivos `original` distintos, seguindo o formato documentado pela Nuvemshop.
- Os quatro arquivos PNG originais são cópias do placeholder vazio já existente no tema. Os templates usam `has_custom_image` para mostrar somente imagens enviadas pelo lojista e preservam valores antigos de `settings` como alternativa. O vídeo continua tendo prioridade.

As quatro definições de imagem incompletas são compatíveis com as quatro falhas `undefined`. O checkbox sem nome é compatível com a exceção de identificador ausente. Sem reproduzir o editor autenticado ou examinar seu bundle e dados de inicialização, não se pode afirmar que a queda inteira está resolvida.

Referência: https://docs.nuvemshop.com.br/help/settings-txt — campos `image` usam `original`; campos `checkbox` usam `name`.

## Publicação

Enviar juntos os oito arquivos de produção:

- `config/settings.txt`
- `snipplets/home/home-banner-duplo.tpl`
- `snipplets/home/home-banner-video-botao.tpl`
- `snipplets/product/product-banner-video-botao.tpl`
- `static/banner_duplo_1_image.png`
- `static/banner_duplo_2_image.png`
- `static/banner_video_botao_image.png`
- `static/product_banner_image.png`

Nenhuma publicação foi executada durante esta correção. Se as imagens dos campos anteriormente inválidos não aparecerem no painel após o envio, recadastrá-las nos campos corrigidos; não há garantia de que o editor tenha armazenado uploads feitos com a definição anterior.

## Validação

`node .github/tests/theme-editor-settings.cjs` (dependência Twig disponível via NODE_PATH): valida identificadores únicos de 1.699 campos, referência `original` nas 191 imagens e renderização dos três templates com campos vazios, imagens antigas, novos uploads, seção desabilitada e vídeo. `git diff --check` também passou. Esses testes locais não reproduzem a aplicação proprietária do painel.

Após publicar, recarregar o editor e verificar se desaparecem `Must specify an id` e as quatro requisições `undefined`. Os avisos de CSP enviados estavam em modo report-only: aquela política apenas registra, sem bloquear. Os avisos de document.write e de falha do UserGuiding, isoladamente, não demonstram a causa do encerramento da aba.

## Condição adicional do computador

Durante esta investigação o Windows ainda estava há 28,64 dias sem reiniciar, com 68.285.001.728 bytes comprometidos de um limite de 68.393.086.976 bytes (aproximadamente 99,84%, com apenas 103 MiB de margem). Isso continua sendo uma condição suficiente para provocar falhas de alocação, além dos campos inválidos. O diagnóstico anterior identificou aproximadamente 32 GiB em seções comprometidas mantidas pelo Cisco ISE Posture.

Salvar trabalhos, reiniciar e testar novamente com margem de memória. Se a falha persistir, exportar um HAR sanitizado com conteúdo e tamanho maior que zero, desde a abertura do editor. Nenhum serviço ou aplicativo foi encerrado automaticamente.
