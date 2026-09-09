# AGENTS.md

Guidance for AI coding agents working in this repository. The full version is [CLAUDE.md](CLAUDE.md); this file is the short form.

- Read `doc/要件定義.md` and `doc/実装プラン.md` (section 4 has what each phase actually built) before changing behaviour.
- This repository is public: no Firebase, no pokePlus backend, no site-specific selectors or URLs. `npm run check:no-firebase` must pass.
- Generated files: `packages/wsi_sdk/dist/`, `apps/wsi_browser/assets/sdk/wsi-sdk-core.js`, `apps/wsi_browser/lib/db/database.g.dart`, `apps/wsi_browser/lib/l10n/generated/`, `apps/wsi_browser/integration_test/samples_data.g.dart`. Regenerate; do not hand-edit.
- Verify with `npm run test:sdk`, `npm run test:tools`, `npm test -w apps/api`, `flutter analyze && flutter test` in `apps/wsi_browser`, and the integration test on an Android emulator when the runtime changed.
- One commit per phase, no push unless asked.
