# =====================================================
#  OPTIMIZATION TOOL
#  Developer / Разработчик: github.com/ghostsmash
# =====================================================

$Host.UI.RawUI.WindowTitle = "Optimization Tool"
$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"

# --- Глобальные настройки (сохраняются в config.json рядом со скриптом) ---
$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigPath = Join-Path $ScriptDir "config.json"
$LogPath    = Join-Path $ScriptDir "debug_log.txt"

$Global:Config = [ordered]@{
    Language     = "EN"      # EN / RU
    Architecture = "AUTO"    # 32 / 64 / AUTO
    Color        = "Green"   # Green / Cyan / Yellow / Orange / White
    DebugLogs    = $false
    FirstRun     = $true
    AdvancedAccepted = $false
}

# --- Проверка версии Windows (работает даже на PowerShell 2.0) ---
function Test-WindowsVersion {
    $osVersion = [System.Environment]::OSVersion.Version
    # Windows 10 = 10.0, Windows 11 тоже определяется как 10.0 (build 22000+)
    $isSupported = ($osVersion.Major -eq 10)

    if (-not $isSupported) {
        Clear-Host
        Write-Host ""
        Write-Host "  █████████████████████████████████████████████" -ForegroundColor Red
        Write-Host "  █                                             █" -ForegroundColor Red
        Write-Host "  █             ! WARNING / ВНИМАНИЕ !          █" -ForegroundColor Red
        Write-Host "  █                                             █" -ForegroundColor Red
        Write-Host "  █████████████████████████████████████████████" -ForegroundColor Red
        Write-Host ""
        Write-Host "  This tool is designed for Windows 10 / 11 only." -ForegroundColor Red
        Write-Host "  Этот инструмент предназначен только для Windows 10 / 11." -ForegroundColor Red
        Write-Host ""
        Write-Host "  Detected OS version: $osVersion" -ForegroundColor DarkGray
        Write-Host "  Some or all functions may not work correctly." -ForegroundColor Yellow
        Write-Host "  Некоторые функции могут работать некорректно." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Press Enter to continue anyway, or close this window to exit."
        Write-Host "  Нажмите Enter, чтобы продолжить, или закройте окно для выхода."
        Write-Host ""
        Read-Host "  >" | Out-Null
    }
}

function Show-ResponsibilityDisclaimer {
    Clear-Host
    Write-Host ""
    Write-Host "  █████████████████████████████████████████████" -ForegroundColor Yellow
    Write-Host "  █                                             █" -ForegroundColor Yellow
    Write-Host "  █           DISCLAIMER / ОТКАЗ ОТ ОТВЕТСТВЕННОСТИ     " -ForegroundColor Yellow
    Write-Host "  █                                             █" -ForegroundColor Yellow
    Write-Host "  █████████████████████████████████████████████" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  This tool modifies system settings, registry, and services."
    Write-Host "  Этот инструмент изменяет системные настройки, реестр и службы."
    Write-Host ""
    Write-Host "  Something may break as a result of using it."
    Write-Host "  Что-то может сломаться в результате использования."
    Write-Host ""
    Write-Host "  By continuing, you accept full responsibility for any changes"
    Write-Host "  or issues that may occur on your system."
    Write-Host "  Продолжая, вы берете на себя полную ответственность за любые"
    Write-Host "  изменения или проблемы, которые могут возникнуть."
    Write-Host ""
    Write-Host "  Press Enter to accept and continue."
    Write-Host "  Нажмите Enter чтобы принять и продолжить."
    Write-Host ""
    Read-Host "  >" | Out-Null
}

function Load-Config {
    if (Test-Path $ConfigPath) {
        try {
            $loaded = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            foreach ($key in $loaded.PSObject.Properties.Name) {
                $Global:Config[$key] = $loaded.$key
            }
        } catch { }
    }
}

function Save-Config {
    $Global:Config | ConvertTo-Json | Set-Content -Path $ConfigPath -Encoding UTF8
}

function Write-Log {
    param([string]$Message)
    if ($Global:Config.DebugLogs) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content -Path $LogPath -Value "[$timestamp] $Message" -Encoding UTF8
    }
}

# --- Цветовая палитра ---
function Get-ThemeColor {
    switch ($Global:Config.Color) {
        "Green"  { return "Green" }
        "Cyan"   { return "Cyan" }
        "Yellow" { return "Yellow" }
        "Orange" { return "DarkYellow" }
        "White"  { return "White" }
        default  { return "Green" }
    }
}

# --- Словарь текстов (EN / RU) ---
$T = @{
    EN = @{
        Welcome       = "Welcome to Optimization Tool"
        ChooseLang    = "Choose your language:"
        LangRu        = "Russian"
        LangEn        = "English (recommended)"
        ChooseArch    = "Select system architecture:"
        Arch32        = "32-bit"
        Arch64        = "64-bit"
        ArchAuto      = "Auto-detect (recommended)"
        Detected      = "Detected architecture:"
        MainMenuTitle = "OPTIMIZATION"
        M1            = "Performance and Power"
        M2            = "Startup and Background"
        M3            = "Disk Space"
        M4            = "Privacy"
        M5            = "System Info"
        M6            = "Export Report"
        M7            = "Network"
        M8            = "Remove bloatware"
        MP            = "Power (Shutdown/Restart)"
        M9            = "Settings"
        M0            = "Exit"
        PressEnter    = "Press Enter to continue..."
        InvalidChoice = "Invalid choice, try again."
        SettingsTitle = "SETTINGS"
        S1            = "Language"
        S2            = "Debug logs"
        S3            = "Menu color"
        S4            = "Contributors"
        S0            = "Back"
        ColorTitle    = "Choose menu color:"
        Contributors  = "Developer:"
        Back          = "Back"
        On            = "ON"
        Off           = "OFF"
    }
    RU = @{
        Welcome       = "Добро пожаловать в Optimization Tool"
        ChooseLang    = "Выберите язык:"
        LangRu        = "Русский"
        LangEn        = "Английский (рекомендуется)"
        ChooseArch    = "Выберите разрядность системы:"
        Arch32        = "32-бит"
        Arch64        = "64-бит"
        ArchAuto      = "Автоопределение (рекомендуется)"
        Detected      = "Определена разрядность:"
        MainMenuTitle = "ОПТИМИЗАЦИЯ"
        M1            = "Быстродействие и питание"
        M2            = "Автозагрузка и фон"
        M3            = "Место на диске"
        M4            = "Приватность"
        M5            = "Инфо о системе"
        M6            = "Экспорт отчёта"
        M7            = "Сеть"
        M8            = "Удаление bloatware"
        MP            = "Питание (Выкл/Перезагрузка)"
        M9            = "Настройки"
        M0            = "Выход"
        PressEnter    = "Нажмите Enter для продолжения..."
        InvalidChoice = "Неверный выбор, попробуйте снова."
        SettingsTitle = "НАСТРОЙКИ"
        S1            = "Язык"
        S2            = "Debug логи"
        S3            = "Цвет меню"
        S4            = "Разработчики"
        S0            = "Назад"
        ColorTitle    = "Выберите цвет меню:"
        Contributors  = "Разработчик:"
        Back          = "Назад"
        On            = "ВКЛ"
        Off           = "ВЫКЛ"
    }
}

function L {
    param([string]$Key)
    return $T[$Global:Config.Language][$Key]
}

# --- ASCII Art заголовок ---
function Show-Header {
    param([string]$Title)
    $color = Get-ThemeColor
    Clear-Host
    Write-Host ""
    Write-Host "  █████████████████████████████████████" -ForegroundColor $color
    $padded = $Title.ToUpper().PadLeft(([math]::Floor((37 + $Title.Length) / 2))).PadRight(37)
    Write-Host "  █$padded█" -ForegroundColor $color
    Write-Host "  █████████████████████████████████████" -ForegroundColor $color
    Write-Host ""
}

function Show-Welcome {
    $color = Get-ThemeColor
    Clear-Host
    Write-Host ""
    Write-Host "  █████████████████████████████████████" -ForegroundColor $color
    Write-Host "  █          OPTIMIZATION TOOL         █" -ForegroundColor $color
    Write-Host "  █████████████████████████████████████" -ForegroundColor $color
    Write-Host ""
    Write-Host "  Welcome / Добро пожаловать" -ForegroundColor $color
    Write-Host ""
    Write-Host "  1. Русский"
    Write-Host "  2. English (recommended)"
    Write-Host ""
    $choice = Read-Host "  >"
    switch ($choice) {
        "1" { $Global:Config.Language = "RU" }
        default { $Global:Config.Language = "EN" }
    }
    Write-Log "Language selected: $($Global:Config.Language)"
}

function Show-ArchSelect {
    Show-Header (L "ChooseArch")
    $detected = if ([Environment]::Is64BitOperatingSystem) { "64" } else { "32" }
    Write-Host "  1. $(L 'Arch32')"
    Write-Host "  2. $(L 'Arch64')"
    Write-Host "  3. $(L 'ArchAuto')"
    Write-Host ""
    Write-Host "  $(L 'Detected') $detected-bit" -ForegroundColor DarkGray
    Write-Host ""
    $choice = Read-Host "  >"
    switch ($choice) {
        "1" { $Global:Config.Architecture = "32" }
        "2" { $Global:Config.Architecture = "64" }
        default { $Global:Config.Architecture = $detected }
    }
    Write-Log "Architecture selected: $($Global:Config.Architecture)"
}

# --- Главное меню ---
function Show-MainMenu {
    while ($true) {
        Show-Header (L "MainMenuTitle")
        Write-Host ("  1. {0,-27} 5. {1}" -f (L "M1"), (L "M5"))
        Write-Host ("  2. {0,-27} 6. {1}" -f (L "M2"), (L "M6"))
        Write-Host ("  3. {0,-27} 7. {1}" -f (L "M3"), (L "M7"))
        Write-Host ("  4. {0,-27} 8. {1}" -f (L "M4"), (L "M8"))
        Write-Host ""
        Write-Host ("  9. {0,-27} P. {1}" -f (L 'M9'), (L 'MP'))
        Write-Host ("  0. {0,-27} D. {1}" -f (L 'M0'), "Advanced / Для разработчиков")
        Write-Host ("     {0,-27} R. {1}" -f "", "Rest / Отдых")
        Write-Host ("     {0,-27} T. {1}" -f "", "Tests & Diagnostics / Тесты и диагностика")
        Write-Host ""
        $choice = Read-Host "  >"
        Write-Log "Main menu choice: $choice"
        switch ($choice.ToUpper()) {
            "1" { Show-PerformanceMenu }
            "2" { Show-StartupMenu }
            "3" { Show-DiskMenu }
            "4" { Show-PrivacyMenu }
            "5" { Show-SystemInfo }
            "6" { Show-ExportReport }
            "7" { Show-NetworkMenu }
            "8" { Show-BloatwareMenu }
            "9" { Show-SettingsMenu }
            "P" { Show-PowerMenu }
            "D" { Show-AdvancedMenu }
            "R" { Show-RestMenu }
            "T" { Show-DiagnosticsMenu }
            "0" { Save-Config; exit }
            default {
                Write-Host ""
                Write-Host "  $(L 'InvalidChoice')" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}

# --- Меню настроек ---
function Show-SettingsMenu {
    while ($true) {
        Show-Header (L "SettingsTitle")
        $dbg = if ($Global:Config.DebugLogs) { "[v]" } else { "[x]" }
        $langName = if ($Global:Config.Language -eq "RU") { L "LangRu" } else { L "LangEn" }
        Write-Host "  1. $(L 'S1'): $langName"
        Write-Host "  2. $(L 'S2'): $dbg"
        Write-Host "  3. $(L 'S3'): $($Global:Config.Color)"
        Write-Host "  4. $(L 'S4')"
        Write-Host "  5. Architecture: $($Global:Config.Architecture)-bit"
        Write-Host "  6. Reset Advanced disclaimer / Сбросить подтверждение Advanced"
        Write-Host "  7. Version history / История версий"
        Write-Host ""
        Write-Host "  0. $(L 'S0')"
        Write-Host ""
        $choice = Read-Host "  >"
        switch ($choice) {
            "1" {
                $Global:Config.Language = if ($Global:Config.Language -eq "EN") { "RU" } else { "EN" }
                Save-Config
            }
            "2" {
                $Global:Config.DebugLogs = -not $Global:Config.DebugLogs
                Save-Config
                Write-Log "Debug logs toggled: $($Global:Config.DebugLogs)"
            }
            "3" { Show-ColorMenu }
            "4" { Show-Contributors }
            "5" { Show-ArchSelect; Save-Config }
            "6" {
                $Global:Config.AdvancedAccepted = $false
                Save-Config
                Write-Host "  Done. / Готово." -ForegroundColor Green
                Start-Sleep -Seconds 1
            }
            "7" { Show-Changelog }
            "0" { Save-Config; return }
            default {
                Write-Host "  $(L 'InvalidChoice')" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}

function Show-ColorMenu {
    Show-Header (L "ColorTitle")
    Write-Host "  1. Green"   -ForegroundColor Green
    Write-Host "  2. Cyan"    -ForegroundColor Cyan
    Write-Host "  3. Yellow"  -ForegroundColor Yellow
    Write-Host "  4. Orange"  -ForegroundColor DarkYellow
    Write-Host "  5. White"   -ForegroundColor White
    Write-Host ""
    Write-Host "  0. $(L 'Back')"
    Write-Host ""
    $choice = Read-Host "  >"
    switch ($choice) {
        "1" { $Global:Config.Color = "Green" }
        "2" { $Global:Config.Color = "Cyan" }
        "3" { $Global:Config.Color = "Yellow" }
        "4" { $Global:Config.Color = "Orange" }
        "5" { $Global:Config.Color = "White" }
    }
    Save-Config
}

function Show-Contributors {
    Show-Header (L "S4")
    Write-Host "  $(L 'Contributors') github.com/ghostsmash" -ForegroundColor (Get-ThemeColor)
    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

function Show-Changelog {
    Show-Header "Version History / История версий"

    Write-Host "  v1.0" -ForegroundColor (Get-ThemeColor)
    Write-Host "  ------------------------------------------------"
    Write-Host "  1. Initial menu structure: language, architecture select"
    Write-Host "  2. Performance, Startup, Disk, Privacy sections"
    Write-Host "  3. Basic Settings (language, debug logs, color)"
    Write-Host ""

    Write-Host "  v1.1" -ForegroundColor (Get-ThemeColor)
    Write-Host "  ------------------------------------------------"
    Write-Host "  1. Fixed encoding/BOM and launcher path issues"
    Write-Host "  2. Startup manager: toggle RUN / STARTUP folder / Task Scheduler"
    Write-Host "  3. Windows version check warning (10/11 only)"
    Write-Host ""

    Write-Host "  v1.2" -ForegroundColor (Get-ThemeColor)
    Write-Host "  ------------------------------------------------"
    Write-Host "  1. Network section: adapters, ping by country, speedtest (Ookla CLI)"
    Write-Host "  2. Power menu: shutdown/restart with timer and message templates"
    Write-Host "  3. System Info: summary, drivers, live CPU/RAM snapshot"
    Write-Host "  4. Bloatware removal list"
    Write-Host ""

    Write-Host "  v1.3" -ForegroundColor (Get-ThemeColor)
    Write-Host "  ------------------------------------------------"
    Write-Host "  1. Real toggle system [v]/[x] with color and 'not recommended' hints"
    Write-Host "  2. Power plan submenu, background UWP apps manager (enable/disable all)"
    Write-Host "  3. Disk health / S.M.A.R.T. with multi-disk selection"
    Write-Host "  4. Expanded export report and live snapshot (top processes, page file)"
    Write-Host "  5. Speedtest simplified to direct native output (no flicker)"
    Write-Host ""

    Write-Host "  v1.4" -ForegroundColor (Get-ThemeColor)
    Write-Host "  ------------------------------------------------"
    Write-Host "  1. Advanced section: DISM cleanup, paging file, hibernation, WinSxS size"
    Write-Host "  2. Responsibility disclaimer on first run"
    Write-Host "  3. MAS Activator integration (Advanced section)" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "  v1.5" -ForegroundColor (Get-ThemeColor)
    Write-Host "  ------------------------------------------------"
    Write-Host "  1. Y/N confirmation style across all prompts"
    Write-Host "  2. Fixed bloatware 'already removed' false success message"
    Write-Host "  3. Advanced disclaimer: one-time, red color, resettable in Settings"
    Write-Host "  4. Fixed hibernation toggle logic and live status refresh"
    Write-Host "  5. CPU / GPU detailed info sections"
    Write-Host "  6. Rest section: Guess the Number and Snake games"
    Write-Host ""

    Write-Host "  v1.6" -ForegroundColor (Get-ThemeColor)
    Write-Host "  ------------------------------------------------"
    Write-Host "  1. Tests & Diagnostics section (Fastfetch, Smartctl, Autorunsc, Handle, AccessChk)"
    Write-Host "  2. Version history / changelog viewer in Settings"
    Write-Host ""

    Write-Host "  ------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Built by / Собрано: Claude (Anthropic)" -ForegroundColor (Get-ThemeColor)
    Write-Host "  MAS Activator addition / Добавление MAS: Gemini (Google)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

# =====================================================
#  РАЗДЕЛ 1: PERFORMANCE & POWER
# =====================================================
function Get-ToggleMark {
    param([bool]$IsOn, [bool]$OnIsBad = $true)
    if ($IsOn) {
        $color = if ($OnIsBad) { "Red" } else { "Green" }
        $note = if ($OnIsBad) { "(not recommended)" } else { "" }
        return @{ Text = "[v]"; Color = $color; Note = $note }
    } else {
        $color = if ($OnIsBad) { "Green" } else { "Red" }
        $note = if (-not $OnIsBad) { "(not recommended)" } else { "" }
        return @{ Text = "[x]"; Color = $color; Note = $note }
    }
}

function Show-PowerPlanMenu {
    while ($true) {
        Show-Header "Power Plan"
        $active = powercfg /getactivescheme
        $activeGuid = if ($active -match "([0-9a-f-]{36})") { $matches[1] } else { "" }

        $high = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
        $balanced = "381b4222-f694-41f0-9685-ff5bb260df2e"
        $saver = "a1841308-3541-4fab-bc81-f71556f20b4a"

        $m1 = if ($activeGuid -eq $high) { "[v]" } else { "[x]" }
        $m2 = if ($activeGuid -eq $balanced) { "[v]" } else { "[x]" }
        $m3 = if ($activeGuid -eq $saver) { "[v]" } else { "[x]" }

        Write-Host "  1. High Performance / Высокая производительность (recommended) $m1"
        Write-Host "  2. Balanced / Баланс $m2"
        Write-Host "  3. Power saver / Энергосбережение $m3"
        Write-Host ""
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        switch ($choice) {
            "1" { powercfg /setactive $high; Write-Log "Power plan: High Performance" }
            "2" { powercfg /setactive $balanced; Write-Log "Power plan: Balanced" }
            "3" { powercfg /setactive $saver; Write-Log "Power plan: Power saver" }
            "0" { return }
        }
    }
}

function Show-PerformanceMenu {
    while ($true) {
        Show-Header (L "M1")

        $activeScheme = powercfg /getactivescheme
        $activePlanName = if ($activeScheme -match "\((.+)\)") { $matches[1] } else { "Unknown" }

        $sysmainStartType = (Get-Service -Name "SysMain" -ErrorAction SilentlyContinue).StartType
        $sysmainOn = ($sysmainStartType -ne "Disabled")
        $sysmainMark = Get-ToggleMark -IsOn $sysmainOn -OnIsBad $true

        $wsearchStartType = (Get-Service -Name "WSearch" -ErrorAction SilentlyContinue).StartType
        $wsearchOn = ($wsearchStartType -ne "Disabled")
        $wsearchMark = Get-ToggleMark -IsOn $wsearchOn -OnIsBad $true

        $defragTask = Get-ScheduledTask -TaskName "ScheduledDefrag" -TaskPath "\Microsoft\Windows\Defrag\" -ErrorAction SilentlyContinue
        $defragOn = ($defragTask -and $defragTask.State -ne "Disabled")
        $defragMark = Get-ToggleMark -IsOn $defragOn -OnIsBad $true

        Write-Host "  1. Power plan (current: $activePlanName)"
        Write-Host "  2. Disable visual effects (animations)"
        Write-Host ("  3. SysMain/Superfetch (recommended OFF for SSD) {0} {1}" -f $sysmainMark.Text, $sysmainMark.Note) -ForegroundColor $sysmainMark.Color
        Write-Host ("  4. Scheduled SSD defrag task {0} {1}" -f $defragMark.Text, $defragMark.Note) -ForegroundColor $defragMark.Color
        Write-Host ("  5. Windows Search indexing {0} {1}" -f $wsearchMark.Text, $wsearchMark.Note) -ForegroundColor $wsearchMark.Color
        Write-Host ""
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        switch ($choice) {
            "1" { Show-PowerPlanMenu }
            "2" {
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -ErrorAction SilentlyContinue
                Write-Log "Visual effects reduced"
                Write-Host "  Done. Re-login may be required." -ForegroundColor Green
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "3" {
                if ($sysmainOn) {
                    Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
                    Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
                    Write-Log "SysMain disabled"
                } else {
                    Set-Service -Name "SysMain" -StartupType Automatic -ErrorAction SilentlyContinue
                    Start-Service -Name "SysMain" -ErrorAction SilentlyContinue
                    Write-Log "SysMain enabled"
                }
                Write-Host "  Done." -ForegroundColor Green
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "4" {
                if ($defragOn) {
                    Disable-ScheduledTask -TaskName "ScheduledDefrag" -TaskPath "\Microsoft\Windows\Defrag\" -ErrorAction SilentlyContinue | Out-Null
                    Write-Log "SSD defrag task disabled"
                } else {
                    Enable-ScheduledTask -TaskName "ScheduledDefrag" -TaskPath "\Microsoft\Windows\Defrag\" -ErrorAction SilentlyContinue | Out-Null
                    Write-Log "SSD defrag task enabled"
                }
                Write-Host "  Done." -ForegroundColor Green
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "5" {
                if ($wsearchOn) {
                    Stop-Service -Name "WSearch" -Force -ErrorAction SilentlyContinue
                    Set-Service -Name "WSearch" -StartupType Disabled -ErrorAction SilentlyContinue
                    Write-Log "Windows Search indexing disabled"
                } else {
                    Set-Service -Name "WSearch" -StartupType Automatic -ErrorAction SilentlyContinue
                    Start-Service -Name "WSearch" -ErrorAction SilentlyContinue
                    Write-Log "Windows Search indexing enabled"
                }
                Write-Host "  Done." -ForegroundColor Green
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "0" { return }
        }
    }
}

# =====================================================
#  РАЗДЕЛ 2: STARTUP & BACKGROUND
# =====================================================

# --- Источник 1: RUN (реестр) ---
$Global:RunPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
)
$Global:RunDisabledPath = "HKCU:\Software\OptiToolDisabledStartup"

function Get-RunItems {
    $items = @()
    foreach ($path in $Global:RunPaths) {
        if (Test-Path $path) {
            $props = Get-ItemProperty -Path $path
            $props.PSObject.Properties |
                Where-Object { $_.Name -notmatch "^PS(Path|ParentPath|ChildName|Provider)$" } |
                ForEach-Object {
                    $items += [PSCustomObject]@{
                        Source  = "RUN"
                        Name    = $_.Name
                        Value   = $_.Value
                        Path    = $path
                        Enabled = $true
                    }
                }
        }
    }
    if (Test-Path $Global:RunDisabledPath) {
        $props = Get-ItemProperty -Path $Global:RunDisabledPath
        $props.PSObject.Properties |
            Where-Object { $_.Name -notmatch "^PS(Path|ParentPath|ChildName|Provider)$" } |
            ForEach-Object {
                $items += [PSCustomObject]@{
                    Source  = "RUN"
                    Name    = $_.Name
                    Value   = $_.Value
                    Path    = $Global:RunDisabledPath
                    Enabled = $false
                }
            }
    }
    return $items
}

function Toggle-RunItem {
    param($item)
    if ($item.Enabled) {
        if (-not (Test-Path $Global:RunDisabledPath)) {
            New-Item -Path $Global:RunDisabledPath -Force | Out-Null
        }
        New-ItemProperty -Path $Global:RunDisabledPath -Name $item.Name -Value $item.Value -PropertyType String -Force | Out-Null
        Remove-ItemProperty -Path $item.Path -Name $item.Name -ErrorAction SilentlyContinue
        Write-Log "RUN item disabled: $($item.Name)"
    } else {
        New-ItemProperty -Path $Global:RunPaths[0] -Name $item.Name -Value $item.Value -PropertyType String -Force | Out-Null
        Remove-ItemProperty -Path $Global:RunDisabledPath -Name $item.Name -ErrorAction SilentlyContinue
        Write-Log "RUN item enabled: $($item.Name)"
    }
}

# --- Источник 2: STARTUP FOLDER (папка автозагрузки) ---
function Get-StartupFolderItems {
    $items = @()
    $folders = @(
        [Environment]::GetFolderPath("Startup"),
        [Environment]::GetFolderPath("CommonStartup")
    )
    foreach ($folder in $folders) {
        if (Test-Path $folder) {
            Get-ChildItem -Path $folder -File | ForEach-Object {
                $enabled = -not $_.Name.EndsWith(".disabled")
                $displayName = $_.Name -replace "\.disabled$", ""
                $items += [PSCustomObject]@{
                    Source   = "STARTUP"
                    Name     = $displayName
                    FullPath = $_.FullName
                    Enabled  = $enabled
                }
            }
        }
    }
    return $items
}

function Toggle-StartupFolderItem {
    param($item)
    if ($item.Enabled) {
        Rename-Item -Path $item.FullPath -NewName "$($item.FullPath | Split-Path -Leaf).disabled" -ErrorAction SilentlyContinue
        Write-Log "Startup folder item disabled: $($item.Name)"
    } else {
        $newName = $item.FullPath -replace "\.disabled$", "" | Split-Path -Leaf
        Rename-Item -Path $item.FullPath -NewName $newName -ErrorAction SilentlyContinue
        Write-Log "Startup folder item enabled: $($item.Name)"
    }
}

# --- Источник 3: TASK SCHEDULER (планировщик задач) ---
function Get-TaskSchedulerItems {
    $items = @()
    Get-ScheduledTask | Where-Object {
        ($_.Triggers.TriggerType -contains "LogonTrigger" -or $_.Triggers.TriggerType -contains "BootTrigger") -and
        $_.TaskPath -notlike "\Microsoft\*"
    } | ForEach-Object {
        $items += [PSCustomObject]@{
            Source   = "TASK"
            Name     = $_.TaskName
            TaskPath = $_.TaskPath
            Enabled  = ($_.State -ne "Disabled")
        }
    }
    return $items
}

function Toggle-TaskSchedulerItem {
    param($item)
    if ($item.Enabled) {
        Disable-ScheduledTask -TaskName $item.Name -TaskPath $item.TaskPath -ErrorAction SilentlyContinue | Out-Null
        Write-Log "Task disabled: $($item.Name)"
    } else {
        Enable-ScheduledTask -TaskName $item.Name -TaskPath $item.TaskPath -ErrorAction SilentlyContinue | Out-Null
        Write-Log "Task enabled: $($item.Name)"
    }
}

# --- Универсальная функция переключения по источнику ---
function Toggle-StartupItemBySource {
    param($item)
    switch ($item.Source) {
        "RUN"     { Toggle-RunItem $item }
        "STARTUP" { Toggle-StartupFolderItem $item }
        "TASK"    { Toggle-TaskSchedulerItem $item }
    }
}

# --- Отображение списка с возможностью переключения ---
function Show-StartupItemsList {
    param(
        [string]$Title,
        [scriptblock]$GetItems
    )
    while ($true) {
        Show-Header $Title
        $items = @(& $GetItems)
        if ($items.Count -eq 0) {
            Write-Host "  (empty / пусто)" -ForegroundColor DarkGray
        } else {
            for ($i = 0; $i -lt $items.Count; $i++) {
                $mark = if ($items[$i].Enabled) { "[v]" } else { "[x]" }
                $srcTag = "[$($items[$i].Source)]"
                Write-Host ("  {0,2}. {1} {2,-7} {3}" -f ($i+1), $mark, $srcTag, $items[$i].Name)
                if ($items[$i].Source -eq "TASK") {
                    Write-Host ("       ------------------------------------------") -ForegroundColor DarkGray
                }
            }
        }
        Write-Host ""
        Write-Host "  Enter number to toggle / Введите номер для переключения"
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        if ($choice -eq "0") { return }

        $index = 0
        if ([int]::TryParse($choice, [ref]$index) -and $index -ge 1 -and $index -le $items.Count) {
            Toggle-StartupItemBySource $items[$index - 1]
        } else {
            Write-Host "  $(L 'InvalidChoice')" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}

function Show-StartupSourceMenu {
    while ($true) {
        Show-Header (L "M2")
        Write-Host "  1. RUN (registry)"
        Write-Host "  2. STARTUP (folder)"
        Write-Host "  3. TASK SCHEDULER"
        Write-Host "  4. ALL / ВСЕ ВМЕСТЕ"
        Write-Host ""
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        switch ($choice) {
            "1" { Show-StartupItemsList -Title "RUN" -GetItems { Get-RunItems } }
            "2" { Show-StartupItemsList -Title "STARTUP" -GetItems { Get-StartupFolderItems } }
            "3" { Show-StartupItemsList -Title "TASK SCHEDULER" -GetItems { Get-TaskSchedulerItems } }
            "4" {
                Show-StartupItemsList -Title "ALL STARTUP ITEMS" -GetItems {
                    @(Get-RunItems) + @(Get-StartupFolderItems) + @(Get-TaskSchedulerItems)
                }
            }
            "0" { return }
        }
    }
}

function Get-BackgroundApps {
    $basePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    $items = @()
    if (Test-Path $basePath) {
        Get-ChildItem -Path $basePath | ForEach-Object {
            $disabledVal = (Get-ItemProperty -Path $_.PSPath -Name "Disabled" -ErrorAction SilentlyContinue).Disabled
            $items += [PSCustomObject]@{
                Name    = $_.PSChildName
                Path    = $_.PSPath
                Enabled = ($disabledVal -ne 1)
            }
        }
    }
    return $items | Sort-Object Name
}

function Show-BackgroundAppsMenu {
    while ($true) {
        Show-Header "Background UWP Apps"
        $apps = @(Get-BackgroundApps)
        if ($apps.Count -eq 0) {
            Write-Host "  (no entries found / записи не найдены)" -ForegroundColor DarkGray
        } else {
            for ($i = 0; $i -lt $apps.Count; $i++) {
                $mark = Get-ToggleMark -IsOn $apps[$i].Enabled -OnIsBad $true
                Write-Host ("  {0,2}. {1} {2}" -f ($i+1), $mark.Text, $apps[$i].Name) -ForegroundColor $mark.Color
            }
        }
        Write-Host ""
        Write-Host "  Enter number to toggle / Введите номер для переключения"
        Write-Host "  A. Disable ALL / Выключить все"
        Write-Host "  E. Enable ALL / Включить все"
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        switch ($choice.ToUpper()) {
            "0" { return }
            "A" {
                foreach ($app in $apps) {
                    Set-ItemProperty -Path $app.Path -Name "Disabled" -Value 1 -ErrorAction SilentlyContinue
                }
                Write-Log "All background UWP apps disabled"
            }
            "E" {
                foreach ($app in $apps) {
                    Set-ItemProperty -Path $app.Path -Name "Disabled" -Value 0 -ErrorAction SilentlyContinue
                }
                Write-Log "All background UWP apps enabled"
            }
            default {
                $index = 0
                if ([int]::TryParse($choice, [ref]$index) -and $index -ge 1 -and $index -le $apps.Count) {
                    $app = $apps[$index - 1]
                    $newVal = if ($app.Enabled) { 1 } else { 0 }
                    Set-ItemProperty -Path $app.Path -Name "Disabled" -Value $newVal -ErrorAction SilentlyContinue
                    Write-Log "Background app '$($app.Name)' toggled"
                }
            }
        }
    }
}

function Show-StartupMenu {
    while ($true) {
        Show-Header (L "M2")
        Write-Host "  1. Manage startup programs / Управление автозагрузкой"
        Write-Host "  2. Background UWP apps / Фоновые UWP-приложения"
        Write-Host ""
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        switch ($choice) {
            "1" { Show-StartupSourceMenu }
            "2" { Show-BackgroundAppsMenu }
            "0" { return }
        }
    }
}

# =====================================================
#  РАЗДЕЛ 3: DISK SPACE
# =====================================================
function Show-DiskDetail {
    param($d)
    $healthColor = switch ($d.HealthStatus) {
        "Healthy" { "Green" }
        default   { "Red" }
    }
    $sizeGB = [math]::Round($d.Size / 1GB, 1)
    $mediaLabel = if ($d.MediaType -eq "SSD") { "SSD" } elseif ($d.MediaType -eq "HDD") { "HDD" } else { "$($d.MediaType)" }

    Write-Host "  -----------------------------------" -ForegroundColor DarkGray
    Write-Host "  $mediaLabel - $($d.FriendlyName)" -ForegroundColor (Get-ThemeColor)
    Write-Host "  -----------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "    Model:           $($d.Model)"
    Write-Host "    Serial Number:   $($d.SerialNumber)"
    Write-Host "    Size:            $sizeGB GB"
    Write-Host "    Media Type:      $($d.MediaType)"
    Write-Host "    Bus Type:        $($d.BusType)"
    Write-Host "    Firmware:        $($d.FirmwareVersion)"
    Write-Host "    Health Status:   $($d.HealthStatus)" -ForegroundColor $healthColor
    Write-Host "    Operational:     $($d.OperationalStatus)"
    Write-Host "    Spindle Speed:   $(if ($d.SpindleSpeed -eq 0) { 'SSD (no spindle)' } else { "$($d.SpindleSpeed) RPM" })"

    $counters = $d | Get-StorageReliabilityCounter -ErrorAction SilentlyContinue
    if ($counters) {
        Write-Host "    --- Reliability counters ---" -ForegroundColor DarkGray
        if ($null -ne $counters.Temperature) {
            Write-Host "    Temperature:         $($counters.Temperature) C"
        }
        if ($null -ne $counters.TemperatureMax) {
            Write-Host "    Max Temperature:     $($counters.TemperatureMax) C"
        }
        if ($null -ne $counters.Wear) {
            Write-Host "    Wear level:          $($counters.Wear)%"
        }
        if ($null -ne $counters.PowerOnHours) {
            $days = [math]::Round($counters.PowerOnHours / 24, 0)
            Write-Host "    Power-on hours:      $($counters.PowerOnHours) (~$days days)"
        }
        if ($null -ne $counters.ReadErrorsUncorrected) {
            Write-Host "    Read errors:         $($counters.ReadErrorsUncorrected)"
        }
        if ($null -ne $counters.WriteErrorsUncorrected) {
            Write-Host "    Write errors:        $($counters.WriteErrorsUncorrected)"
        }
        if ($null -ne $counters.ReadLatencyMax) {
            Write-Host "    Max Read Latency:    $($counters.ReadLatencyMax) ms"
        }
        if ($null -ne $counters.WriteLatencyMax) {
            Write-Host "    Max Write Latency:   $($counters.WriteLatencyMax) ms"
        }
        if ($null -ne $counters.LoadUnloadCycleCount) {
            Write-Host "    Load/Unload Cycles:  $($counters.LoadUnloadCycleCount)"
        }
        if ($null -ne $counters.StartStopCycleCount) {
            Write-Host "    Start/Stop Cycles:   $($counters.StartStopCycleCount)"
        }
    }

    $partitions = Get-Partition -DiskNumber $d.DeviceId -ErrorAction SilentlyContinue
    if ($partitions) {
        Write-Host "    --- Partitions ---" -ForegroundColor DarkGray
        foreach ($p in $partitions) {
            $pSizeGB = [math]::Round($p.Size / 1GB, 1)
            $letter = if ($p.DriveLetter) { "$($p.DriveLetter):" } else { "(no letter)" }
            Write-Host "    $letter  $pSizeGB GB"
        }
    }
    Write-Host ""
}

function Show-DiskHealthMenu {
    $disks = @(Get-PhysicalDisk)
    if ($disks.Count -eq 0) {
        Show-Header "Disk Health"
        Write-Host "  (no disks found / диски не найдены)" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  $(L 'PressEnter')"
        Read-Host | Out-Null
        return
    }

    if ($disks.Count -eq 1) {
        Show-Header "Disk Health"
        Show-DiskDetail $disks[0]
        Write-Host "  $(L 'PressEnter')"
        Read-Host | Out-Null
        return
    }

    while ($true) {
        Show-Header "Disk Health"
        for ($i = 0; $i -lt $disks.Count; $i++) {
            $mediaLabel = if ($disks[$i].MediaType -eq "SSD") { "SSD" } elseif ($disks[$i].MediaType -eq "HDD") { "HDD" } else { "$($disks[$i].MediaType)" }
            Write-Host ("  {0}. [{1}] {2}" -f ($i+1), $mediaLabel, $disks[$i].FriendlyName)
        }
        Write-Host "  A. Show all / Показать все"
        Write-Host ""
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        if ($choice -eq "0") { return }
        if ($choice.ToUpper() -eq "A") {
            Show-Header "Disk Health"
            foreach ($d in $disks) {
                Show-DiskDetail $d
            }
            Write-Host "  $(L 'PressEnter')"
            Read-Host | Out-Null
            continue
        }
        $index = 0
        if ([int]::TryParse($choice, [ref]$index) -and $index -ge 1 -and $index -le $disks.Count) {
            Show-Header "Disk Health"
            Show-DiskDetail $disks[$index - 1]
            Write-Host "  $(L 'PressEnter')"
            Read-Host | Out-Null
        }
    }
}

function Show-DiskMenu {
    while ($true) {
        Show-Header (L "M3")
        $drive = Get-PSDrive C
        $freeGB = [math]::Round($drive.Free / 1GB, 1)
        Write-Host "  Free space on C: $freeGB GB" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  1. Clean TEMP files"
        Write-Host "  2. Clean Windows Update cache"
        Write-Host "  3. Remove Windows.old (if exists)"
        Write-Host "  4. Empty Recycle Bin"
        Write-Host "  5. Disk health / S.M.A.R.T. status"
        Write-Host ""
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        switch ($choice) {
            "1" {
                Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
                Write-Log "Temp files cleaned"
                Write-Host "  Done." -ForegroundColor Green
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "2" {
                Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
                Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
                Start-Service -Name wuauserv -ErrorAction SilentlyContinue
                Write-Log "Windows Update cache cleaned"
                Write-Host "  Done." -ForegroundColor Green
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "3" {
                if (Test-Path "C:\Windows.old") {
                    takeown /F "C:\Windows.old" /R /A | Out-Null
                    icacls "C:\Windows.old" /T /grant administrators:F | Out-Null
                    Remove-Item -Path "C:\Windows.old" -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Log "Windows.old removed"
                    Write-Host "  Done." -ForegroundColor Green
                } else {
                    Write-Host "  Windows.old not found." -ForegroundColor Yellow
                }
                Start-Sleep -Seconds 1
            }
            "4" {
                Clear-RecycleBin -Force -ErrorAction SilentlyContinue
                Write-Log "Recycle bin emptied"
                Write-Host "  Done." -ForegroundColor Green
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "5" { Show-DiskHealthMenu }
            "0" { return }
        }
    }
}

# =====================================================
#  РАЗДЕЛ 4: PRIVACY
# =====================================================
function Show-PrivacyMenu {
    while ($true) {
        Show-Header (L "M4")

        $telemetryVal = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -ErrorAction SilentlyContinue).AllowTelemetry
        $telemetryOn = ($telemetryVal -ne 0)
        $telemetryMark = Get-ToggleMark -IsOn $telemetryOn -OnIsBad $true

        $adIdVal = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -ErrorAction SilentlyContinue).Enabled
        $adIdOn = ($adIdVal -ne 0)
        $adIdMark = Get-ToggleMark -IsOn $adIdOn -OnIsBad $true

        $tipsVal = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -ErrorAction SilentlyContinue).SoftLandingEnabled
        $tipsOn = ($tipsVal -ne 0)
        $tipsMark = Get-ToggleMark -IsOn $tipsOn -OnIsBad $true

        Write-Host ("  1. Telemetry / Телеметрия {0} {1}" -f $telemetryMark.Text, $telemetryMark.Note) -ForegroundColor $telemetryMark.Color
        Write-Host ("  2. Advertising ID / Рекламный ID {0} {1}" -f $adIdMark.Text, $adIdMark.Note) -ForegroundColor $adIdMark.Color
        Write-Host ("  3. Windows tips and suggestions / Советы Windows {0} {1}" -f $tipsMark.Text, $tipsMark.Note) -ForegroundColor $tipsMark.Color
        Write-Host ""
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        switch ($choice) {
            "1" {
                $newVal = if ($telemetryOn) { 0 } else { 1 }
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value $newVal -ErrorAction SilentlyContinue
                Write-Log "Telemetry set to $newVal"
                Write-Host "  Done." -ForegroundColor Green
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "2" {
                $newVal = if ($adIdOn) { 0 } else { 1 }
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value $newVal -ErrorAction SilentlyContinue
                Write-Log "Advertising ID set to $newVal"
                Write-Host "  Done." -ForegroundColor Green
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "3" {
                $newVal = if ($tipsOn) { 0 } else { 1 }
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Value $newVal -ErrorAction SilentlyContinue
                Write-Log "Windows tips set to $newVal"
                Write-Host "  Done." -ForegroundColor Green
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "0" { return }
        }
    }
}

# =====================================================
#  РАЗДЕЛ 5: SYSTEM INFO
# =====================================================
function Show-SystemInfoSummary {
    Show-Header (L "M5")
    $cpuInfo = Get-CimInstance Win32_Processor
    $ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    $osInfo = Get-CimInstance Win32_OperatingSystem
    $bios = Get-CimInstance Win32_BIOS
    $board = Get-CimInstance Win32_BaseBoard
    $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
    $drive = Get-PSDrive C
    $freeGB = [math]::Round($drive.Free / 1GB, 1)
    $totalGB = [math]::Round(($drive.Free + $drive.Used) / 1GB, 1)
    $uptime = (Get-Date) - $osInfo.LastBootUpTime
    $uptimeStr = "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes
    $resolution = Get-CimInstance Win32_VideoController | Select-Object -First 1 -Property CurrentHorizontalResolution, CurrentVerticalResolution

    Write-Host "  --- CPU ---" -ForegroundColor DarkGray
    Write-Host "  Name:          $($cpuInfo.Name)"
    Write-Host "  Cores/Threads: $($cpuInfo.NumberOfCores) cores / $($cpuInfo.NumberOfLogicalProcessors) threads"
    Write-Host "  Max Clock:     $($cpuInfo.MaxClockSpeed) MHz"
    Write-Host "  Current Load:  $($cpuInfo.LoadPercentage)%"
    Write-Host ""
    Write-Host "  --- RAM ---" -ForegroundColor DarkGray
    Write-Host "  Total:         $ram GB"
    Write-Host ""
    Write-Host "  --- GPU ---" -ForegroundColor DarkGray
    if ($gpu) {
        Write-Host "  Name:          $($gpu.Name)"
        if ($resolution.CurrentHorizontalResolution) {
            Write-Host "  Resolution:    $($resolution.CurrentHorizontalResolution)x$($resolution.CurrentVerticalResolution)"
        }
    }
    Write-Host ""
    Write-Host "  --- Motherboard / BIOS ---" -ForegroundColor DarkGray
    Write-Host "  Board:         $($board.Manufacturer) $($board.Product)"
    Write-Host "  BIOS Version:  $($bios.SMBIOSBIOSVersion)"
    Write-Host "  BIOS Date:     $(if ($bios.ReleaseDate) { $bios.ReleaseDate.ToString('yyyy-MM-dd') } else { 'n/a' })"
    Write-Host ""
    Write-Host "  --- OS ---" -ForegroundColor DarkGray
    Write-Host "  Name:          $($osInfo.Caption)"
    Write-Host "  Version:       $($osInfo.Version) (Build $($osInfo.BuildNumber))"
    Write-Host "  Install Date:  $(if ($osInfo.InstallDate) { $osInfo.InstallDate.ToString('yyyy-MM-dd') } else { 'n/a' })"
    Write-Host "  Last Boot:     $($osInfo.LastBootUpTime.ToString('yyyy-MM-dd HH:mm'))"
    Write-Host "  Uptime:        $uptimeStr"
    Write-Host "  Arch:          $($Global:Config.Architecture)-bit (selected)"
    Write-Host ""
    Write-Host "  --- Disk C: ---" -ForegroundColor DarkGray
    Write-Host "  Free / Total:  $freeGB GB / $totalGB GB"
    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

function Show-DriverList {
    Show-Header "Installed Drivers"
    Get-CimInstance Win32_PnPSignedDriver |
        Where-Object { $_.DeviceName } |
        Sort-Object DriverDate -Descending |
        Select-Object -First 40 |
        ForEach-Object {
            $date = if ($_.DriverDate) { ([datetime]$_.DriverDate).ToString("yyyy-MM-dd") } else { "n/a" }
            Write-Host ("  {0,-45} {1}  v{2}" -f $_.DeviceName, $date, $_.DriverVersion)
        }
    Write-Host ""
    Write-Host "  (showing latest 40 / показаны последние 40)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

function Show-LiveSnapshot {
    Show-Header "Live CPU / RAM"
    Write-Host "  Sampling... / Замер..." -ForegroundColor DarkGray
    $cpuLoad = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
    $os = Get-CimInstance Win32_OperatingSystem
    $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM  = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedRAM  = [math]::Round($totalRAM - $freeRAM, 2)
    $ramPercent = [math]::Round(($usedRAM / $totalRAM) * 100, 0)

    $pageFile = Get-CimInstance Win32_PageFileUsage -ErrorAction SilentlyContinue
    $commitLimit = [math]::Round($os.TotalVirtualMemorySize / 1MB, 2)
    $commitUsed = [math]::Round(($os.TotalVirtualMemorySize - $os.FreeVirtualMemory) / 1MB, 2)

    $topCPU = Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 -Property ProcessName, CPU, WorkingSet
    $topRAM = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 -Property ProcessName, WorkingSet

    function Get-Bar($percent) {
        $filled = [math]::Round($percent / 5)
        return ("█" * $filled) + ("░" * (20 - $filled))
    }

    Show-Header "Live CPU / RAM"
    Write-Host "  CPU Load: $cpuLoad%"
    Write-Host "  [$(Get-Bar $cpuLoad)]"
    Write-Host ""
    Write-Host "  RAM Used: $usedRAM GB / $totalRAM GB ($ramPercent%)"
    Write-Host "  [$(Get-Bar $ramPercent)]"
    Write-Host ""
    Write-Host "  Virtual Memory (Commit): $commitUsed GB / $commitLimit GB"
    if ($pageFile) {
        foreach ($pf in $pageFile) {
            Write-Host "  Page file: $($pf.Name)  ($([math]::Round($pf.AllocatedBaseSize/1024,2)) GB allocated)"
        }
    }
    Write-Host ""
    Write-Host "  --- Top 5 by CPU time ---" -ForegroundColor DarkGray
    foreach ($p in $topCPU) {
        $cpuTime = if ($p.CPU) { [math]::Round($p.CPU, 1) } else { 0 }
        $ramMB = [math]::Round($p.WorkingSet / 1MB, 0)
        Write-Host ("  {0,-25} CPU: {1,8}s   RAM: {2,6} MB" -f $p.ProcessName, $cpuTime, $ramMB)
    }
    Write-Host ""
    Write-Host "  --- Top 5 by RAM usage ---" -ForegroundColor DarkGray
    foreach ($p in $topRAM) {
        $ramMB = [math]::Round($p.WorkingSet / 1MB, 0)
        Write-Host ("  {0,-25} RAM: {1,6} MB" -f $p.ProcessName, $ramMB)
    }
    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

function Show-SystemInfo {
    while ($true) {
        Show-Header (L "M5")
        Write-Host "  1. Summary / Общая информация"
        Write-Host "  2. Installed drivers / Установленные драйверы"
        Write-Host "  3. Live CPU/RAM snapshot / Снэпшот в реальном времени"
        Write-Host "  4. CPU details / Подробно о процессоре"
        Write-Host "  5. GPU details / Подробно о видеокарте"
        Write-Host ""
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        switch ($choice) {
            "1" { Show-SystemInfoSummary }
            "2" { Show-DriverList }
            "3" { Show-LiveSnapshot }
            "4" { Show-CPUDetails }
            "5" { Show-GPUDetails }
            "0" { return }
        }
    }
}

function Show-CPUDetails {
    Show-Header "CPU Details"
    $cpu = Get-CimInstance Win32_Processor

    Write-Host "  Name:                $($cpu.Name.Trim())"
    Write-Host "  Manufacturer:        $($cpu.Manufacturer)"
    Write-Host "  Socket:              $($cpu.SocketDesignation)"
    Write-Host "  Cores:               $($cpu.NumberOfCores)"
    Write-Host "  Logical Processors:  $($cpu.NumberOfLogicalProcessors)"
    Write-Host "  Max Clock Speed:     $($cpu.MaxClockSpeed) MHz"
    Write-Host "  Current Clock Speed: $($cpu.CurrentClockSpeed) MHz"
    Write-Host "  L2 Cache Size:       $($cpu.L2CacheSize) KB"
    Write-Host "  L3 Cache Size:       $($cpu.L3CacheSize) KB"
    Write-Host "  Current Load:        $($cpu.LoadPercentage)%"
    Write-Host "  Virtualization:      $($cpu.VirtualizationFirmwareEnabled)"
    Write-Host "  Architecture:        $($cpu.AddressWidth)-bit"

    # Попытка получить температуру через WMI thermal zone (не на всех системах доступно)
    Write-Host ""
    Write-Host "  --- Temperature ---" -ForegroundColor DarkGray
    try {
        $thermal = Get-CimInstance -Namespace "root/wmi" -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction Stop
        if ($thermal) {
            $i = 1
            foreach ($zone in $thermal) {
                $tempC = [math]::Round(($zone.CurrentTemperature / 10) - 273.15, 1)
                Write-Host "  Zone $i`: $tempC C"
                $i++
            }
        } else {
            Write-Host "  Not available on this system. / Недоступно на этой системе." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  Not available (requires vendor tools like HWiNFO/Core Temp for accurate readings)." -ForegroundColor Yellow
        Write-Host "  Недоступно (для точных данных нужны сторонние утилиты вроде HWiNFO/Core Temp)." -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

function Show-GPUDetails {
    Show-Header "GPU Details"
    $gpus = Get-CimInstance Win32_VideoController
    foreach ($gpu in $gpus) {
        $vramGB = if ($gpu.AdapterRAM) { [math]::Round($gpu.AdapterRAM / 1GB, 2) } else { "n/a" }
        Write-Host "  Name:              $($gpu.Name)"
        Write-Host "  Driver Version:    $($gpu.DriverVersion)"
        Write-Host "  Driver Date:       $(if ($gpu.DriverDate) { ([datetime]$gpu.DriverDate).ToString('yyyy-MM-dd') } else { 'n/a' })"
        Write-Host "  VRAM:              $vramGB GB"
        Write-Host "  Video Processor:   $($gpu.VideoProcessor)"
        Write-Host "  Resolution:        $($gpu.CurrentHorizontalResolution)x$($gpu.CurrentVerticalResolution)"
        Write-Host "  Refresh Rate:      $($gpu.CurrentRefreshRate) Hz"
        Write-Host "  Status:            $($gpu.Status)"
        Write-Host ""
    }
    Write-Host "  --- Temperature ---" -ForegroundColor DarkGray
    Write-Host "  Not available via built-in Windows tools." -ForegroundColor Yellow
    Write-Host "  Недоступно через встроенные средства Windows."
    Write-Host "  (requires vendor tools like GPU-Z / MSI Afterburner)"
    Write-Host "  (нужны сторонние утилиты вроде GPU-Z / MSI Afterburner)"
    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

# =====================================================
#  РАЗДЕЛ 6: EXPORT REPORT
# =====================================================
function Show-ExportReport {
    Show-Header (L "M6")
    Write-Host "  Gathering data... / Сбор данных..." -ForegroundColor DarkGray
    $reportPath = Join-Path $ScriptDir "report.txt"

    $cpuInfo = Get-CimInstance Win32_Processor
    $ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    $osInfo = Get-CimInstance Win32_OperatingSystem
    $bios = Get-CimInstance Win32_BIOS
    $board = Get-CimInstance Win32_BaseBoard
    $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
    $drive = Get-PSDrive C
    $freeGB = [math]::Round($drive.Free / 1GB, 1)
    $totalGB = [math]::Round(($drive.Free + $drive.Used) / 1GB, 1)
    $uptime = (Get-Date) - $osInfo.LastBootUpTime
    $uptimeStr = "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes

    $sysmainStart = (Get-Service -Name "SysMain" -ErrorAction SilentlyContinue).StartType
    $wsearchStart = (Get-Service -Name "WSearch" -ErrorAction SilentlyContinue).StartType
    $runningServices = (Get-Service | Where-Object { $_.Status -eq "Running" }).Count
    $totalServices = (Get-Service).Count

    $disks = Get-PhysicalDisk
    $diskLines = @()
    foreach ($d in $disks) {
        $sizeGB = [math]::Round($d.Size / 1GB, 1)
        $counters = $d | Get-StorageReliabilityCounter -ErrorAction SilentlyContinue
        $temp = if ($counters -and $null -ne $counters.Temperature) { "$($counters.Temperature) C" } else { "n/a" }
        $wear = if ($counters -and $null -ne $counters.Wear) { "$($counters.Wear)%" } else { "n/a" }
        $diskLines += "  - $($d.FriendlyName) [$($d.MediaType)] $sizeGB GB, Health: $($d.HealthStatus), Temp: $temp, Wear: $wear"
    }

    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    $netLines = @()
    foreach ($a in $adapters) {
        $netLines += "  - $($a.Name): $($a.LinkSpeed), MAC: $($a.MacAddress)"
    }

    $topRAM = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5
    $procLines = @()
    foreach ($p in $topRAM) {
        $ramMB = [math]::Round($p.WorkingSet / 1MB, 0)
        $procLines += "  - $($p.ProcessName): $ramMB MB"
    }

    $report = @"
Optimization Tool - System Report
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
========================================
CPU
========================================
Name: $($cpuInfo.Name)
Cores/Threads: $($cpuInfo.NumberOfCores) / $($cpuInfo.NumberOfLogicalProcessors)
Max Clock: $($cpuInfo.MaxClockSpeed) MHz
Current Load: $($cpuInfo.LoadPercentage)%

========================================
RAM
========================================
Total: $ram GB

========================================
GPU
========================================
Name: $($gpu.Name)

========================================
Motherboard / BIOS
========================================
Board: $($board.Manufacturer) $($board.Product)
BIOS Version: $($bios.SMBIOSBIOSVersion)

========================================
OS
========================================
Name: $($osInfo.Caption)
Version: $($osInfo.Version) (Build $($osInfo.BuildNumber))
Uptime: $uptimeStr
Selected architecture: $($Global:Config.Architecture)-bit

========================================
Disk C:
========================================
Free / Total: $freeGB GB / $totalGB GB

========================================
Physical Disks
========================================
$($diskLines -join "`n")

========================================
Network Adapters (active)
========================================
$($netLines -join "`n")

========================================
Services
========================================
SysMain startup type: $sysmainStart
Windows Search startup type: $wsearchStart
Running services: $runningServices / $totalServices

========================================
Top 5 processes by RAM
========================================
$($procLines -join "`n")

========================================
Developer: github.com/ghostsmash
"@
    $report | Set-Content -Path $reportPath -Encoding UTF8
    Write-Log "Report exported to $reportPath"
    Write-Host "  Report saved to: $reportPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

# =====================================================
#  РАЗДЕЛ 7: NETWORK
# =====================================================

function Get-Sparkline {
    param([double[]]$Values)
    if ($Values.Count -eq 0) { return "" }
    $chars = @("▁","▂","▃","▄","▅","▆","▇","█")
    $min = ($Values | Measure-Object -Minimum).Minimum
    $max = ($Values | Measure-Object -Maximum).Maximum
    $range = $max - $min
    if ($range -eq 0) { $range = 1 }
    $line = ""
    foreach ($v in $Values) {
        $idx = [math]::Floor((($v - $min) / $range) * 7)
        if ($idx -lt 0) { $idx = 0 }
        if ($idx -gt 7) { $idx = 7 }
        $line += $chars[$idx]
    }
    return $line
}

function Show-AdapterDetail {
    param($Adapter)
    Show-Header $Adapter.Name
    Write-Host "  Name:        $($Adapter.Name)"
    Write-Host "  Description: $($Adapter.InterfaceDescription)"
    Write-Host "  Status:      $($Adapter.Status)"
    Write-Host "  Link Speed:  $($Adapter.LinkSpeed)"
    Write-Host "  MAC Address: $($Adapter.MacAddress)"

    $ipConfig = Get-NetIPConfiguration -InterfaceIndex $Adapter.ifIndex -ErrorAction SilentlyContinue
    if ($ipConfig) {
        $ipv4 = $ipConfig.IPv4Address.IPAddress -join ", "
        $gw   = $ipConfig.IPv4DefaultGateway.NextHop -join ", "
        $dns  = ($ipConfig.DNSServer | Where-Object { $_.AddressFamily -eq 2 }).ServerAddresses -join ", "
        Write-Host "  IPv4:        $ipv4"
        Write-Host "  Gateway:     $gw"
        Write-Host "  DNS:         $dns"
    }
    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

function Show-AdapterMenu {
    while ($true) {
        Show-Header "Network Adapters"
        $adapters = @(Get-NetAdapter)
        if ($adapters.Count -eq 0) {
            Write-Host "  (no adapters found / адаптеры не найдены)" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  $(L 'PressEnter')"
            Read-Host | Out-Null
            return
        }
        for ($i = 0; $i -lt $adapters.Count; $i++) {
            $desc = $adapters[$i].InterfaceDescription
            $type = if ($desc -match "Wireless|Wi-Fi|WiFi|802\.11") { "Wi-Fi" }
                    elseif ($desc -match "RNDIS|Mobile Broadband|USB.*Modem|WWAN") { "USB" }
                    elseif ($adapters[$i].Virtual -eq $true) { "Virt" }
                    else { "LAN" }
            Write-Host ("  {0}. [{1,-5}] {2} - {3}" -f ($i+1), $type, $adapters[$i].Name, $adapters[$i].Status)
        }
        Write-Host ""
        Write-Host "  Enter number for details / Введите номер для деталей"
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        if ($choice -eq "0") { return }
        $index = 0
        if ([int]::TryParse($choice, [ref]$index) -and $index -ge 1 -and $index -le $adapters.Count) {
            Show-AdapterDetail $adapters[$index - 1]
        }
    }
}

function Show-ConnectionInfo {
    Show-Header "Current Connection Info"
    $ipConfig = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Select-Object -First 1
    if ($ipConfig) {
        Write-Host "  Adapter:     $($ipConfig.InterfaceAlias)"
        Write-Host "  IPv4:        $($ipConfig.IPv4Address.IPAddress)"
        Write-Host "  Gateway:     $($ipConfig.IPv4DefaultGateway.NextHop)"
        $dns = ($ipConfig.DNSServer | Where-Object { $_.AddressFamily -eq 2 }).ServerAddresses -join ", "
        Write-Host "  DNS:         $dns"
        $adapter = Get-NetAdapter -InterfaceIndex $ipConfig.InterfaceIndex -ErrorAction SilentlyContinue
        if ($adapter) {
            Write-Host "  MAC:         $($adapter.MacAddress)"
            Write-Host "  Link Speed:  $($adapter.LinkSpeed)"
        }
    } else {
        Write-Host "  No active connection found. / Активное подключение не найдено." -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "  Public IP: fetching... / Публичный IP: получение..." -ForegroundColor DarkGray
    try {
        $publicIP = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5)
        Write-Host "  Public IP: $publicIP"
    } catch {
        Write-Host "  Public IP: unavailable / недоступно" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

$Global:PingTargets = @(
    @{ Name = "USA (Cloudflare)";   Host = "1.1.1.1" }
    @{ Name = "USA (Google)";       Host = "8.8.8.8" }
    @{ Name = "Germany";            Host = "9.9.9.9" }
    @{ Name = "Poland";             Host = "195.187.242.1" }
    @{ Name = "Russia (Yandex)";    Host = "77.88.8.8" }
    @{ Name = "Japan";              Host = "210.130.202.11" }
)

function Show-PingTest {
    while ($true) {
        Show-Header "Ping Test"
        for ($i = 0; $i -lt $Global:PingTargets.Count; $i++) {
            Write-Host ("  {0}. {1}" -f ($i+1), $Global:PingTargets[$i].Name)
        }
        Write-Host ""
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        if ($choice -eq "0") { return }
        $index = 0
        if ([int]::TryParse($choice, [ref]$index) -and $index -ge 1 -and $index -le $Global:PingTargets.Count) {
            $target = $Global:PingTargets[$index - 1]
            Show-Header "Ping: $($target.Name)"
            Write-Host "  Pinging $($target.Host)... / Пинг $($target.Host)..." -ForegroundColor DarkGray
            Write-Host ""
            $results = Test-Connection -ComputerName $target.Host -Count 10 -ErrorAction SilentlyContinue
            if ($results) {
                $times = $results | ForEach-Object { $_.ResponseTime }
                $avg = [math]::Round(($times | Measure-Object -Average).Average, 0)
                $min = ($times | Measure-Object -Minimum).Minimum
                $max = ($times | Measure-Object -Maximum).Maximum
                $spark = Get-Sparkline -Values $times
                Write-Host "  Min: $min ms   Avg: $avg ms   Max: $max ms"
                Write-Host "  $spark" -ForegroundColor (Get-ThemeColor)
                $lossPercent = [math]::Round((10 - $results.Count) / 10 * 100, 0)
                Write-Host ""
                $stability = if ($avg -lt 50) { "Stable / Стабильно" } elseif ($avg -lt 120) { "OK / Норм" } else { "Unstable / Нестабильно" }
                Write-Host "  Stability: $stability" -ForegroundColor (Get-ThemeColor)
            } else {
                Write-Host "  No response / Нет ответа" -ForegroundColor Red
            }
            Write-Host ""
            Write-Host "  $(L 'PressEnter')"
            Read-Host | Out-Null
        }
    }
}

function Ensure-SpeedtestCLI {
    $exePath = Join-Path $ScriptDir "speedtest.exe"
    if (Test-Path $exePath) { return $exePath }

    Show-Header "Speedtest CLI"
    Write-Host "  Speedtest CLI is not found and needs to be downloaded."
    Write-Host "  Speedtest CLI не найден и требует скачивания."
    Write-Host ""
    Write-Host "  Official source: https://www.speedtest.net/apps/cli" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Download now? / Скачать сейчас? (Y/N)"
    $confirm = Read-Host "  >"
    if ($confirm.ToUpper() -ne "Y") { return $null }

    $arch = if ([Environment]::Is64BitOperatingSystem) { "win64" } else { "win32" }
    $url = "https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-$arch.zip"
    $zipPath = Join-Path $ScriptDir "speedtest_tmp.zip"
    $extractPath = Join-Path $ScriptDir "speedtest_tmp"

    try {
        Write-Host ""
        Write-Host "  Downloading... / Скачивание..." -ForegroundColor DarkGray
        Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
        Copy-Item -Path (Join-Path $extractPath "speedtest.exe") -Destination $exePath -Force
        Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Speedtest CLI downloaded from official source"
        Write-Host "  Done." -ForegroundColor Green
        Start-Sleep -Seconds 1
        return $exePath
    } catch {
        Write-Host "  Download failed. / Скачивание не удалось." -ForegroundColor Red
        Start-Sleep -Seconds 2
        return $null
    }
}

function Get-BlockBar {
    param([double]$Percent, [int]$Width = 30)
    if ($Percent -lt 0) { $Percent = 0 }
    if ($Percent -gt 100) { $Percent = 100 }
    $filled = [math]::Round(($Percent / 100) * $Width)
    return ("█" * $filled) + ("░" * ($Width - $filled))
}

function Show-SpeedTest {
    $exePath = Ensure-SpeedtestCLI
    if (-not $exePath) { return }

    Show-Header "Speed Test"
    Write-Host "  Running Ookla Speedtest... / Выполняется тест..." -ForegroundColor DarkGray
    Write-Host ""

    & $exePath --accept-license --accept-gdpr

    Write-Host ""
    Write-Host "  --------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Test finished / Тест завершён." -ForegroundColor Green
    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

function Show-NetworkMenu {
    while ($true) {
        Show-Header (L "M7")
        Write-Host "  1. Flush DNS cache / Сбросить кэш DNS"
        Write-Host "  2. Network adapters (LAN/Wi-Fi) / Сетевые адаптеры"
        Write-Host "  3. Reset TCP/IP stack / Сбросить стек TCP/IP"
        Write-Host "  4. Reinstall / Reset Microsoft Store (wsreset)"
        Write-Host "  5. Current connection info / Инфо о текущем подключении"
        Write-Host "  6. Ping test (by country) / Тест пинга по странам"
        Write-Host "  7. Speed test / Тест скорости"
        Write-Host "  8. Active connections / Активные подключения"
        Write-Host ""
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        switch ($choice) {
            "1" {
                ipconfig /flushdns | Out-Null
                Write-Log "DNS cache flushed"
                Write-Host "  Done." -ForegroundColor Green
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "2" { Show-AdapterMenu }
            "3" {
                netsh int ip reset | Out-Null
                netsh winsock reset | Out-Null
                Write-Log "TCP/IP stack reset"
                Write-Host "  Done. Restart required." -ForegroundColor Green
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "4" {
                Show-Header "Microsoft Store Reset"
                $storeApp = Get-AppxPackage -Name "*WindowsStore*" -ErrorAction SilentlyContinue
                if ($storeApp) {
                    Write-Host "  Microsoft Store is already installed."
                    Write-Host "  Microsoft Store уже установлен."
                } else {
                    Write-Host "  Microsoft Store was not found."
                    Write-Host "  Microsoft Store не найден."
                }
                Write-Host ""
                Write-Host "  Y. Install/Reset anyway / Все равно установить"
                Write-Host "  N. Cancel / Отмена"
                Write-Host ""
                $confirm = Read-Host "  >"
                if ($confirm.ToUpper() -eq "Y") {
                    Start-Process "wsreset.exe" -ArgumentList "-i"
                    Write-Log "wsreset -i launched"
                    Write-Host "  Microsoft Store reset launched (wsreset -i)." -ForegroundColor Green
                } else {
                    Write-Host "  Cancelled / Отменено." -ForegroundColor Yellow
                }
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "5" { Show-ConnectionInfo }
            "6" { Show-PingTest }
            "7" { Show-SpeedTest }
            "8" {
                Show-Header "Active Connections"
                Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue |
                    Select-Object -First 25 |
                    ForEach-Object {
                        Write-Host ("  {0,-16} -> {1,-16}:{2}" -f $_.LocalAddress, $_.RemoteAddress, $_.RemotePort)
                    }
                Write-Host ""
                Write-Host "  (showing up to 25 / показаны до 25)" -ForegroundColor DarkGray
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "0" { return }
        }
    }
}

# =====================================================
#  РАЗДЕЛ 8: REMOVE BLOATWARE
# =====================================================
$Global:BloatwareApps = @(
    @{ Name = "Xbox App";           Pattern = "*Xbox*" }
    @{ Name = "Xbox Game Bar";      Pattern = "*XboxGamingOverlay*" }
    @{ Name = "3D Viewer";          Pattern = "*3DViewer*" }
    @{ Name = "Mixed Reality Portal"; Pattern = "*MixedReality*" }
    @{ Name = "Skype";              Pattern = "*SkypeApp*" }
    @{ Name = "Weather";            Pattern = "*BingWeather*" }
    @{ Name = "News";               Pattern = "*BingNews*" }
    @{ Name = "Solitaire Collection"; Pattern = "*SolitaireCollection*" }
    @{ Name = "Paint 3D";           Pattern = "*MSPaint*" }
    @{ Name = "Get Help";           Pattern = "*GetHelp*" }
    @{ Name = "Feedback Hub";       Pattern = "*WindowsFeedbackHub*" }
    @{ Name = "OneNote (UWP)";      Pattern = "*OneNote*" }
    @{ Name = "Zune Music/Video";   Pattern = "*ZuneMusic*", "*ZuneVideo*" }
)

function Show-BloatwareMenu {
    while ($true) {
        Show-Header (L "M8")
        for ($i = 0; $i -lt $Global:BloatwareApps.Count; $i++) {
            $pattern = $Global:BloatwareApps[$i].Pattern
            $installed = $false
            foreach ($p in @($pattern)) {
                if (Get-AppxPackage -Name $p -ErrorAction SilentlyContinue) {
                    $installed = $true
                    break
                }
            }
            $mark = if ($installed) { "[v]" } else { "[x]" }
            Write-Host ("  {0,2}. {1} {2}" -f ($i+1), $mark, $Global:BloatwareApps[$i].Name)
        }
        Write-Host ""
        Write-Host "  [v] = installed / установлено   [x] = not installed / не установлено"
        Write-Host "  Enter number to remove / Введите номер для удаления"
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        if ($choice -eq "0") { return }

        $index = 0
        if ([int]::TryParse($choice, [ref]$index) -and $index -ge 1 -and $index -le $Global:BloatwareApps.Count) {
            $app = $Global:BloatwareApps[$index - 1]
            $foundPackage = $false
            foreach ($p in @($app.Pattern)) {
                if (Get-AppxPackage -Name $p -ErrorAction SilentlyContinue) {
                    $foundPackage = $true
                    Get-AppxPackage -Name $p -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
                }
            }
            if ($foundPackage) {
                Write-Log "Bloatware removed: $($app.Name)"
                Write-Host "  Done. (Can be reinstalled from Store later)" -ForegroundColor Green
            } else {
                Write-Host "  App is not installed. / Приложение не установлено." -ForegroundColor Yellow
            }
            Write-Host ""
            Write-Host "  $(L 'PressEnter')"
            Read-Host | Out-Null
        } else {
            Write-Host "  $(L 'InvalidChoice')" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}

# =====================================================
#  РАЗДЕЛ P: POWER (SHUTDOWN / RESTART)
# =====================================================
function Get-SecondsInput {
    param([string]$Prompt)
    while ($true) {
        $val = Read-Host "  $Prompt"
        $num = 0
        if ([int]::TryParse($val, [ref]$num) -and $num -ge 0) {
            return $num
        }
        Write-Host "  $(L 'InvalidChoice')" -ForegroundColor Red
    }
}

function Show-PowerMenu {
    while ($true) {
        Show-Header (L "MP")
        Write-Host "  --- Shutdown / Выключение ---"
        Write-Host "  1. Shutdown now / Выключить сейчас"
        Write-Host "  2. Shutdown with timer / Выключение с таймером"
        Write-Host "  3. Shutdown with message / Выключение с сообщением"
        Write-Host "  4. Shutdown with timer + message / Таймер + сообщение"
        Write-Host ""
        Write-Host "  --- Restart / Перезагрузка ---"
        Write-Host "  5. Restart now / Перезагрузить сейчас"
        Write-Host "  6. Restart with timer / Перезагрузка с таймером"
        Write-Host "  7. Restart with message / Перезагрузка с сообщением"
        Write-Host "  8. Restart with timer + message / Таймер + сообщение"
        Write-Host ""
        Write-Host "  9. Cancel pending shutdown/restart / Отменить запланированное"
        Write-Host "  L. Lock screen / Заблокировать экран"
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"

        switch ($choice.ToUpper()) {
            "1" {
                shutdown.exe /s /t 0
            }
            "2" {
                $sec = Get-SecondsInput "Seconds until shutdown / Секунд до выключения:"
                shutdown.exe /s /t $sec
                Write-Host "  Scheduled in $sec sec." -ForegroundColor Green
                Start-Sleep -Seconds 2
            }
            "3" {
                $msg = Read-Host "  Message / Сообщение"
                shutdown.exe /s /t 0 /c $msg
            }
            "4" {
                $sec = Get-SecondsInput "Seconds until shutdown / Секунд до выключения:"
                $msg = Read-Host "  Message / Сообщение"
                shutdown.exe /s /t $sec /c $msg
                Write-Host "  Scheduled in $sec sec." -ForegroundColor Green
                Start-Sleep -Seconds 2
            }
            "5" {
                shutdown.exe /r /t 0
            }
            "6" {
                $sec = Get-SecondsInput "Seconds until restart / Секунд до перезагрузки:"
                shutdown.exe /r /t $sec
                Write-Host "  Scheduled in $sec sec." -ForegroundColor Green
                Start-Sleep -Seconds 2
            }
            "7" {
                $msg = Read-Host "  Message / Сообщение"
                shutdown.exe /r /t 0 /c $msg
            }
            "8" {
                $sec = Get-SecondsInput "Seconds until restart / Секунд до перезагрузки:"
                $msg = Read-Host "  Message / Сообщение"
                shutdown.exe /r /t $sec /c $msg
                Write-Host "  Scheduled in $sec sec." -ForegroundColor Green
                Start-Sleep -Seconds 2
            }
            "9" {
                shutdown.exe /a
                Write-Host "  Cancelled / Отменено." -ForegroundColor Green
                Start-Sleep -Seconds 1
            }
            "L" {
                rundll32.exe user32.dll,LockWorkStation
            }
            "0" { return }
        }
    }
}

# =====================================================
#  РАЗДЕЛ D: ADVANCED / ДЛЯ РАЗРАБОТЧИКОВ
# =====================================================
function Show-AdvancedDisclaimer {
    Show-Header "! WARNING / ВНИМАНИЕ !"
    Write-Host "  ████████████████████████████████████████████████████████" -ForegroundColor Red
    Write-Host "  █          ADVANCED SECTION / ПРОДВИНУТЫЙ РАЗДЕЛ       █" -ForegroundColor Red
    Write-Host "  ████████████████████████████████████████████████████████" -ForegroundColor Red
    Write-Host ""
    Write-Host "  This section contains advanced, low-level system operations." -ForegroundColor Red
    Write-Host "  Этот раздел содержит продвинутые низкоуровневые операции." -ForegroundColor Red
    Write-Host ""
    Write-Host "  Some actions here are IRREVERSIBLE (e.g. DISM cleanup)." -ForegroundColor Red
    Write-Host "  Некоторые действия здесь НЕОБРАТИМЫ (например, очистка DISM)." -ForegroundColor Red
    Write-Host ""
    Write-Host "  By proceeding, you accept full responsibility for any changes." -ForegroundColor Red
    Write-Host "  Продолжая, вы берете на себя полную ответственность за изменения." -ForegroundColor Red
    Write-Host ""
    Write-Host "  Y. Yes, I accept / Да, принимаю" -ForegroundColor Green
    Write-Host "  N. No / Нет"
    Write-Host ""
    $choice = Read-Host "  >"
    return ($choice.ToUpper() -eq "Y")
}

function Show-MasActivation {
    Show-Header "MAS Activator (GitHub)"
    Write-Host "  ████████████████████████████████████████████████████████" -ForegroundColor Red
    Write-Host "  █                ! IMPORTANT NOTICE !                  █" -ForegroundColor Red
    Write-Host "  █             ОТКАЗ ОТ ОТВЕТСТВЕННОСТИ                 █" -ForegroundColor Red
    Write-Host "  ████████████████████████████████████████████████████████" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Вы запускаете сторонний открытый инструмент (Microsoft Activation Scripts)." -ForegroundColor Yellow
    Write-Host "  Данный скрипт загружается напрямую из репозитория GitHub / get.activated.win."
    Write-Host "  Разработчик Optimization Tool НЕ несёт ответственности за действия,"
    Write-Host "  выполняемые сторонним скриптом, изменения реестра или статус лицензии."
    Write-Host ""
    Write-Host "  Вся ответственность за запуск внешнего кода лежит исключительно на вас."
    Write-Host ""
    Write-Host "  1. Я понимаю риски, продолжить запуск / Proceed" -ForegroundColor Green
    Write-Host "  0. Отмена / Cancel"
    Write-Host ""
    $choice = Read-Host "  >"
    if ($choice -eq "1") {
        Write-Host ""
        Write-Host "  Загрузка и запуск MAS с get.activated.win..." -ForegroundColor DarkGray
        Write-Host ""
        try {
            Invoke-RestMethod -Uri "https://get.activated.win" | Invoke-Expression
            Write-Log "MAS Activator executed successfully via irm"
        } catch {
            Write-Host "  [!] Ошибка прямого подключения (irm). Пробуем обход через DNS (DoH)..." -ForegroundColor Yellow
            try {
                iex (curl.exe -s --doh-url https://1.1.1.1/dns-query https://get.activated.win)
                Write-Log "MAS Activator executed via DoH fallback"
            } catch {
                Write-Host "  [!] Не удалось загрузить скрипт. Проверьте подключение к сети или антивирус." -ForegroundColor Red
            }
        }
        Write-Host ""
        Write-Host "  $(L 'PressEnter')"
        Read-Host | Out-Null
    }
}

function Show-AdvancedMenu {
    if (-not $Global:Config.AdvancedAccepted) {
        if (-not (Show-AdvancedDisclaimer)) { return }
        $Global:Config.AdvancedAccepted = $true
        Save-Config
    }

    while ($true) {
        Show-Header "Advanced / Для разработчиков"
        Write-Host "  1. DISM component cleanup (irreversible) / Очистка компонентов DISM (необратимо)"
        Write-Host "  2. Paging file settings / Настройка файла подкачки"
        Write-Host "  3. Hibernation on/off / Гибернация вкл/выкл"
        Write-Host "  4. System Restore space / Размер точек восстановления"
        Write-Host "  5. WinSxS folder size / Размер папки WinSxS"
        Write-Host "  6. MAS Activation / Активатор MAS (GitHub)"
        Write-Host ""
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        switch ($choice) {
            "1" {
                Show-Header "DISM Cleanup"
                Write-Host "  This will permanently remove old update versions." -ForegroundColor Yellow
                Write-Host "  Это навсегда удалит старые версии обновлений." -ForegroundColor Yellow
                Write-Host "  You will NOT be able to uninstall recent updates afterwards."
                Write-Host "  После этого нельзя будет удалить недавние обновления."
                Write-Host ""
                Write-Host "  Y. Proceed / Продолжить    N. Cancel / Отмена"
                Write-Host ""
                $confirm = Read-Host "  >"
                if ($confirm.ToUpper() -eq "Y") {
                    Write-Host ""
                    Write-Host "  Running DISM cleanup... this may take several minutes." -ForegroundColor DarkGray
                    Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase
                    Write-Log "DISM ResetBase cleanup executed"
                    Write-Host ""
                    Write-Host "  Done." -ForegroundColor Green
                } else {
                    Write-Host "  Cancelled / Отменено." -ForegroundColor Yellow
                }
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "2" {
                Show-Header "Paging File"
                $cs = Get-CimInstance Win32_ComputerSystem
                $currentAuto = $cs.AutomaticManagedPagefile
                $pf = Get-CimInstance Win32_PageFileUsage -ErrorAction SilentlyContinue
                Write-Host "  Automatic management: $currentAuto"
                if ($pf) {
                    foreach ($p in $pf) {
                        Write-Host "  Current: $($p.Name), Allocated: $([math]::Round($p.AllocatedBaseSize/1024,2)) GB"
                    }
                }
                Write-Host ""
                Write-Host "  1. Set fixed size (recommended for SSD) / Задать фиксированный размер"
                Write-Host "  2. Reset to automatic / Вернуть автоматически"
                Write-Host "  0. $(L 'Back')"
                Write-Host ""
                $sub = Read-Host "  >"
                if ($sub -eq "1") {
                    $ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 0)
                    $suggested = [math]::Max(1024, $ramGB * 1024)
                    Write-Host "  Suggested size: $suggested MB (based on RAM). Enter size in MB:"
                    $sizeInput = Read-Host "  >"
                    $sizeMB = 0
                    if ([int]::TryParse($sizeInput, [ref]$sizeMB) -and $sizeMB -gt 0) {
                        $cs = Get-CimInstance Win32_ComputerSystem
                        $cs | Set-CimInstance -Property @{ AutomaticManagedPagefile = $false } -ErrorAction SilentlyContinue
                        $pfSetting = Get-CimInstance Win32_PageFileSetting -ErrorAction SilentlyContinue
                        if ($pfSetting) {
                            $pfSetting | Set-CimInstance -Property @{ InitialSize = $sizeMB; MaximumSize = $sizeMB } -ErrorAction SilentlyContinue
                        } else {
                            New-CimInstance -ClassName Win32_PageFileSetting -Property @{ Name = "C:\pagefile.sys"; InitialSize = $sizeMB; MaximumSize = $sizeMB } -ErrorAction SilentlyContinue | Out-Null
                        }
                        Write-Log "Pagefile set to fixed $sizeMB MB"
                        Write-Host "  Done. Restart required." -ForegroundColor Green
                    }
                } elseif ($sub -eq "2") {
                    $cs = Get-CimInstance Win32_ComputerSystem
                    $cs | Set-CimInstance -Property @{ AutomaticManagedPagefile = $true } -ErrorAction SilentlyContinue
                    Write-Log "Pagefile reset to automatic"
                    Write-Host "  Done. Restart required." -ForegroundColor Green
                }
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "3" {
                while ($true) {
                    Show-Header "Hibernation"
                    $hiberPath = "C:\hiberfil.sys"
                    $hiberExists = Test-Path $hiberPath
                    $mark = Get-ToggleMark -IsOn $hiberExists -OnIsBad $true
                    Write-Host ("  Hibernation file {0} {1}" -f $mark.Text, $mark.Note) -ForegroundColor $mark.Color
                    Write-Host "  (uses disk space equal to RAM size, mainly useful on laptops with Fast Startup)"
                    Write-Host "  (занимает место на диске равное объёму RAM, полезно на ноутбуках с быстрым запуском)"
                    Write-Host ""
                    Write-Host "  1. Toggle hibernation / Переключить гибернацию"
                    Write-Host "  0. $(L 'Back')"
                    Write-Host ""
                    $sub = Read-Host "  >"
                    if ($sub -eq "1") {
                        if ($hiberExists) {
                            powercfg /hibernate off
                            Write-Log "Hibernation disabled"
                        } else {
                            powercfg /hibernate on
                            Write-Log "Hibernation enabled"
                        }
                        Write-Host "  Done." -ForegroundColor Green
                        Start-Sleep -Milliseconds 800
                    } else {
                        break
                    }
                }
            }
            "4" {
                Show-Header "System Restore Space"
                try {
                    $srInfo = vssadmin list shadowstorage 2>&1
                    Write-Host "  $srInfo"
                } catch {
                    Write-Host "  Could not retrieve info. / Не удалось получить данные." -ForegroundColor Red
                }
                Write-Host ""
                Write-Host "  Set max usage to 5% of disk / Установить лимит 5% от диска: (Y/N)"
                $sub = Read-Host "  >"
                if ($sub.ToUpper() -eq "Y") {
                    vssadmin resize shadowstorage /for=C: /on=C: /maxsize=5% | Out-Null
                    Write-Log "System Restore space limited to 5%"
                    Write-Host "  Done." -ForegroundColor Green
                }
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "5" {
                Show-Header "WinSxS Folder Size"
                Write-Host "  Calculating... / Подсчёт... (may take a moment)" -ForegroundColor DarkGray
                $winSxSPath = "C:\Windows\WinSxS"
                if (Test-Path $winSxSPath) {
                    $size = (Get-ChildItem -Path $winSxSPath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
                    $sizeGB = [math]::Round($size / 1GB, 2)
                    Write-Host ""
                    Write-Host "  WinSxS size: $sizeGB GB"
                    Write-Host "  Use option 1 (DISM cleanup) to reduce this. / Используйте пункт 1 для уменьшения."
                } else {
                    Write-Host "  Folder not found. / Папка не найдена." -ForegroundColor Red
                }
                Write-Host ""
                Write-Host "  $(L 'PressEnter')"
                Read-Host | Out-Null
            }
            "6" { Show-MasActivation }
            "0" { return }
        }
    }
}

# =====================================================
#  РАЗДЕЛ R: REST / ОТДЫХ
# =====================================================
function Show-GuessNumberGame {
    Show-Header "Guess the Number"
    $target = Get-Random -Minimum 1 -Maximum 101
    $attempts = 0
    Write-Host "  I'm thinking of a number between 1 and 100."
    Write-Host "  Я загадал число от 1 до 100."
    Write-Host ""
    while ($true) {
        $guessInput = Read-Host "  Your guess"
        $guess = 0
        if (-not [int]::TryParse($guessInput, [ref]$guess)) {
            Write-Host "  Enter a number. / Введите число." -ForegroundColor Red
            continue
        }
        $attempts++
        if ($guess -eq $target) {
            Write-Host ""
            Write-Host "  Correct! You got it in $attempts attempts. / Правильно! Попыток: $attempts" -ForegroundColor Green
            break
        } elseif ($guess -lt $target) {
            Write-Host "  Higher! / Больше!" -ForegroundColor Yellow
        } else {
            Write-Host "  Lower! / Меньше!" -ForegroundColor Yellow
        }
    }
    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

function Show-SnakeGame {
    Show-Header "Snake"
    Write-Host "  Controls: W A S D, Q to quit"
    Write-Host "  Управление: W A S D, Q для выхода"
    Write-Host ""
    Write-Host "  Press any key to start... / Нажмите любую клавишу для старта..."
    [System.Console]::ReadKey($true) | Out-Null

    $width = 20
    $height = 12
    $snake = [System.Collections.Generic.List[object]]::new()
    $snake.Add(@{X=5; Y=5})
    $dir = "D"
    $food = @{ X = Get-Random -Minimum 0 -Maximum $width; Y = Get-Random -Minimum 0 -Maximum $height }
    $score = 0
    $gameOver = $false
    $consoleTop = [Console]::CursorTop

    while (-not $gameOver) {
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true).Key
            switch ($key) {
                "W" { if ($dir -ne "S") { $dir = "W" } }
                "S" { if ($dir -ne "W") { $dir = "S" } }
                "A" { if ($dir -ne "D") { $dir = "A" } }
                "D" { if ($dir -ne "A") { $dir = "D" } }
                "Q" { $gameOver = $true }
            }
        }

        $head = $snake[0]
        $newHead = @{ X = $head.X; Y = $head.Y }
        switch ($dir) {
            "W" { $newHead.Y-- }
            "S" { $newHead.Y++ }
            "A" { $newHead.X-- }
            "D" { $newHead.X++ }
        }

        if ($newHead.X -lt 0 -or $newHead.X -ge $width -or $newHead.Y -lt 0 -or $newHead.Y -ge $height) {
            $gameOver = $true
            break
        }
        foreach ($seg in $snake) {
            if ($seg.X -eq $newHead.X -and $seg.Y -eq $newHead.Y) {
                $gameOver = $true
                break
            }
        }
        if ($gameOver) { break }

        $snake.Insert(0, $newHead)
        if ($newHead.X -eq $food.X -and $newHead.Y -eq $food.Y) {
            $score++
            $food = @{ X = Get-Random -Minimum 0 -Maximum $width; Y = Get-Random -Minimum 0 -Maximum $height }
        } else {
            $snake.RemoveAt($snake.Count - 1)
        }

        [Console]::SetCursorPosition(0, $consoleTop)
        $sb = New-Object System.Text.StringBuilder
        [void]$sb.AppendLine("  Score: $score   (W A S D to move, Q to quit)")
        [void]$sb.AppendLine("  +" + ("-" * $width) + "+")
        for ($y = 0; $y -lt $height; $y++) {
            [void]$sb.Append("  |")
            for ($x = 0; $x -lt $width; $x++) {
                $isSnake = $false
                foreach ($seg in $snake) {
                    if ($seg.X -eq $x -and $seg.Y -eq $y) { $isSnake = $true; break }
                }
                if ($isSnake) {
                    [void]$sb.Append("█")
                } elseif ($food.X -eq $x -and $food.Y -eq $y) {
                    [void]$sb.Append("*")
                } else {
                    [void]$sb.Append(" ")
                }
            }
            [void]$sb.AppendLine("|")
        }
        [void]$sb.AppendLine("  +" + ("-" * $width) + "+")
        Write-Host $sb.ToString()

        Start-Sleep -Milliseconds 150
    }

    Write-Host ""
    Write-Host "  Game Over! Final score: $score / Игра окончена! Счёт: $score" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

function Show-RestMenu {
    while ($true) {
        Show-Header "Rest / Отдых"
        Write-Host "  1. Guess the Number / Угадай число"
        Write-Host "  2. Snake / Змейка"
        Write-Host ""
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        switch ($choice) {
            "1" { Show-GuessNumberGame }
            "2" { Show-SnakeGame }
            "0" { return }
        }
    }
}

# =====================================================
#  РАЗДЕЛ T: TESTS & DIAGNOSTICS / ТЕСТЫ И ДИАГНОСТИКА
# =====================================================

function Ensure-Fastfetch {
    $exePath = Join-Path $ScriptDir "fastfetch.exe"
    if (Test-Path $exePath) { return $exePath }

    Show-Header "Fastfetch"
    Write-Host "  Fastfetch is not found and needs to be downloaded."
    Write-Host "  Fastfetch не найден и требует скачивания."
    Write-Host ""
    Write-Host "  Official source: https://github.com/fastfetch-cli/fastfetch" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Download now? / Скачать сейчас? (Y/N)"
    $confirm = Read-Host "  >"
    if ($confirm.ToUpper() -ne "Y") { return $null }

    $url = "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-windows-amd64.zip"
    $zipPath = Join-Path $ScriptDir "fastfetch_tmp.zip"
    $extractPath = Join-Path $ScriptDir "fastfetch_tmp"

    try {
        Write-Host ""
        Write-Host "  Downloading... / Скачивание..." -ForegroundColor DarkGray
        Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
        $found = Get-ChildItem -Path $extractPath -Filter "fastfetch.exe" -Recurse | Select-Object -First 1
        if ($found) {
            Copy-Item -Path $found.FullName -Destination $exePath -Force
        }
        Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Fastfetch downloaded from official source"
        Write-Host "  Done." -ForegroundColor Green
        Start-Sleep -Seconds 1
        return $exePath
    } catch {
        Write-Host "  Download failed. / Скачивание не удалось." -ForegroundColor Red
        Start-Sleep -Seconds 2
        return $null
    }
}

function Show-FastfetchTool {
    $exePath = Ensure-Fastfetch
    if (-not $exePath) { return }

    Show-Header "Fastfetch"
    & $exePath

    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

function Ensure-Smartctl {
    $exePath = Join-Path $ScriptDir "smartctl.exe"
    if (Test-Path $exePath) { return $exePath }

    Show-Header "Smartmontools"
    Write-Host "  Smartctl is not found and needs to be downloaded."
    Write-Host "  Smartctl не найден и требует скачивания."
    Write-Host ""
    Write-Host "  Official source: https://www.smartmontools.org" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Download now? / Скачать сейчас? (Y/N)"
    $confirm = Read-Host "  >"
    if ($confirm.ToUpper() -ne "Y") { return $null }

    $url = "https://sourceforge.net/projects/smartmontools/files/latest/download"
    $installerPath = Join-Path $ScriptDir "smartmontools_setup.exe"
    $installDir = Join-Path $ScriptDir "smartmontools_tmp"

    try {
        Write-Host ""
        Write-Host "  Downloading... / Скачивание..." -ForegroundColor DarkGray
        Invoke-WebRequest -Uri $url -OutFile $installerPath -UseBasicParsing

        Write-Host "  Installing silently... / Тихая установка..." -ForegroundColor DarkGray
        Start-Process -FilePath $installerPath -ArgumentList "/S", "/D=$installDir" -Wait

        $found = Get-ChildItem -Path $installDir -Filter "smartctl.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            Copy-Item -Path $found.FullName -Destination $exePath -Force
        }
        Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $installDir -Recurse -Force -ErrorAction SilentlyContinue

        if (Test-Path $exePath) {
            Write-Log "Smartctl downloaded from official source"
            Write-Host "  Done." -ForegroundColor Green
            Start-Sleep -Seconds 1
            return $exePath
        } else {
            Write-Host "  Installation did not produce smartctl.exe. / Установка не дала smartctl.exe." -ForegroundColor Red
            return $null
        }
    } catch {
        Write-Host "  Download/install failed. / Скачивание/установка не удались." -ForegroundColor Red
        Start-Sleep -Seconds 2
        return $null
    }
}

function Show-SmartctlTool {
    $exePath = Ensure-Smartctl
    if (-not $exePath) { return }

    Show-Header "Smartctl - Scan"
    Write-Host "  Scanning devices... / Сканирование устройств..." -ForegroundColor DarkGray
    Write-Host ""
    $scanOutput = & $exePath --scan 2>&1
    $scanOutput | ForEach-Object { Write-Host "  $_" }
    Write-Host ""

    $devices = @()
    foreach ($line in $scanOutput) {
        if ($line -match "^(\S+)\s+-d") {
            $devices += $matches[1]
        }
    }

    if ($devices.Count -eq 0) {
        Write-Host "  No devices found. / Устройства не найдены." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  $(L 'PressEnter')"
        Read-Host | Out-Null
        return
    }

    Write-Host "  Select device for full report / Выберите устройство для отчёта:"
    for ($i = 0; $i -lt $devices.Count; $i++) {
        Write-Host "  $($i+1). $($devices[$i])"
    }
    Write-Host "  0. $(L 'Back')"
    Write-Host ""
    $choice = Read-Host "  >"
    $index = 0
    if ([int]::TryParse($choice, [ref]$index) -and $index -ge 1 -and $index -le $devices.Count) {
        Show-Header "Smartctl - Full Report"
        & $exePath -a $devices[$index - 1]
    }
    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

function Ensure-SysinternalsTool {
    param([string]$ToolName)
    $exePath = Join-Path $ScriptDir "$ToolName.exe"
    if (Test-Path $exePath) { return $exePath }

    Show-Header $ToolName
    Write-Host "  $ToolName is not found and needs to be downloaded."
    Write-Host "  $ToolName не найден и требует скачивания."
    Write-Host ""
    Write-Host "  Official source: https://live.sysinternals.com" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Download now? / Скачать сейчас? (Y/N)"
    $confirm = Read-Host "  >"
    if ($confirm.ToUpper() -ne "Y") { return $null }

    $url = "https://live.sysinternals.com/$ToolName.exe"
    try {
        Write-Host ""
        Write-Host "  Downloading... / Скачивание..." -ForegroundColor DarkGray
        Invoke-WebRequest -Uri $url -OutFile $exePath -UseBasicParsing
        Write-Log "$ToolName downloaded from official source"
        Write-Host "  Done." -ForegroundColor Green
        Start-Sleep -Seconds 1
        return $exePath
    } catch {
        Write-Host "  Download failed. / Скачивание не удалось." -ForegroundColor Red
        Start-Sleep -Seconds 2
        return $null
    }
}

function Show-AutorunscTool {
    $exePath = Ensure-SysinternalsTool -ToolName "autorunsc64"
    if (-not $exePath) { return }

    Show-Header "Autorunsc - Third-party autostart"
    Write-Host "  Scanning autostart locations (non-Microsoft only)..." -ForegroundColor DarkGray
    Write-Host "  Сканирование мест автозапуска (только сторонние)..." -ForegroundColor DarkGray
    Write-Host ""
    & $exePath -accepteula -m -nobanner

    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

function Show-HandleTool {
    $exePath = Ensure-SysinternalsTool -ToolName "handle64"
    if (-not $exePath) { return }

    Show-Header "Handle - Find locked file"
    Write-Host "  Enter file/folder name or path to search (partial match works):"
    Write-Host "  Введите имя файла/папки или путь для поиска (частичное совпадение подходит):"
    $searchTerm = Read-Host "  >"
    if ([string]::IsNullOrWhiteSpace($searchTerm)) { return }

    Show-Header "Handle - Results"
    & $exePath -accepteula -nobanner $searchTerm

    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

function Show-AccesschkTool {
    $exePath = Ensure-SysinternalsTool -ToolName "accesschk64"
    if (-not $exePath) { return }

    Show-Header "AccessChk - Security Audit"
    Write-Host "  1. Check C:\Windows permissions / Проверить права C:\Windows"
    Write-Host "  2. Check a specific service / Проверить конкретную службу"
    Write-Host "  0. $(L 'Back')"
    Write-Host ""
    $choice = Read-Host "  >"
    switch ($choice) {
        "1" {
            Show-Header "AccessChk - C:\Windows"
            & $exePath -accepteula -nobanner -s -w "C:\Windows" 2>&1 | Select-Object -First 60
        }
        "2" {
            $svcName = Read-Host "  Service name / Имя службы"
            if (-not [string]::IsNullOrWhiteSpace($svcName)) {
                Show-Header "AccessChk - Service: $svcName"
                & $exePath -accepteula -nobanner -c $svcName
            }
        }
        default { return }
    }
    Write-Host ""
    Write-Host "  $(L 'PressEnter')"
    Read-Host | Out-Null
}

function Show-DiagnosticsMenu {
    while ($true) {
        Show-Header "Tests & Diagnostics"
        Write-Host "  1. System overview (Fastfetch) / Обзор системы"
        Write-Host "  2. Deep SMART analysis (Smartctl) / Глубокий анализ SMART"
        Write-Host "  3. Third-party autostart scan (Autorunsc) / Скан стороннего автозапуска"
        Write-Host "  4. Find locked file (Handle) / Найти блокировку файла"
        Write-Host "  5. Security audit (AccessChk) / Аудит прав доступа"
        Write-Host ""
        Write-Host "  0. $(L 'Back')"
        Write-Host ""
        $choice = Read-Host "  >"
        switch ($choice) {
            "1" { Show-FastfetchTool }
            "2" { Show-SmartctlTool }
            "3" { Show-AutorunscTool }
            "4" { Show-HandleTool }
            "5" { Show-AccesschkTool }
            "0" { return }
        }
    }
}

# =====================================================
#  ТОЧКА ВХОДА
# =====================================================
Test-WindowsVersion
Load-Config

if ($Global:Config.FirstRun) {
    Show-ResponsibilityDisclaimer
    Show-Welcome
    Show-ArchSelect
    $Global:Config.FirstRun = $false
    Save-Config
}

Write-Log "Session started"
Show-MainMenu
