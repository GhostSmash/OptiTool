# ⚡ OptiTool-Win10-11

---

## 🇬🇧 [EN] OptiTool - Script for Windows Optimization

OptiTool is a lightweight, modular PowerShell utility for optimizing, cleaning, and diagnosing Windows 10 and 11 — all through a simple console menu.

### 🖼️ Screenshots

<p align="center">
  <img src="assets/main-menu-en.png" alt="English Main Menu" width="700"/>
  <br/>
  <i>Main Interface (English)</i>
</p>

<p align="center">
  <img src="assets/features-en.png" alt="English Features Preview" width="700"/>
  <br/>
  <i>Diagnostics & Tools Preview</i>
</p>

### 💻 Requirements
* **OS:** Windows 10 or 11
* **Environment:** PowerShell 5.1+
* **Rights:** Run as Administrator

### 🚀 Quick Start
1. Download the archive from the **Releases** tab.
2. Right-click `start.bat` and choose **Run as administrator**.

### ⚡ Key Features
* **Performance:** Power plan management, disabling unnecessary services (SysMain, indexing) and visual effects.
* **Startup:** Manage startup items via registry, Task Scheduler, and background app control.
* **Disk & Cleanup:** Clean `TEMP`, `Windows.old`, update cache, and built-in multi-disk S.M.A.R.T. health check.
* **Privacy:** Disable Windows telemetry, advertising ID, and background trackers.
* **Network:** Resource monitoring, DNS/TCP-IP reset, ping test by country, and Speedtest.
* **Bloatware Removal:** Quickly remove built-in clutter (Xbox, Weather, News, etc.).
* **Advanced:** DISM cleanup (`/ResetBase`), paging file settings, hibernation toggle, and MAS launcher.
* **Diagnostics:** On-demand download of Fastfetch, Smartctl, and Sysinternals tools (Autorunsc, Handle, AccessChk).
* **Self-Update:** Checks GitHub Releases automatically, shows changelog, downloads and restarts on its own.
* **System Tools:** One-click access to `diskmgmt`, `services.msc`, `devmgmt`, `regedit`, `msinfo32`, `dxdiag`, and Safe Mode toggle.
* **Software:** Quick download links for essentials — Chrome, Firefox, Telegram, Viber, VLC, 7-Zip, and benchmarking tools (CPU-Z, GPU-Z, FurMark, MSI Afterburner, AIDA64).
* **Rest:** Snake and Guess the Number mini-games right in the console.

### ⚠️ Disclaimers
* **System Changes:** The script modifies registry and services. Use advanced features with care.
* **Third-Party Tools:** Tools like **Speedtest**, **Fastfetch**, **Smartctl**, **Sysinternals**, and software installers are **not stored** in this repository. The script downloads them directly from official sources on-demand.
* **Activation (MAS):** The script provides quick access to [Massgrave (MAS)](https://github.com/massgravel/Microsoft-Activation-Scripts) — an open-source third-party project. All activation code belongs to its original authors.
* **AIDA64:** Free 30-day trial. Mainly useful for initial stress-testing and sensor checks.

---

## 🇷🇺 [RU] OptiTool - Скрипт для оптимизации Windows

OptiTool — это небольшая и удобная утилита на PowerShell для настройки, очистки и диагностики Windows 10 и 11. Всё работает через понятное консольное меню.

### 🖼️ Скриншоты

<p align="center">
  <img src="assets/main-menu-ru.png" alt="Главное меню на русском" width="700"/>
  <br/>
  <i>Главный интерфейс (Русский язык)</i>
</p>

<p align="center">
  <img src="assets/features-ru.png" alt="Раздел утилит и очистки" width="700"/>
  <br/>
  <i>Раздел диагностики и утилит</i>
</p>

### 💻 Что нужно для запуска
* **ОС:** Windows 10 или 11
* **Среда:** PowerShell 5.1+
* **Права:** Запуск от имени администратора

### 🚀 Как запустить
1. Скачай архив из вкладки **Releases**.
2. Нажми правой кнопкой на `start.bat` и выбери **Запуск от имени администратора**.

### ⚡ Что умеет скрипт
* **Быстродействие:** Настройка схем питания, отключение лишних служб (SysMain, индексация) и визуальных эффектов.
* **Автозагрузка:** Управление автозапуском через реестр, планировщик и отключение фоновых приложений.
* **Очистка и диски:** Очистка `TEMP`, `Windows.old`, кэша обновлений и встроенная проверка S.M.A.R.T. на нескольких дисках.
* **Приватность:** Отключение телеметрии, рекламного ID и фоновых трекеров.
* **Сеть:** Мониторинг ресурсов, сброс DNS/TCP-IP, пинг-тест по странам и Speedtest.
* **Удаление блоатвера:** Быстрый снос встроенного мусора (Xbox, Погода, Новости и т.д.).
* **Продвинутое:** Очистка DISM (`/ResetBase`), файл подкачки, гибернация и запуск MAS.
* **Диагностика:** Скачивание Fastfetch, Smartctl и утилит Sysinternals по требованию.
* **Самообновление:** Проверяет GitHub Releases, показывает changelog, скачивает и перезапускается сам.
* **Системные утилиты:** Быстрый доступ к `diskmgmt`, `services.msc`, `devmgmt`, `regedit`, `msinfo32`, `dxdiag` и Безопасному режиму.
* **Софт:** Быстрое скачивание Chrome, Firefox, Telegram, Viber, VLC, 7-Zip и тестовых утилит (CPU-Z, GPU-Z, FurMark, MSI Afterburner, AIDA64).
* **Отдых:** Змейка и «Угадай число» прямо в консоли.

### ⚠️ Важное примечание
* **Изменения в системе:** Скрипт меняет реестр и службы. Используй продвинутые функции с умом.
* **Сторонние утилиты:** Инструменты вроде **Speedtest**, **Fastfetch**, **Smartctl**, **Sysinternals** и софт **не хранятся** в репозитории. Скрипт качает их с официальных сайтов только тогда, когда ты сам выбираешь их в меню.
* **Активация (MAS):** Скрипт лишь даёт быстрый доступ к [Massgrave (MAS)](https://github.com/massgravel/Microsoft-Activation-Scripts) — это сторонний проект, весь код активации принадлежит их авторам.
* **AIDA64:** Бесплатный 30-дневный триал. В основном полезна для первичного стресс-теста и проверки датчиков.

---

## 👨‍💻 Credits / Авторство

* **Developer / Разработчик:** [@ghostsmash](https://github.com/ghostsmash)
* **Code assistance / Помощь с кодом:** Claude & Gemini
