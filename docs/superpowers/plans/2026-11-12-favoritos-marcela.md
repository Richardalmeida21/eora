# Favoritos da Marcela Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Reproduce the supplied Marcela PDF on the existing /favoritosdamarcela/ page.

**Architecture:** Dedicated Twig page and editor section, reusing EORA product cards, filter engines and the Best Sellers catalog controller through optional configuration. Preserve campaign 4 media and curated products as initial content. New editor fields supply independent categories, catalog, looks and founder content.

**Tech Stack:** Nuvemshop Twig, scoped CSS, vanilla JavaScript, existing Twig/Playwright validation tools.

**Spec:** User supplied BRIEFING DE ESTRUTURA PARA PAGINA MARCELA DO SITE, October 2026, 13 pages. Visual references inspected on pages 2–12.

## Global Constraints

- Five sections, in order: photo/video hero, visual categories, catalog, shop the look, founder content.
- Up to 15 optional categories, tag matching, editable image/name/link/order/description. Only one description expanded.
- Desktop categories: 3 visible plus continuation when overflowing; mobile: 2.
- 10 optional curated catalog slots. First 12 products desktop / 6 mobile; Show More adds another 3 rows. Preserve selected order.
- Looks: 10 optional ordered slots, 2 visible desktop plus continuation / 1 mobile, modal with at most 2 selected products.
- Founder: 10 optional ordered image/GIF slots, title/description/button, 4 visible plus continuation desktop / 1 mobile.
- Reuse eyewear and bag filters. All links and dialogs keyboard accessible. Empty/disabled slots leave no gaps.
- Preserve user PDF changes and existing campaign configuration. No unrelated assets or routes changed.

## Review Focus

- Inactive or incomplete slots, duplicate selected products, no products for a chosen tag.
- Filter combinations, sorting, history navigation, mobile Show More and viewport resizing.
- Modal focus, Escape/backdrop close, no products in a look, no overflow on small screens.
- GIF animation, responsive video, reduced motion, external media URL validation.
- Legacy campaign content survives before new configuration is populated.

## Tasks

- [x] Add dedicated page route, Twig sections and schema with legacy fallbacks.
- [x] Extend shared catalog with opt-in curated products and responsive page sizes; keep Best Sellers defaults.
- [x] Implement scoped responsive composition, media, carousel and look-dialog behavior.
- [x] Render with real EORA assets in local harness; verify desktop/mobile against PDF side by side.
- [x] Test category switching, filter/sort, pagination, look dialog, media, empty states and existing Best Sellers.
- [x] Document editor setup and prepare completed branch and preview.

## Execution record

- User authorized the local automated browser because connected browser surfaces were unavailable.
- User chose to leave final looks and founder assets ready for later editor registration. Demonstration photos exist only in the local harness; empty production blocks stay hidden.
- Ruling: use square look photographs and 2:3 founder images to match PDF pages 8–11. The initial hero and product selection fall back to campaign 4.
- Ruling: exclude the dedicated route from legacy campaign CSS and slider initialization, following Best Sellers' existing integration.
- Verified: dedicated browser tests at 1440, 390 and 320 px; Best Sellers at 320, 390, 767, 768, 1440 and 1920 px; paginated category regression; complete editor schema (2194 fields); dependency-staging test.
- Visual artifacts remain outside the repository in `C:/Temp/eora-marcela-validation`. User-provided PDF changes are preserved separately.
