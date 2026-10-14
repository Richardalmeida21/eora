# Portuguese product titles across storefront languages

The theme uses Portuguese product names for English and Spanish title displays. Descriptions, prices, inventory, variants, purchase forms and product URLs are not changed. Portuguese pages keep using the live native Portuguese field, so they never replace a new admin edit with an older snapshot.

## Operation

`.github/workflows/product-name-sync.yml` reads the catalog through GET requests every five minutes and generates private `snipplets/product-name-pt-v2-data.tpl` title data. Only that data file is uploaded by FTPS. It is not committed to the public repository or included in browser scripts. There are no additional browser requests, observers or JavaScript dependencies. GitHub schedules can be delayed; this is eventual synchronization, not an instant or guaranteed five-minute deadline.

The initial V2 snapshot is bootstrapped before deploying the stable `snipplets/product-name-pt.tpl` helper and title consumers. Bootstrap mode is removed only after those consumers are live. The publisher uploads a staging sibling, downloads it and verifies SHA-256. Nuvemshop rejects renaming over an existing file (HTTP/FTP probe returned 553), so the publisher first moves the old complete file to a backup, then moves the verified new file into place. The stable helper includes the current data with `ignore missing` and uses the backup during the switch. It falls back to the native name if neither snapshot exists. A transfer or checksum failure never moves the active file; a failed switch attempts restoration and still leaves a complete previous snapshot available to the helper. The regular theme deployment excludes generated, backup and staging files.

Missing IDs or missing language context preserve the native name. An empty, invalid or incomplete catalog aborts generation before upload and leaves the last good production file in place. The generator supports only GET catalog requests; it cannot overwrite names or any other product fields in the admin panel.

The workflow renews its enabled state through the GitHub Actions API to avoid automatic suspension of scheduled workflows after repository inactivity. It only does so while already active, respecting a manually disabled workflow. This requires `actions: write` for the temporary GitHub job token and does not create dummy commits.

## Scope

The lookup is used by product pages, grid/search/recommendation cards, campaign cards, homepage sliders, contact product references and theme-rendered cart items and stock errors. Stock-error item names retain their variant suffix. It affects title text and associated accessible labels/attributes. Other translated interface text and product descriptions retain their existing language handling.

Checkout belongs to the platform and is outside this theme rule. Existing order snapshots also retain their historical item names. Do not claim those native surfaces are synchronized by this implementation. A native catalog synchronization would require locale-only writes or working server-side concurrency protection; the tested classic PUT API requires resending Portuguese fields and ignores write preconditions, so it is unsuitable for unattended writes.

Tests also ruled out empty foreign names as a native fallback: the new catalog PATCH API can clear those fields, but the public storefront then renders a blank name. The probe product was restored and verified afterward.

## Verification and rollback

Run `node --test .github/tests/portuguese-product-titles.cjs .github/tests/portuguese-product-titles-theme.cjs` with Twig.js available. The local Twig.js emulator does not decode escaped backslashes like PHP Twig; literal source escaping is tested separately. Template delimiters are split into harmless string expressions, and displayed title text is escaped at the HTML sinks.

Verify the deployed product titles in Portuguese, English and Spanish, including the theme-rendered cart, and check URL/form preservation. Compare loading behavior before and after; no client resources are added by this change.

To roll back, revert the theme-consumer commit and disable the title-data workflow. The generated server file can remain unused. No catalog rollback is required because the production rule never writes catalog data.
