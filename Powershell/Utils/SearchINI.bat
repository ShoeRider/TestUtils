:: Copied from: https://stackoverflow.com/questions/2866117/windows-batch-script-to-read-an-ini-file
:: USE:
::    SearchINI.bat ./Manifest.ini Version Revision
@setlocal enableextensions enabledelayedexpansion
@echo off
set file=%~1
set area=[%~2]
set key=%~3
set section=

for /f "usebackq delims=" %%a in ("!file!") do (
    set line=%%a

    if "x!line:~0,1!"=="x[" (
        set section=!line!
    ) else (
        for /f "tokens=1,2 delims==" %%b in ("!line!") do (
            set currkey=%%b
            set currval=%%c
            if "x!area!"=="x!section!" if "x!key!"=="x!currkey!" (
                echo !currval!
            )
        )
    )
)
endlocal
