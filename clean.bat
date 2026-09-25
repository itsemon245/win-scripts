@echo off
setlocal EnableDelayedExpansion

:: Check for administrative privileges
net session >nul 2>&1
if !errorLevel! == 0 (
    echo [RUNNING AS ADMIN]
) else (
    echo [ERROR: PLEASE RUN AS ADMINISTRATOR]
    pause
    exit /b
)

echo ---------------------------------------------------------
echo WINDOWS POWER-USER CLEANUP SCRIPT (46GB SSD OPTIMIZED)
echo ---------------------------------------------------------

:: Capture initial free space on C: (in bytes)
for /f %%i in ('powershell -NoProfile -Command "(Get-PSDrive C).Free"') do set "BEFORE_BYTES=%%i"

:: Display initial space before starting
powershell -NoProfile -Command "$b=[int64]$env:BEFORE_BYTES; function fmt($v){$a=[math]::Abs($v); if($a -ge 1TB){'{0:N2} TB' -f ($v/1TB)} elseif($a -ge 1GB){'{0:N2} GB' -f ($v/1GB)} elseif($a -ge 1MB){'{0:N2} MB' -f ($v/1MB)} else{'{0:N2} KB' -f ($v/1KB)}}; Write-Host 'Initial Free Space: ' -NoNewline; Write-Host ('{0:N0} bytes ' -f $b) -NoNewline; Write-Host ('[ ' + (fmt $b) + ' ]') -ForegroundColor Cyan"
echo ---------------------------------------------------------

:: 1. Stop Windows Update Services (to clear the cache)
echo Stopping Update Services...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1

:: 2. Clear Windows Update Cache & Delivery Optimization
echo Clearing Update Cache...
del /f /q /s %windir%\SoftwareDistribution\Download\*.* >nul 2>&1
del /f /q /s %windir%\temp\*.* >nul 2>&1

:: 3. Clear Delivery Optimization Files
echo Clearing Delivery Optimization...
powershell.exe -Command "Get-DeliveryOptimizationStatus | Remove-DeliveryOptimizationObject -Force" >nul 2>&1

:: 4. Restart Update Services
echo Restarting Update Services...
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

:: 5. Clear User Temp Files, Prefetch, and Logs
echo Clearing Temp Files and Prefetch...
rd /s /q "%temp%" >nul 2>&1
mkdir "%temp%" >nul 2>&1
del /f /q /s %systemroot%\Prefetch\*.* >nul 2>&1
del /f /q /s "%systemroot%\DirectX Shader Cache\*.*" >nul 2>&1

:: 6. Clear CBS and DISM Logs (Developer Bloat)
echo Clearing System Logs...
del /f /q /s %windir%\Logs\CBS\*.* >nul 2>&1
del /f /q /s %windir%\Logs\DISM\*.* >nul 2>&1

:: 7. Run DISM Component Cleanup (Safe version)
echo Running DISM Component Cleanup...
dism /online /cleanup-image /startcomponentcleanup /quiet

:: 8. Run Disk Cleanup (Interactive config check + Silent run)
echo ---------------------------------------------------------
echo Checking Disk Cleanup configuration...

:: Check registry to see if preset #1 has ever been configured
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches" /s /f "StateFlags0001" >nul 2>&1
if !errorLevel! neq 0 (
    echo [!] First-time setup: Disk Cleanup preset #1 is not yet configured.
    echo     Opening settings window...
    echo     Please check the items you want cleaned and click OK.
    echo.
    start "" /wait cleanmgr /sageset:1
) else (
    echo Disk Cleanup preset #1 is already configured.
    choice /c YN /t 3 /d N /m "Do you want to review or modify your cleanup selections?"
    if !errorLevel! equ 1 (
        start "" /wait cleanmgr /sageset:1
    )
)

echo Running Built-in Disk Cleanup with preset #1...
start "" /wait cleanmgr /sagerun:1
echo ---------------------------------------------------------

:: 9. Empty Recycle Bin
echo Emptying Recycle Bin...
powershell.exe -Command "$rb = New-Object -ComObject Shell.Application; $rb.NameSpace(0x0a).Items() | ForEach-Object { Remove-Item $_.Path -Recurse -Force }" >nul 2>&1

echo ---------------------------------------------------------
echo CLEANUP COMPLETE!
echo ---------------------------------------------------------

:: Calculate and display Before, After, and Reclaimed Space
powershell -NoProfile -Command ^
    "$before = if ($env:BEFORE_BYTES) { [int64]$env:BEFORE_BYTES } else { 0 }; " ^
    "$after  = [int64](Get-PSDrive C).Free; " ^
    "$diff   = $after - $before; " ^
    "function fmt($v) { " ^
    "    $a = [math]::Abs($v); " ^
    "    if ($a -ge 1TB) { '{0:N2} TB' -f ($v / 1TB) } " ^
    "    elseif ($a -ge 1GB) { '{0:N2} GB' -f ($v / 1GB) } " ^
    "    elseif ($a -ge 1MB) { '{0:N2} MB' -f ($v / 1MB) } " ^
    "    else { '{0:N2} KB' -f ($v / 1KB) } " ^
    "} " ^
    "Write-Host 'Before Cleanup  : ' -NoNewline; " ^
    "Write-Host ('{0,15:N0} bytes  ' -f $before) -NoNewline; " ^
    "Write-Host ('[ ' + (fmt $before) + ' ]') -ForegroundColor Cyan; " ^
    "Write-Host 'After Cleanup   : ' -NoNewline; " ^
    "Write-Host ('{0,15:N0} bytes  ' -f $after) -NoNewline; " ^
    "Write-Host ('[ ' + (fmt $after) + ' ]') -ForegroundColor Cyan; " ^
    "Write-Host '---------------------------------------------------------'; " ^
    "Write-Host 'Space Reclaimed : ' -NoNewline; " ^
    "Write-Host ('{0,15:N0} bytes  ' -f $diff) -NoNewline; " ^
    "if ($diff -gt 0) { " ^
    "    Write-Host ('[ +' + (fmt $diff) + ' ]') -ForegroundColor Green; " ^
    "} elseif ($diff -eq 0) { " ^
    "    Write-Host '[ 0.00 MB ]' -ForegroundColor Yellow; " ^
    "} else { " ^
    "    Write-Host ('[ ' + (fmt $diff) + ' ]') -ForegroundColor Red; " ^
    "}"

echo ---------------------------------------------------------
pause