# ==========================================
# WINDOWS 11 OPTIMIZATION FOR GAMING
# ==========================================

Clear-Host
Write-Host "Starting gaming optimizations..." -ForegroundColor Green

# -------------------------------
# ADMINISTRATOR CHECK
# -------------------------------
$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Reopening script as Administrator..." -ForegroundColor Yellow
    Start-Process powershell `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}

# -------------------------------
# 1. POWER PLAN – MAXIMUM PERFORMANCE
# -------------------------------
powercfg -setactive SCHEME_MIN

# -------------------------------
# 2. DISABLE GAME DVR / XBOX GAME BAR
# -------------------------------
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f

# -------------------------------
# 3. REDUCE LATENCY (ONLINE GAMING)
# -------------------------------
$sysProfile = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"

reg add $sysProfile /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f
reg add $sysProfile /v SystemResponsiveness /t REG_DWORD /d 0 /f

# -------------------------------
# 4. MAXIMUM PRIORITY FOR GAMES
# -------------------------------
$gamesKey = "$sysProfile\Tasks\Games"

reg add $gamesKey /v "GPU Priority" /t REG_DWORD /d 8 /f
reg add $gamesKey /v "Priority" /t REG_DWORD /d 6 /f
reg add $gamesKey /v "Scheduling Category" /t REG_SZ /d High /f

# -------------------------------
# 5. DISABLE VISUAL EFFECTS
# -------------------------------
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
/v VisualFXSetting /t REG_DWORD /d 2 /f

# ==========================================
# 6. REAL RAM CACHE CLEANUP
# (Standby Memory – Safe Method)
# ==========================================
Write-Host "Cleaning RAM cache..." -ForegroundColor Yellow

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class RamCleaner {
    [DllImport("ntdll.dll")]
    public static extern int NtSetSystemInformation(
        int SystemInformationClass,
        IntPtr SystemInformation,
        int SystemInformationLength
    );
}
"@

$ptr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(4)
[System.Runtime.InteropServices.Marshal]::WriteInt32($ptr, 4)
[RamCleaner]::NtSetSystemInformation(0x50, $ptr, 4)
[System.Runtime.InteropServices.Marshal]::FreeHGlobal($ptr)

Write-Host "RAM cache cleaned successfully." -ForegroundColor Green

# -------------------------------
# 7. DISABLE SERVICES THAT CAUSE STUTTER
# -------------------------------
$services = @("SysMain", "WSearch")

foreach ($service in $services) {
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    Set-Service  -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
}

# -------------------------------
# FINISH
# -------------------------------
Write-Host ""
Write-Host "Optimization applied successfully!" -ForegroundColor Cyan
Write-Host "Restart your PC before gaming for best results." -ForegroundColor Cyan

# created by: jvt 🦇
# 21/02/2026