REM Authored by Ethan Blair MAR-16-2026
@echo off
REM Deletes LanSchool reporting CSV files.

set "SharePath=\\fileserver\share\LanSchoolReporting"

del "%SharePath%\Manual_Touch.csv" /f /q
del "%SharePath%\Uninstall_Success.csv" /f /q
del "%SharePath%\Final_Reinstall_Collection.csv" /f /q

echo Reporting CSV files deleted.
exit /b 0
