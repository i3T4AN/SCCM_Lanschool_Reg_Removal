REM Authored by Ethan Blair OCT-20-2025
REM Modified by Ethan Blair MAR-16-2026
REM Deletes LanSchool and Installer registry keys. (Make sure to scope to a collection made from devices listed in your Uninstall_Success.csv report.)

@echo off

reg delete "HKLM\SOFTWARE\Classes\Installer\Products\BABAE78ECF4207D47A4E62323550704A" /f /reg:64
reg delete "HKCU\SOFTWARE\Classes\Installer\Products\BABAE78ECF4207D47A4E62323550704A" /f /reg:64

reg delete "HKLM\SOFTWARE\LanSchool" /f /reg:64
reg delete "HKLM\SOFTWARE\WOW6432Node\LanSchool" /f /reg:64
reg delete "HKLM\SOFTWARE\LanSchool" /f /reg:32
reg delete "HKLM\SOFTWARE\WOW6432Node\LanSchool" /f /reg:32

echo Registry keys deleted.
exit /b 0
