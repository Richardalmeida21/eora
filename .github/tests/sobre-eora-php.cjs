// Twig.js treats [] as object-property access; PHP Twig distinguishes arrays and objects.
// Run with SOBRE_PHP_BIN and SOBRE_TWIG_AUTOLOAD pointing to PHP and Twig's autoloader.
// Supports the classic Twig 1.x autoloader or Composer's vendor/autoload.php.
const assert = require('node:assert/strict');
const path = require('node:path');
const {spawnSync} = require('node:child_process');
const {test} = require('node:test');
const root = path.resolve(__dirname, '../..');
const php = process.env.SOBRE_PHP_BIN;
const autoload = process.env.SOBRE_TWIG_AUTOLOAD;
const kinds = ['press', 'sustainability', 'timeline', 'values'];
const program = String.raw`
error_reporting(E_ALL & ~E_DEPRECATED & ~E_USER_DEPRECATED);
require $argv[1];
if (class_exists('Twig_Autoloader')) { Twig_Autoloader::register(); }
$loader = new Twig_Loader_Filesystem($argv[2]);
$twig = new Twig_Environment($loader, ['autoescape' => false]);
foreach (['static_url', 'settings_image_url'] as $name) {
    $twig->addFilter(new Twig_SimpleFilter($name, function ($value) { return $value; }));
}
$twig->addFilter(new Twig_SimpleFilter('has_custom_image', function () { return false; }));
$twig->addFilter(new Twig_SimpleFilter('is_external', function ($value) { return (bool) preg_match('~^https?://~', $value); }));
$data = json_decode(stream_get_contents(STDIN), true);
if ($data['objectSettings']) { $data['settings'] = (object) $data['settings']; }
echo $twig->render('snipplets/sobre-eora/index.tpl', $data);
`;
function fixture(objectSettings) {
    const data = {objectSettings, settings: {sobre_eora_intro_enabled: true, sobre_eora_quote_enabled: true, sobre_eora_quote_text: 'Frase cadastrada'}, page: {name: 'Sobre', content: 'Introdução cadastrada'}, sections: {}};
    for (const kind of kinds) {
        data.settings[`sobre_eora_${kind}_enabled`] = true;
        data.settings[`sobre_eora_${kind}_title`] = `Seção ${kind}`;
        data.settings[`sobre_eora_${kind}_images`] = [
            {image: `${kind}-primeira.webp`, title: `Primeira ${kind}`, description: `Texto ${kind}`, link: 'https://example.com/materia', button: 'Ler conteúdo'},
            {image: `${kind}-segunda.webp`, title: `Segunda ${kind}`},
        ];
        data.settings[`sobre_eora_${kind}_images_mobile`] = [{image: `${kind}-mobile-1.webp`}, {image: `${kind}-mobile-2.webp`}];
    }
    return data;
}
function render(data) {
    const result = spawnSync(php, ['-r', program, autoload, root], {input: JSON.stringify(data), encoding: 'utf8'});
    assert.equal(result.status, 0, result.stderr || result.error?.message || result.stdout);
    assert.equal(result.stderr, '', 'PHP renders without warnings');
    return result.stdout;
}
for (const objectSettings of [true, false]) {
    test(`PHP Twig: published content renders with settings as ${objectSettings ? 'object' : 'array'}`, {skip: !php || !autoload ? 'Set SOBRE_PHP_BIN and SOBRE_TWIG_AUTOLOAD to run real PHP Twig' : false}, () => {
        const data = fixture(objectSettings);
        const html = render(data);
        assert(html.includes('Introdução cadastrada'));
        assert(html.includes('Frase cadastrada'), 'Enabled quote must survive dynamic settings access');
        assert.equal((html.match(/<article\b/g) || []).length, 8, 'All four enabled galleries render both uploaded cards');
        for (const kind of kinds) {
            for (const content of [`Seção ${kind}`, `Primeira ${kind}`, `Segunda ${kind}`, `Texto ${kind}`, `${kind}-mobile-1.webp`, `${kind}-mobile-2.webp`]) assert(html.includes(content), content);
            assert(html.indexOf(`${kind}-primeira.webp`) < html.indexOf(`${kind}-segunda.webp`), 'Preserves saved gallery order');
        }
        data.settings.sobre_eora_press_enabled = false;
        data.settings.sobre_eora_timeline_images = [];
        const filtered = render(data);
        assert(!filtered.includes('id="se-press"'), 'Disabled section remains absent');
        assert(!filtered.includes('id="se-timeline"'), 'Empty gallery remains absent');
        assert.equal((filtered.match(/<article\b/g) || []).length, 4);
    });
}
