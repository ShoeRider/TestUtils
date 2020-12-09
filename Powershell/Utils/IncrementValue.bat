:: USE:
::    IncrementINIValue.bat Manifest.ini Version Revision
@echo off
set file=%~1
set section=%~2
set key=%~3

FOR /F %%I IN ('%~dp0SearchINI.bat %file% %section% %key%') DO set Value=%%I
set /A Value=%Value%+1
echo "Continue?"
%~dp0SetINI.bat %file% %section% %key% %Value%
echo "Continue?"
pause
