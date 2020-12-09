:: https://stackoverflow.com/questions/2866117/windows-batch-script-to-read-an-ini-file
:: Edited By AMS: Shoerider
:: USE:
::    SetINI.bat ./Manifest.ini Version Revision 4
@setlocal enableextensions enabledelayedexpansion
@echo off
set file=%~1
set area=[%~2]
set key=%~3
set value=%~4
set section=

echo. > Temp.ini
del Temp.ini
:: For Each Line within the provided file
for /f "usebackq delims=" %%a in ("!file!") do (
    set line=%%a
    if "x!line:~0,1!"=="x[" (
        set section=!line!
        echo !line!>>./Temp.ini
    ) else (
        for /f "tokens=1,2 delims==" %%b in ("!line!") do (
            set currkey=%%b
            set currval=%%c
            if "x!area!"=="x!section!" (
              if "x!key!"=="x!currkey!" (
        	         echo !currkey!=!value!>>./Temp.ini
                ) else (
        	         echo !line!>>./Temp.ini
                )
              ) else (
                 echo !line!>>./Temp.ini
              )

        )
    )

)
del %file%

call :file_name_from_path Name !file!
call :file_name_from_path result !file!

ren Temp.ini %Name%
move %Name% !file!

goto eof

:Get_path <resultVar> <pathVar>
(
    set "%~1=%~dp2"

)
::exit /b
:file_name_from_path <resultVar> <pathVar>
(
    set "%~1=%~nx2"

)

:eof
pause
endlocal
