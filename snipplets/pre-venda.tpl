<main class="eora-preorder" aria-labelledby="eora-preorder-title">
    <div>
        <p class="eora-preorder__eyebrow">EORA</p>
        <h1 id="eora-preorder-title">Pré-venda</h1>
        <p>Os produtos de pré-venda serão disponibilizados aqui em breve.</p>
        <a href="{{ settings.eora_menu_launches_url | default('/best-sellers1/?bs_filters=%7B%22bs_new%22%3A%221%22%7D') | setting_url }}">Conhecer lançamentos</a>
    </div>
</main>
<style>
    .eora-preorder { display: grid; place-items: center; min-height: 55vh; padding: 80px 24px; text-align: center; font-family: var(--body-font, sans-serif); }
    .eora-preorder > div { max-width: 560px; }
    .eora-preorder__eyebrow { font-size: 11px; letter-spacing: .18em; margin-bottom: 24px; }
    .eora-preorder h1 { font: inherit; font-size: clamp(24px, 3vw, 36px); text-transform: uppercase; letter-spacing: .06em; margin: 0 0 24px; }
    .eora-preorder p { line-height: 1.8; }
    .eora-preorder a { display: inline-block; padding: 12px 0; margin-top: 20px; text-transform: uppercase; font-size: 12px; text-underline-offset: 6px; color: inherit; }
</style>
