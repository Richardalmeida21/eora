// Actual PHP Twig, matching the Nuvemshop Settings object contract.
const assert = require('node:assert/strict');
const {spawnSync} = require('node:child_process');
const {root, context} = require('./menu-harness.cjs');
const php = process.env.SOBRE_PHP_BIN || 'C:/Temp/eora-sobre-php/runtime/php.exe';
const autoload = process.env.SOBRE_TWIG_AUTOLOAD || 'C:/Temp/eora-sobre-php/autoload.php';
const program = String.raw`
error_reporting(E_ALL & ~E_DEPRECATED & ~E_USER_DEPRECATED);
require $argv[1];
if (class_exists('Twig_Autoloader')) Twig_Autoloader::register();
$twig = new Twig_Environment(new Twig_Loader_Filesystem($argv[2]), ['autoescape' => false]);
foreach (['static_url', 'settings_image_url', 'setting_url', 'product_image_url', 'money'] as $name) {
    $twig->addFilter(new Twig_SimpleFilter($name, function ($v) { return is_array($v) && isset($v['url']) ? $v['url'] : $v; }));
}
$twig->addFilter(new Twig_SimpleFilter('has_custom_image', function () { return false; }));
$data = json_decode(stream_get_contents(STDIN), true);
if ($data['objectSettings']) $data['settings'] = (object) $data['settings'];
echo $twig->render($data['file'], $data);
`;
for (const file of ['snipplets/navigation/eora-menu.tpl', 'snipplets/navigation/eora-menu-next.tpl']) for (const objectSettings of [true, false]) for (const mode of ['desktop', 'mobile']) {
    const data = {...context({settings: {eora_menu_bags_url: '/colecao-bolsas-custom/', eora_menu_shop_title: 'Shop EORA'}}), objectSettings, mode, file};
    const output = spawnSync(php, ['-r', program, autoload, root], {input: JSON.stringify(data), encoding: 'utf8'});
    assert.equal(output.status, 0, output.stderr || output.error?.message);
    assert.equal(output.stderr, '');
    assert.ok(output.stdout.includes('href="/colecao-bolsas-custom/"'));
    assert.ok(output.stdout.includes('Shop EORA'));
    assert.equal((output.stdout.match(/<img /g) || []).length, mode === 'desktop' ? (file.includes('-next') ? 5 : 10) : (file.includes('-next') ? 28 : 24));
}
console.log('PASS PHP Twig: settings object/array, desktop/mobile, configurable links/titles and all galleries.');
