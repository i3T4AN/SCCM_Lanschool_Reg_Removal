REM Authored by Ethan Blair MAR-16-2026
@echo off
REM Reports devices based on whether LanSchool registry removal was successful. (Make sure to scope to a collection made from devices listed in your Uninstall_Success.csv report.)

set "SharePath=\\fileserver\share\LanSchoolReporting"
set "SuccessOutput=%SharePath%\Final_Reinstall_Collection.csv"
set "ManualTouchOutput=%SharePath%\Manual_Touch.csv"
set "RegPath1=HKLM\SOFTWARE\Classes\Installer\Products\BABAE78ECF4207D47A4E62323550704A"
set "RegPath2=HKCU\SOFTWARE\Classes\Installer\Products\BABAE78ECF4207D47A4E62323550704A"
set "RegPath3=HKLM\SOFTWARE\LanSchool"
set "RegPath4=HKLM\SOFTWARE\WOW6432Node\LanSchool"
set "FailLocation=Registry Removal"

REM Gather device info
set "ComputerName=%COMPUTERNAME%"

for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-CimInstance Win32_BIOS).SerialNumber"') do set "SerialNumber=%%A"
if not defined SerialNumber set "SerialNumber=Unknown"

for /f "delims=" %%A in ('powershell -NoProfile -Command "Get-Date -Format \"yyyy-MM-dd HH:mm:ss\""') do set "ReportDate=%%A"

REM Check if registry key still exists
set "RegFound=0"
reg query "%RegPath1%" /reg:64 >nul 2>&1 && set "RegFound=1"
reg query "%RegPath2%" /reg:64 >nul 2>&1 && set "RegFound=1"
reg query "%RegPath3%" /reg:64 >nul 2>&1 && set "RegFound=1"
reg query "%RegPath3%" /reg:32 >nul 2>&1 && set "RegFound=1"
reg query "%RegPath4%" /reg:64 >nul 2>&1 && set "RegFound=1"
reg query "%RegPath4%" /reg:32 >nul 2>&1 && set "RegFound=1"

REM If registry key does not exist, write to Final_Reinstall_Collection.csv
if "%RegFound%"=="0" (
    if not exist "%SuccessOutput%" (
        > "%SuccessOutput%" echo Date,ComputerName,SerialNumber
    )
    >> "%SuccessOutput%" echo %ReportDate%,%ComputerName%,%SerialNumber%
    exit /b 0
)

REM If registry key still exists, write to Manual_Touch.csv
if not exist "%ManualTouchOutput%" (
    > "%ManualTouchOutput%" echo Date,ComputerName,SerialNumber,FailLocation
)
>> "%ManualTouchOutput%" echo %ReportDate%,%ComputerName%,%SerialNumber%,%FailLocation%

exit /b 0
