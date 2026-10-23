const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {test} = require('node:test');
const h = require('./sobre-eora-harness.cjs');
const kinds = ['press', 'sustainability', 'timeline', 'values'];
function fixture(kind, count) {
    const data = h.context();
    data.settings[`sobre_eora_${kind}_images`] = Array.from({length: count}, (_, i) => ({image: `editorial-${i}.webp`, title: `Título ${i}`, description: `Descrição ${i}`, link: `https://example.com/item-${i}`, button: `Abrir ${i}`}));
    return data;
}
for (const kind of kinds) {
    test(`${kind}: só renderiza os itens cadastrados, na ordem e com seus textos/links`, () => {
        const data = fixture(kind, 11);
        const items = data.settings[`sobre_eora_${kind}_images`];
        [items[0], items[10]] = [items[10], items[0]];
        let html = h.render(data);
        assert.equal((html.match(/<article\b/g) || []).length, 11, 'Quantidade definida pela galeria, sem espaços ou limite antigo');
        assert(html.indexOf('editorial-10.webp') < html.indexOf('editorial-0.webp'), 'A ordem segue o arrastar da galeria');
        for (const i of [0, 10]) {
            assert(html.includes(`Título ${i}`));
            assert(html.includes(`Descrição ${i}`));
            assert(html.includes(`href="https://example.com/item-${i}"`));
            assert(html.includes(`Abrir ${i}`));
        }
        data.settings[`sobre_eora_${kind}_images`] = [items[0]];
        html = h.render(data);
        assert.equal((html.match(/<article\b/g) || []).length, 1, 'Remover da galeria remove da página, sem slot vazio');
        data.settings[`sobre_eora_${kind}_images`] = [];
        assert(!h.render(data).includes(`id="se-${kind}-title"`), 'Sem fotos, não cria a seção');
    });
    test(`${kind}: mobile acompanha a posição e mantém desktop quando ausente`, () => {
        const data = fixture(kind, 2);
        const mobileKey = `sobre_eora_${kind}_images_mobile`;
        data.settings[mobileKey] = [{image: 'recorte-celular.png'}, {image: 'recorte-segundo.webp'}];
        let html = h.render(data);
        assert.equal((html.match(/<source\b/g) || []).length, 2, 'Galeria mobile completa fornece as alternativas');
        assert(html.includes('recorte-celular.png'), 'Usa o arquivo real da galeria, sem deduzir extensão/nome');
        data.settings[mobileKey].shift();
        html = h.render(data);
        assert.equal((html.match(/<source\b/g) || []).length, 0, 'Galeria mobile incompleta usa desktop, sem deslocar a foto do segundo item para o primeiro');
        assert(html.includes('editorial-1.webp'), 'Desktop permanece disponível');
        data.settings[mobileKey] = [{image: 'recorte-celular.png'}, {image: 'recorte-segundo.webp'}];
        data.settings[mobileKey].reverse();
        data.settings[`sobre_eora_${kind}_images`].reverse();
        html = h.render(data);
        const first = html.split('<article')[1].split('</article>')[0];
        assert(first.includes('recorte-segundo.webp') && first.includes('Título 1'), 'Reordenar ambas mantém foto e conteúdo associados');
        data.settings[`sobre_eora_${kind}_enabled`] = false;
        assert(!h.render(data).includes(`id="se-${kind}-title"`), 'Continua respeitando a ativação da seção');
    });
}
test('Painel usa galerias expansíveis e mantém somente o par de imagens dos fundadores', () => {
    const config = fs.readFileSync(path.join(h.root, 'config/settings.txt'), 'utf8').split(/\r?\n/);
    const blocks = [];
    let block;
    for (const row of config.slice(config.indexOf('Sobre EORA') + 1)) {
        if (/^\S/.test(row)) break;
        if (/^\t[^\t\s]/.test(row)) { block = {type: row.trim(), props: {}}; blocks.push(block); }
        else if (block) { const match = row.match(/^\t\t(\w+) = (.*)$/); if (match) block.props[match[1]] = match[2]; }
    }
    const galleries = blocks.filter(b => b.type === 'gallery');
    assert.equal(galleries.length, 8, 'Uma galeria desktop e outra mobile por seção repetível');
    for (const kind of kinds) for (const suffix of ['', '_mobile']) {
        const field = galleries.find(b => b.props.name === `sobre_eora_${kind}_images${suffix}`);
        assert(field, 'Galeria nativa disponível no personalizador');
        assert.equal(field.props.gallery_more_info, suffix ? undefined : 'true', 'Metadados editados apenas no desktop, evitando duplicação de textos');
    }
    assert.equal(blocks.filter(b => b.type === 'image').length, 2, 'Sem dezenas de uploads fixos no painel');
});
