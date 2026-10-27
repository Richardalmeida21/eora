const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const {chromium} = require('playwright');
const h = require('./sobre-eora-harness.cjs');
assert(fs.existsSync(path.join(h.root, 'snipplets/sobre-eora/index.tpl')), 'A página Sobre deve ter seu próprio template configurável');
let data = h.context();
let output = h.render(data);
assert(!output.includes('data-se-card'), 'Sem materiais cadastrados não cria carrosséis vazios');
assert(output.includes('História original da EORA.'), 'Preserva o conteúdo atual enquanto a apresentação não foi preenchida');
data = h.demoContext();
const removed = data.settings.sobre_eora_press_images.splice(1, 1)[0];
output = h.render(data);
assert(!output.includes(removed.title), 'Remover uma imagem da galeria remove seu título e texto');
assert(output.includes('sobre_eora_press_3.jpg'), 'Remover um item preserva os outros');
assert(output.includes('<strong>Design com identidade.</strong>'), 'Texto dos fundadores mantém negrito');
assert(output.includes('<em>Raízes no Brasil.</em>'), 'Frase mantém itálico');
assert(!output.includes('id="se-quote-title"'), 'Titulo da missao permanece opcional para cadastros existentes');
data.settings.sobre_eora_quote_title = 'Nossa missao <EORA>';
output = h.render(data);
assert(output.includes('id="se-quote-title">Nossa missao &lt;EORA&gt;</h2>'), 'Titulo cadastrado aparece acima da missao com HTML escapado');
assert(output.includes('aria-labelledby="se-quote-title"'), 'Missao recebe o titulo como nome acessivel');
delete data.settings.sobre_eora_quote_title;
data.settings.sobre_eora_sustainability_enabled = false;
assert(!h.render(data).includes('id="se-sustainability"'), 'Bloco desativado não aparece na página');
data.settings.sobre_eora_community_enabled = false;
assert(!h.render(data).includes('data-be-product='), 'Seleção de produtos respeita a ativação da seção');
// Executa o roteador de produção; as outras páginas continuam em seus próprios templates.
for (const [id, marker] of [['best-sellers/index.tpl', 'best'], ['gift-guide-banners.tpl', 'gifts'], ['campaign/index.tpl', 'campaign'], ['page-content/behind-the-lens-index.tpl', 'lentes'], ['garantia-eora.tpl', 'garantia'], ['bolsas-eora/index.tpl', 'bolsas'], ['oculos-eora/index.tpl', 'oculos'], ['page-content/who-uses.tpl', 'quem']]) h.compile('snipplets/' + id, '<div data-route="' + marker + '"></div>');
const router = h.compile('sobre-page-router', fs.readFileSync(path.join(h.root, 'templates/page.tpl'), 'utf8'));
for (const handle of ['sobre1', 'nossa-marca']) {
    const input = h.context();
    input.page.handle = handle;
    input.settings.sobre_eora_page_url = 'nossa-marca';
    input.settings.campaign_page_01_url = handle;
    assert(router.render(input).includes('data-se-page'), 'Roteia a página Sobre mesmo se antes usava uma campanha');
}
for (const [handle, marker] of [['best-sellers1', 'best'], ['bolsas-eora', 'bolsas'], ['oculos-eora', 'oculos'], ['garantia-eora', 'garantia']]) {
    const input = h.context(); input.page.handle = handle;
    const result = router.render(input);
    assert(result.includes('data-route="' + marker + '"') && !result.includes('data-se-page'), 'Mantém a rota existente: ' + handle);
}
data = h.context(); data.page.handle = 'politica-de-privacidade';
assert(!router.render(data).includes('data-se-page'), 'Página institucional comum mantém o modelo original');
const server = h.server(0);
(async () => {
    const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
    try {
        const page = await browser.newPage();
        const errors = [];
        page.on('pageerror', e => errors.push(e.message));
        await page.goto('http://127.0.0.1:' + server.address().port);
        await page.locator('.se-page img').evaluateAll(images => images.forEach(image => { image.loading = 'eager'; }));
        await page.evaluate(() => Promise.all(Array.from(document.querySelectorAll('.se-page img')).map(image => image.decode())));
        assert(await page.locator('.se-page img').evaluateAll(images => images.every(image => image.complete && image.naturalWidth > 0)), 'Todas as imagens da prévia carregam');
        for (const width of [1440, 390, 320]) {
            await page.setViewportSize({width, height: 950});
            const peeks = await page.locator('[data-se-carousel]').evaluateAll(sections => sections.map(section => {
                const track = section.querySelector('[data-se-track]');
                const bounds = track.getBoundingClientRect();
                const cards = [...track.querySelectorAll('[data-se-card]')].map(card => card.getBoundingClientRect());
                return {id: section.id, overflow: track.scrollWidth > track.clientWidth + 2,
                    peek: cards.some(card => card.left > bounds.left && card.left < bounds.right - 8 && card.right > bounds.right + 8)};
            }));
            for (const carousel of peeks.filter(carousel => carousel.overflow)) {
                assert(carousel.peek, `${width}px: ${carousel.id} mostra parte do proximo slide`);
            }
            assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), 'Sem rolagem horizontal da página');
            const before = await page.locator('#se-timeline [data-se-track]').evaluate(el => el.scrollLeft);
            await page.locator('#se-timeline [data-se-next]').click();
            await page.waitForFunction(previous => document.querySelector('#se-timeline [data-se-track]').scrollLeft > previous + 50 && document.querySelector('#se-timeline [data-se-dot="1"]').getAttribute('aria-current') === 'true', before);
            const active = await page.locator('#se-timeline [data-se-dot][aria-current="true"]').getAttribute('data-se-dot');
            assert(Number(active) > 0, 'Navegação avança imagem e texto da linha do tempo');
            await page.locator('#se-timeline [data-se-dot="0"]').click();
            await page.waitForFunction(() => document.querySelector('#se-timeline [data-se-track]').scrollLeft < 5);
            const values = page.locator('.se-values');
            assert.equal(await values.locator('[data-se-card]').count(), 3, 'Valores preserva todos os itens cadastrados');
            if (width < 768) {
                await values.locator('[data-se-next]').click();
                await page.waitForFunction(() => document.querySelector('.se-values [data-se-track]').scrollLeft > 50);
                await values.locator('[data-se-track]').focus();
                await page.keyboard.press('End');
                await page.waitForFunction(() => document.querySelector('.se-values [data-se-next]').disabled);
                await page.keyboard.press('Home');
                await page.waitForFunction(() => document.querySelector('.se-values [data-se-track]').scrollLeft < 5);
            } else {
                assert.equal(await values.locator('[data-se-controls]').isVisible(), false, 'Valores usa grade sem controles no desktop');
            }
            await page.screenshot({path: 'C:/Temp/eora-sobre-preview/sobre-' + width + '.png', fullPage: true});
        }
        assert.deepEqual(errors, [], 'JavaScript da página não gera erros');
        const ids = await page.locator('#se-community [data-be-product]').evaluateAll(nodes => nodes.map(n => n.dataset.beProduct));
        assert.deepEqual(ids, ['9000', '9001', '9002', '9003', '9004', '9005'], 'Mantém a seleção e a ordem cadastradas dos produtos');
        const globalMain = fs.readFileSync(path.join(h.root, 'static/css/style-critical.scss'), 'utf8').match(/#single-product,\s*main,[\s\S]*?\}/)[0];
        await page.addStyleTag({content: globalMain});
        await page.setViewportSize({width: 1920, height: 1080});
        assert((await page.locator('.se-page').boundingBox()).width <= 1600, 'Os estilos globais do tema não expandem a página editorial em telas largas');
        await page.waitForFunction(() => document.querySelector('.se-values [data-se-controls]').hidden);
        assert(await page.locator('.se-values [data-se-track]').evaluate(track => track.scrollWidth <= track.clientWidth), 'Valores volta à grade sem rolagem ao ampliar a tela');
        await page.addScriptTag({path: path.join(h.root, 'static/js/sobre-eora.js')});
        assert.equal(await page.locator('#se-timeline [data-se-dot]').count(), 5, 'Reinicializar não duplica os controles');
        await page.goto('http://127.0.0.1:' + server.address().port + '/?empty=1');
        assert.equal(await page.locator('[data-se-carousel]').count(), 0, 'Nenhuma seção ou espaço de carrossel sem cadastro');
        const noJs = await browser.newPage({javaScriptEnabled: false, viewport: {width: 390, height: 844}});
        await noJs.goto('http://127.0.0.1:' + server.address().port);
        assert.equal(await noJs.locator('#se-timeline [data-se-card]').count(), 5, 'Fotos e história continuam acessíveis sem JavaScript');
        assert.equal(await noJs.locator('#se-timeline [data-se-controls]').isVisible(), false, 'Não exibe botões sem funcionamento quando JS está desligado');
        assert(await noJs.locator('.se-values [data-se-track]').evaluate(track => track.scrollWidth > track.clientWidth), 'Valores permite rolagem nativa no mobile sem JavaScript');
        console.log('PASS: conteúdo real Twig, galerias vazias/removidas, seções desativadas, formatação, produtos/ordem, 3 larguras, carrosséis e modo sem JS.');
    } finally { await browser.close(); server.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
