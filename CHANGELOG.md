# 📜 Changelog — OptiTool-Win10-11

All notable changes to the project will be documented in this file.

---

## [v2.0] - 2026

### English
**Fixed**
* Windows 7 launch crash — accessing `$Host.UI.RawUI` before the OS version check could throw Access Denied (0x80070005) on some Win7/PowerShell 2.0 configurations. The version check now runs first, and the WindowTitle assignment is wrapped safely so it can never stop the script.

**Improved**
* Full slash-free translation: the **Settings** section and the entire in-app **Changelog** are now translated separately for Russian and English, instead of showing both languages joined by a slash.
* All "Done." confirmation messages across the script are now translated the same way.

### Русский
**Исправлено**
* Сбой запуска на Windows 7 — обращение к `$Host.UI.RawUI` до проверки версии ОС могло вызывать ошибку доступа (0x80070005) на некоторых конфигурациях Win7/PowerShell 2.0. Проверка версии теперь выполняется первой, а установка заголовка окна безопасно обёрнута, чтобы никогда не останавливать скрипт.

**Улучшено**
* Полный перевод без слэшей: раздел **Настройки** и весь встроенный **Changelog** теперь переведены раздельно на русский и английский, вместо показа обоих языков через слэш.
* Все сообщения "Готово." по всему скрипту теперь переведены тем же способом.

---

## [v1.9.3] - 2026
### Added
* New **Version Info** screen in Settings — shows current version and a short changelog without digging through full history.
* Snake now lets you choose **WASD or Arrow keys** before starting.
* Two new games: **Clicker** (with upgrades, idle income, and a persistent save file) and **CPS Test** (measure your clicks per second).

### Improved
* Main menu simplified: all letter sections (Power, Advanced, Rest, Diagnostics, Software, System Tools, Edition Info) merged into a single **Other** menu, reducing clutter on the main screen.

---

## [v1.9.2] - 2026
### Fixed
* Hibernation status always showed green — was checking a hidden system file instead of the actual registry setting.
* MAS Activator confirmation changed from `1/0` to `Y/N`, fully bilingual now.

### Improved
* Added a file map / navigation comment at the top of the script for easier orientation.

---

## [v1.9.1] - 2026
### Added
* New **Edition Info** section: detects exact Windows edition, build number, and version.
* Organized into three clear submenus: **Detailed Info**, **Change Edition** (warning + guidance), and **Tweaks**.
* Fix for "managed by your organization" labels caused by LTSC-related Group Policy keys — safe to remove when the underlying feature actually exists but is blocked by policy.
* Home edition: `gpedit`, Hyper-V, and BitLocker now show clear alternatives instead of silent failures.
* Windows 11: restore classic right-click context menu, disable taskbar widgets, disable Copilot.

---

## [v1.9] - 2026
### Improved
* Self-update now lists **all** newer versions available, not just the latest one.
* Patch versions (e.g. `1.8.1`) are shown indented under their parent version (`1.8`) as recommended.
* When picking a version that isn't the latest, the script now shows a clear warning and still allows updating.
* Each version in the update menu shows its own changelog, pulled directly from its GitHub Release.

---

## [v1.8] - 2026
### Added
* New **Software** section: quick download of Chrome, Firefox, Telegram, Viber, VLC, 7-Zip.
* New **System Tools** section: quick access to `diskmgmt.msc`, `services.msc`, `devmgmt.msc`, `regedit`, `msinfo32`, `dxdiag`, and more.
* Safe Mode toggle for next boot (minimal / with networking / disable).
* Benchmark tools: CPU-Z, GPU-Z, FurMark, MSI Afterburner, AIDA64 (stress test / sensors, 30-day trial).

### Improved
* Main menu rebalanced into two even columns (no more right-side overhang).

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
