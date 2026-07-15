# Changelog

All notable changes to this project are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [0.1.0] - 2026-06-15

First tagged release. The plugin is installable as a Claude Code marketplace plugin:

```
/plugin marketplace add mcmespinaa/job-application-toolkit
/plugin install job-application@job-application-toolkit
```

### Added
- Claude Code plugin (`plugins/job-application`) distributed via a marketplace manifest
  (`.claude-plugin/marketplace.json` + `.claude-plugin/plugin.json`).
- Five skills: `job-application` (the tailoring pipeline), `job-setup` (workspace scaffolder),
  `job-export` (DOCX/HTML render), plus the `slop-proof` and `nordic-style` cleaning passes.
- ICM workspace templates with a blank `00_master/` factory (master CV, experience bank, voice)
  and CONTEXT.md contracts — no-fabrication design keeps all personal data local.
- ATS-styled `reference.docx` and a reproducible `build-reference-docx.sh` to regenerate it.
- Continuous integration: manifest validation, ShellCheck, script smoke tests, and a
  build-and-verify pass for the ATS reference template.
- Test suite (`tests/`): `validate_manifests.py`, `smoke-scripts.sh`, `test_reference_docx.py`.

[0.1.0]: https://github.com/mcmespinaa/job-application-toolkit/releases/tag/v0.1.0
