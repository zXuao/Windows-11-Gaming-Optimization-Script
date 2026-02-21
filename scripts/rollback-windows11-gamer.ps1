# ==========================================
# FULL ROLLBACK – WINDOWS 11 GAMING TWEAKS
# ==========================================

Clear-Host
Write-Host "Starting rollback of gaming optimizations..." -ForegroundColor Yellow

# -------------------------------
# ADMINISTRATOR CHECK
# -------------------------------
$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Reopening rollback as Administrator..." -ForegroundColor Yellow
    Start-Process powershell `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}

# -------------------------------
# 1. DEFAULT POWER PLAN (BALANCED)
# -------------------------------
powercfg -setactive SCHEME_BALANCED

# -------------------------------
# 2. RE-ENABLE GAME DVR / XBOX GAME BAR
# -------------------------------
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 1 /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /f

# -------------------------------
# 3. RESTORE MULTIMEDIA SYSTEM PROFILE
# -------------------------------
$sysProfile = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"

reg delete $sysProfile /v NetworkThrottlingIndex /f
reg delete $sysProfile /v SystemResponsiveness /f

# -------------------------------
# 4. REMOVE GAME PRIORITY SETTINGS
# -------------------------------
$gamesKey = "$sysProfile\Tasks\Games"

reg delete $gamesKey /v "GPU Priority" /f
reg delete $gamesKey /v "Priority" /f
reg delete $gamesKey /v "Scheduling Category" /f

# -------------------------------
# 5. RESTORE VISUAL EFFECTS
# -------------------------------
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
/v VisualFXSetting /t REG_DWORD /d 1 /f

# -------------------------------
# 6. RE-ENABLE DEFAULT SERVICES
# -------------------------------
$services = @(
    @{ Name = "SysMain"; Startup = "Automatic" },
    @{ Name = "WSearch"; Startup = "Automatic" }
)

foreach ($s in $services) {
    Set-Service -Name $s.Name -StartupType $s.Startup -ErrorAction SilentlyContinue
    Start-Service -Name $s.Name -ErrorAction SilentlyContinue
}

# -------------------------------
# FINISH
# -------------------------------
Write-Host ""
Write-Host "Rollback completed successfully!" -ForegroundColor Green
Write-Host "Restart your PC to finish restoring default settings." -ForegroundColor Cyan

# created by: jvt 🦇
# 21/02/2026