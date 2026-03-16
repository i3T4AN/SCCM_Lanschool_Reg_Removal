REM Authored by Ethan Blair MAR-16-2026
@echo off
REM Reports devices based on whether LanSchool artifacts are present after uninstallation.

set "SharePath=\\fileserver\share\LanSchoolReporting"
set "InstalledOutput=%SharePath%\Manual_Touch.csv"
set "UninstallOutput=%SharePath%\Uninstall_Success.csv"
set "StudentPath=C:\Program Files (x86)\LanSchool\Student.exe"
set "TeacherPath=C:\Program Files (x86)\LanSchool\Teacher.exe"
set "FailLocation=LanSchool App Uninstall"

REM Check both locations independently (teacher install location and student.)
set "LanSchoolFound=0"
if exist "%StudentPath%" set "LanSchoolFound=1"
if exist "%TeacherPath%" set "LanSchoolFound=1"

REM Gather device info
set "ComputerName=%COMPUTERNAME%"

for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-CimInstance Win32_BIOS).SerialNumber"') do set "SerialNumber=%%A"
if not defined SerialNumber set "SerialNumber=Unknown"

for /f "delims=" %%A in ('powershell -NoProfile -Command "Get-Date -Format \"yyyy-MM-dd HH:mm:ss\""') do set "ReportDate=%%A"

REM If installed, write to Manual_Touch.csv
if "%LanSchoolFound%"=="1" (
    if not exist "%InstalledOutput%" (
        > "%InstalledOutput%" echo Date,ComputerName,SerialNumber,FailLocation
    )
    >> "%InstalledOutput%" echo %ReportDate%,%ComputerName%,%SerialNumber%,%FailLocation%
    exit /b 0
)

REM If not installed, write to Uninstall_Success.csv
if not exist "%UninstallOutput%" (
    > "%UninstallOutput%" echo Date,ComputerName,SerialNumber
)
>> "%UninstallOutput%" echo %ReportDate%,%ComputerName%,%SerialNumber%

exit /b 0
