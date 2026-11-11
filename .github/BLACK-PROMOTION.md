# Avisos EORABLACK

O tema personaliza o aviso nativo de 10% OFF comprando 2 ou mais da campanha Black friday 2026. A página do produto mostra a oferta antes da descrição curta, seguida de “Usando o cupom: EORABLACK” e “CUPOM DISPONÍVEL ATÉ 23:59”, em coral (#f76265). Os itens e o resumo do carrinho recebem o mesmo aviso.

A elegibilidade e o desconto continuam sendo calculados pela Nuvemshop. Nenhum cupom é aplicado pelo script. No produto e no resumo, a identificação exige o nome Black friday 2026 e a condição 10% / 2 unidades. Nos itens do carrinho, o componente privado só fornece o texto da oferta: a identificação é pela condição exata 10% OFF comprando 2 ou mais. Portanto, se houver outra campanha simultânea com essa mesma condição, será necessário distinguir sua identificação antes de reutilizar o código. Outros descontos e etiquetas de frete são preservados.

Os nós nativos são mantidos ocultos para preservar os hooks da plataforma. O script acompanha a substituição dos avisos por AJAX. A frase de prazo é fixa, conforme a referência; as datas reais de validade continuam no painel da promoção. Não é um contador.

Publicar juntos:

- `layouts/layout.tpl`
- `snipplets/product/product-form.tpl`
- `snipplets/cart-item-ajax.tpl`
- `static/css/black-promotion.css`
- `static/js/black-promotion.js.tpl`

Verificação local: `.github/tests/black-promotion.cjs` usa Chromium com avisos nativos de exemplo para testar texto, posição, cor, largura no celular, atualização de itens e remoção do desconto. As capturas em `C:/Temp/eora-black-promotion` são exemplos locais; não comprovam a campanha no ambiente publicado. Conferir uma promoção ativa na prévia da Nuvemshop antes da publicação.
