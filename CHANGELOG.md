# 📜 Changelog — OptiTool-Win10-11

All notable changes to the project will be documented in this file.

---

## [v1.7] - 2026
### Fixed
* Windows 7 launch crash caused by `[ordered]` hashtable (unsupported on PowerShell 2.0).
* Broken Smartctl installer — SourceForge `latest/download` link served an HTML page instead of the actual exe.
* DISM cleanup progress bar not visually reaching 100% after completion.

### Added
* Self-update system: checks GitHub Releases, shows changelog, downloads and restarts automatically.
* First-run prompt to enable/disable automatic update checks.
* Settings: manual "check for updates now" option and auto-update toggle.

---

## [v1.6] - 2026
### Added
* New **Tests & Diagnostics** section (Fastfetch, Smartctl).
* Built-in Changelog viewer directly in the script menu.

---

## [v1.5] - 2026
### Added
* Detailed CPU/GPU hardware specifications display.
* Safety Confirmation prompts (Y/N) for critical actions.
* Interactive Rest section with console mini-games.
* Refined disclaimers and tool usage notices.

---

## [v1.4] - 2026
### Added
* Advanced DISM component cleanup (`/ResetBase`).
* Paging file (virtual memory) and Hibernation settings.
* Optional **MAS Activator** integration link.

---

## [v1.3] - 2026
### Added
* Visual toggle indicators (`[v]` / `[x]`).
* Multi-disk S.M.A.R.T. status display.
* Integrated Ookla Speedtest CLI downloader and runner.

---

## [v1.2] - 2026
### Added
* Network diagnostics (DNS flush, TCP/IP reset).
* Power scheme management.
* Hardware info & Bloatware removal tool.

---

## [v1.1] - 2026
### Improved
* UTF-8 / Console encoding fixes.
* Startup manager registry checks.
* OS compatibility checks for Windows 10 & 11.

---

## [v1.0] - 2026
### Initial Release
* Basic terminal menu structure and core optimization script.
