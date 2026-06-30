# lyt-fork — CLAUDE.md

Stan's (GitHub: `bibleman-stan`) personal maintained fork of the abandoned **LYT Mode** Obsidian theme (upstream `nickmilo/LYT-Mode`, last touched 2023-12-19 / v1.9.1). Goal: keep the theme working as Obsidian ships new releases, and make it **structurally resilient** so it stops breaking. Solo fork — not a public project. User-global defaults (execute-don't-ask, verify-don't-recall, lead-with-WHAT-changed) also apply.

## Identity & non-goals
- **Goal:** a self-owned, self-distributing theme that survives Obsidian updates. Fix what looks weird; harden against the next break.
- **NON-goals:** do NOT submit to the official Obsidian theme directory (rejects near-dupes; would make Stan a public maintainer — the opposite of "just for myself"). No BRAT. No build system, no JS, no plugin API. Snippets are a tuning instrument only — never the long-term delivery mechanism (Stan explicitly rejected the "pile of CSS snippets" path).

## Repo layout & source of truth
- **`theme.css` is the ONE file you maintain** and the single source of truth (~5,400 lines, has a table-of-contents — navigable). Everything else is trivial: `manifest.json` (version), `publish.css` (only Obsidian Publish), `snippets/`.
- `obsidian.css` was deleted — pre-2022 loading mechanism no current Obsidian reads. Do not resurrect it.
- **Canonical repo:** `C:\Users\bibleman\repos\lyt-fork`. A throwaway clone at `C:\Users\bibleman\work\lyt-fork` exists — ignore/delete it; never commit there.
- **Remotes:** `origin` = `bibleman-stan/lyt-fork` (push/pull here). `upstream` = `nickmilo/LYT-Mode` with **push disabled** (`git pull upstream main` only if it ever revives). SSH auth, no `gh` CLI.

## WHY LYT breaks (the core principle)
LYT **hardcodes structural CSS** — fixed font-sizes, paddings, type-based selectors (`input[type='text']`) — instead of riding Obsidian's CSS-variable system. Obsidian's philosophy since 1.0: "themes set *variables* (`--background-primary`, `--font-ui-medium`…), Obsidian's own CSS handles structure." Variable-driven themes barely break; hardcoded ones break whenever Obsidian restructures a component or adds a surface the 2023 theme never styled (settings search, Properties view 1.4, Bases 1.9, tab/sidebar redesigns).

## Hard-won rules
- **Theme-side diagnosis first.** Switch to another theme: if the symptom vanishes, it's LYT's CSS (or a *missing* rule for a new Obsidian surface) — not Obsidian core. Then grep/Read `theme.css` for the selector. Right-click → Inspect to get the real element classes; don't guess.
- **Root-cause over fly-swatting.** Fix the whole CLASS, not one instance. The settings-search fix was first scoped too narrowly (`.vertical-tab-header` only) so plugin-pane searches stayed broken; the right fix sized *every* input inside `.modal.mod-settings`. When a symptom recurs in a sibling surface, broaden the selector — don't add a second one-off.
- **CSS specificity gotcha.** LYT sets variables inside **`body.theme-dark { }`** (note `body.` — more specific than `.theme-dark`). A lower-specificity override silently does nothing. Match it or waste a round wondering why toggling changed nothing.
- **Prefer the targeted variable over the shared palette token.** To darken the editor, set `--background-primary` directly, NOT shared `--color-gray-90` (which shifts the whole palette). Change the narrowest variable that achieves the look.
- **Snippet-as-tuning-instrument.** For look-at-it changes (colors) or to confirm a fix before the fork is installed, write a temp snippet into a vault's `.obsidian/snippets/` (use `C:\vaults-nano\my_brain` — the live test vault), dial it in while Stan eyeballs ("darker / less blue / …"), then **bake the final rule into `theme.css` and delete the snippet.**

## Resilience strategy (the ongoing work)
1. **Cover new components** Obsidian added since 2023 (settings search ✅ done, Properties, Bases, tab/sidebar redesigns, callouts) — each gets proper LYT styling.
2. **Migrate hardcoded → variables** where the theme fights Obsidian defaults — shrinks the surface that can break next time (the real durability win).
3. **Drop dead/deprecated selectors** Obsidian renamed or removed since 1.0.

## Test → bake → deploy loop
1. Reproduce; confirm theme-side (see Hard-won rules); Inspect for real classes.
2. Confirm the fix live (snippet or direct theme edit + reload — Obsidian hot-reloads the active theme's CSS *and* snippet edits on disk).
3. Bake into `theme.css`. Set the narrowest variable. Prefer `!important` only when overriding Obsidian's own rules for durability.
4. **Version:** bump `manifest.json` `version` (patch bump per shipped change — 1.9.2, 1.9.3, 1.9.4…) and update the `MODIFIED:` date at the top of `theme.css`.
5. Commit + push to `origin main` (autonomous on `main` after a clean local commit). Use HEREDOC for multi-line commit messages on Windows — a mangled heredoc once ate a commit subject, so verify the subject landed.
6. **Deploy:** `.\deploy.ps1` from the repo — auto-discovers every local vault with a `LYT Mode` theme folder (anchors on `.obsidian`, dedupes nested vaults), copies `theme.css` + `manifest.json` in. Obsidian Sync carries it to Stan's phone. **Batch changes, deploy once.** Confirm before any action touching all vaults/mobile.
7. **Verify on disk** after deploy — read the new value + version back from a couple vaults; don't trust the script's stdout. Retire test snippets once live.

## Constraints about Stan
- **~12 vaults across desktop + phone**; phone use rules out symlinks/copy-scripts — distribution is `push` → `deploy.ps1` → Obsidian Sync.
- `deploy.ps1` scans `C:\vaults-nano` and `C:\Users\bibleman\Documents`, NOT `C:\Users\bibleman\work\` (Stan declined adding it) — vaults there (e.g. `rs6310`) need a manual copy and won't auto-update.
- Stan does NOT code in Obsidian — code-block styling is low priority (left flush with the background on purpose).
- `hotkeys.json` is NOT hot-reloaded (read at startup); editing a hotkey in-session rewrites in-memory defaults to disk and clobbers a file you just copied — reload (Ctrl+R) before tweaking.
