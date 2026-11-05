# Mobile menu implementation plan

> Implement in this session using executing-plans. The client screenshots and the user's request are the specification.

**Goal:** Place Best Sellers, Sobre and Personal Shopper beside Menu on mobile and reveal the menu smoothly from the upper left toward the right and bottom.

**Architecture:** Keep the native modal and its navigation/focus behavior. Share the validated mobile ordering between category buttons and header shortcuts. Use a scoped CSS reveal, approximately 350 ms on entry and 240 ms on exit, with reduced-motion support.

**Tech stack:** Nuvemshop Twig, CSS and existing JavaScript. No production dependencies.

**Constraints:** Preserve merchant labels, URLs, relative ordering, images and desktop navigation. Changes go to main through the existing Deploy Eora workflow, as previously authorized.

**Review focus:** Header links must not inherit the native close handler; 320 px screens must fit; reopening during the native hide timer must stay open; Escape/focus and reduced motion must remain usable; unconfigured/duplicate ordering entries must fall back safely.

### Task 1: Mobile header and motion

Files: `snipplets/navigation/eora-links.tpl`, `snipplets/navigation/eora-menu.tpl`, `snipplets/header/header-modals.tpl`, `snipplets/modal.tpl`, `static/css/eora-menu.css`, `layouts/layout.tpl`; native modal JavaScript only if reopening tests reproduce a stale timer.

- [x] Render the real hamburger embed and test shortcut destinations, independent click handling, mobile geometry, entry/exit motion, reduced motion, Escape and reopening.
- [x] Run the test against the unchanged implementation and confirm the missing header shortcuts fail.
- [x] Move only the three shortcuts to the header; preserve relative merchant ordering in each area. Make header click-to-close optional, with only the hamburger opting out.
- [x] Add the scoped reveal and update the stylesheet cache version.
- [x] Run menu rendering and browser regressions, inspect screenshots and review the diff before publication.

Baseline: `menu.cjs` passes. `menu-revision.cjs` already fails before changes: expects 26 preserved images but the current five-group template correctly renders 22 (4 default + 4 shop + 4 favorites + 2 warranty + 4 new + 4 community). Correct this stale expectation without changing photos.

Review: the independent reviewer found an interrupted entry snapping shut and an old timer truncating a subsequent exit. Both are treated as motion requirements. Added failing browser cases for each; replaced the entry keyframe with reversible CSS transitions, established the closed style once in the native hamburger opener, and cancel/replaced per-modal hide timers. No production dependencies or editor schema changes.

Validation: menu, menu-revision, menu-cleanup, menu-preorder, theme-editor-settings, menu-new-in, theme-preview-loading, menu-browser, menu-mobile-browser and diff whitespace checks pass. The two interrupted-motion cases failed first and now pass. Browser screenshots were inspected. PHP CLI is unavailable in this environment; the real platform's page responses are checked after deployment.
