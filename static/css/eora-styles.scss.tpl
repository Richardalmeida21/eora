/* EORA CUSTOM STYLES - RESTRITO À PÁGINA DE PRODUTO */

/* Ocultar elementos nativos apenas na página de produto SE o Hero EORA estiver ativo */
body.template-product:not(.eora-native-layout) .js-product-description-base { display: none !important; }
body.template-product:not(.eora-native-layout) .js-banner-produto, 
body.template-product:not(.eora-native-layout) .js-variantes-produto, 
body.template-product:not(.eora-native-layout) .js-sequencia-fotos-produto, 
body.template-product:not(.eora-native-layout) .js-texto-campanha-produto { display: none !important; }
body.template-product:not(.eora-native-layout) .js-add-to-wishlist, 
body.template-product:not(.eora-native-layout) .js-wishlist-button, 
body.template-product:not(.eora-native-layout) .product-wishlist, 
body.template-product:not(.eora-native-layout) .wishlist-btn, 
body.template-product:not(.eora-native-layout) .js-product-wishlist, 
body.template-product:not(.eora-native-layout) [data-js="wishlist"], 
body.template-product:not(.eora-native-layout) [class*="wishlist"], 
body.template-product:not(.eora-native-layout) [class*="favorite"] { display: none !important; }

/* Ajustes globais de layout */
html, body { overflow-x: hidden !important; }

/* Estilos do Hero EORA (Apenas Produto) */
body.template-product:not(.eora-native-layout) #single-product .container-fluid { padding: 0 !important; max-width: 100% !important; }
body.template-product:not(.eora-native-layout) #single-product .product-image-column { display: none !important; }
body.template-product:not(.eora-native-layout) #single-product .product-info-column { height: 0 !important; min-height: 0 !important; overflow: hidden !important; padding: 0 !important; margin: 0 !important; border: none !important; }

#eora-hero { position: relative !important; width: 100vw !important; max-width: 100vw !important; overflow: hidden !important; background: #f5f5f3 !important; height: 75vh !important; margin-left: 0 !important; transition: height 0.4s cubic-bezier(0.25, 1, 0.5, 1) !important; }
#eora-hero img.eora-hero-img { width: 100% !important; height: 100% !important; object-fit: cover !important; object-position: center center !important; display: block !important; }

/* Variantes e Fotos EORA */
.eora-pp-variantes { box-sizing: border-box !important; padding: 0 !important; background: #fff !important; }
.eora-pp-variantes-titulo { font-size: 11px !important; letter-spacing: 8px !important; text-transform: uppercase !important; color: #555 !important; text-align: center !important; padding: 40px 0 24px !important; font-weight: 700 !important; }
.eora-pp-variantes-grid { display: grid !important; width: 100% !important; gap: 4px !important; grid-template-columns: repeat(3, 1fr) !important; }
.eora-pp-variante-item { cursor: pointer !important; }
.eora-pp-variante-item.eora-ativa { border-bottom: 3px solid #111 !important; }
.eora-pp-variante-img { width: 100% !important; padding: 32px 20px !important; box-sizing: border-box !important; display: flex !important; justify-content: center !important; position: relative; }
.eora-pp-variante-img img { width: 100% !important; height: auto !important; display: block !important; transition: opacity .4s ease; }
.eora-pp-variante-img img.eora-img-hover { position: absolute !important; top: 0 !important; left: 0 !important; width: 100% !important; height: 100% !important; padding: 32px 20px !important; object-fit: contain !important; opacity: 0 !important; }
.eora-pp-variante-item:hover .eora-pp-variante-img img:not(.eora-img-hover) { opacity: 0 !important; }
.eora-pp-variante-item:hover .eora-pp-variante-img img.eora-img-hover { opacity: 1 !important; }

.eora-pp-vf-grid { display: grid !important; width: 100% !important; grid-template-columns: 1fr 1fr !important; gap: 4px !important; }
.eora-pp-vf-item img { width: 100% !important; height: 100% !important; object-fit: cover !important; display: block !important; }

/* Grid Tryon Icon (Home) */
.eora-grid-tryon { 
    position: absolute !important; 
    top: 10px !important; 
    left: 10px !important; 
    z-index: 100 !important; 
    background: #fff !important; 
    border-radius: 50% !important; 
    width: 32px !important; 
    height: 32px !important; 
    display: flex !important; 
    align-items: center !important; 
    justify-content: center !important; 
    cursor: pointer !important; 
    box-shadow: 0 2px 8px rgba(0,0,0,0.15) !important; 
    border: none !important;
}
.eora-grid-tryon svg { width: 18px !important; height: 18px !important; fill: none !important; stroke: #000 !important; stroke-width: 2.2 !important; }

/* Reset de fontes e textos específicos */
#eora-hero, .eora-pp-variantes, .eora-pp-campanha, .eora-pp-alternados, .eora-provador-btn { 
    font-family: "Hanken Grotesk", sans-serif !important; 
}

/* Floating Bar e Outros */
.eora-floating-bar { position: fixed !important; bottom: 20px !important; left: 50% !important; transform: translateX(-50%) !important; background: #fff !important; padding: 4px !important; display: flex !important; align-items: center !important; z-index: 900 !important; box-shadow: 0 2px 12px rgba(0,0,0,0.12) !important; border-radius: 3px !important; }
.eora-float-buy { background: #000 !important; color: #fff !important; border: none !important; padding: 0 18px !important; font-size: 10px !important; font-weight: 600; text-transform: uppercase; height: 32px !important; cursor: pointer !important; }

/* Accordion de especificações */
.eora-toggle-btn { width: 100% !important; padding: 12px 0 !important; border-top: 1px solid #efefef !important; background: transparent !important; display: flex !important; justify-content: space-between !important; align-items: center !important; cursor: pointer !important; border-left: none !important; border-right: none !important; }
.eora-toggle-content { display: none; padding: 15px 0 !important; }

/* Provador Button */
.eora-provador-btn { display: flex !important; background: #fff !important; border: 1px solid #000 !important; padding: 10px 20px !important; cursor: pointer !important; align-items: center !important; justify-content: center !important; width: 100% !important; max-width: 250px !important; }
.eora-provador-text { font-size: 12px !important; font-weight: 600 !important; text-transform: uppercase !important; margin-left: 8px !important; color: #000 !important; }
