# Imagens e banners — medidas e qualidade

| Local | Desktop | Mobile | Proporção / comportamento |
| --- | --- | --- | --- |
| Sobre: Fundadores, Press, Sustentabilidade, História, Valores | 1920 × 2400 px | 1600 × 2000 px | 4:5; upload mobile opcional até 767 px, com fallback desktop |
| Banner principal da home | 3840 × 1700 px | 1640 × 2000 px | Mantidas as proporções indicadas pelo personalizador; usa `cover` e pode recortar conforme a tela |
| Banner horizontal | 2880 × 1100 px | 1600 × 3040 px | Mesmas proporções anteriores; configure largura/altura de exibição com a mesma proporção da arte |
| Banner duplo, cada imagem | 1920 × 2400 px | Usa a mesma foto | 4:5 no desktop e recorte quadrado no mobile; manter assunto principal no centro |
| Foto de fallback de vídeo + botão | Pelo menos 1920 px de largura | Usa a mesma foto | O recorte muda entre desktop e mobile; uma arte horizontal pode perder as laterais no celular |
| Outras galerias, categorias e campanhas | Pelo menos 1920 px de largura para fotos grandes | Pelo menos 1600 px de largura para artes de largura total | Manter a proporção configurada para cada bloco; para cards pequenos, considerar largura exibida × densidade da tela |

Estas são medidas de arquivo, não de exibição CSS. O layout mantém as proporções e os recortes já existentes. Use uma fonte maior para banners que ocupam a tela toda em monitores de alta densidade. Evite ampliar um arquivo pequeno ou usar imagens recebidas com compressão de mensageiros.

Na página Sobre, Press, Sustentabilidade, História e Valores usam galerias nativas com “+ Adicionar imagem”, uma desktop e outra mobile opcional por seção. Os textos e links ficam no lápis da imagem desktop. Se usar mobile separado, mantenha a mesma quantidade e ordem da desktop. Uma lista mobile vazia ou incompleta usa as fotos desktop. Fundadores conserva apenas seu par de fotos.

Os banners revisados oferecem candidatos de 480, 640, 1024, 1400 e 1920 px com descritores corretos. Banners com lazyload usam a largura medida pelo lazysizes. No banner principal e na grade da home, o arquivo completo também pode ser escolhido quando a galeria informa sua largura real acima de 1920 px; não se presume mais que todo original tenha 3200 px. Fotos editoriais das galerias Bolsas/Óculos também oferecem até 1920 px. Os banners de catálogo que já usam o arquivo completo mantêm esse comportamento.

A Nuvemshop não amplia uploads pequenos: `settings_image_url('original')` significa até 1024 px, `xlarge` até 1400 e `1080p` até 1920. Referência: [WebP e thumbnails](https://docs.tiendanube.com/help/webp-y-thumbnails). Ajustar o código ou a medida sugerida no personalizador não regenera detalhes ausentes dos arquivos antigos.

Validação local:

```powershell
$env:NODE_PATH = 'C:\Temp\eora-best-sellers-validation\node_modules'
node .github/tests/sobre-eora.cjs
node .github/tests/sobre-eora-images.cjs
node --test .github/tests/sobre-eora-galleries.cjs
node --test .github/tests/banner-image-quality.cjs
```

Os testes renderizam os templates reais. A suíte de imagens usa fixtures com tamanhos equivalentes aos thumbnails documentados; a confirmação de processamento dos uploads pelo CDN e da aparência das artes reais deve ocorrer após o envio pelo personalizador.
