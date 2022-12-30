@echo off
::
:: Copyright (c) 2022 Robert Di Pardo, MIT License
::
SETLOCAL

set "VERSION=0.1.1.1-pre"
set "PLUGIN=NPPFSIPlugin"
set "BIN_DIR=.\Source\Plugin\Bin"
set "PLUGIN_DLL=%BIN_DIR%\i386-win32\Release\%PLUGIN%.dll"
set "PLUGINX64_DLL=%BIN_DIR%\x86_64-win64\Release\%PLUGIN%.dll"
set "SLUGX64_NAME=%BIN_DIR%\%PLUGIN%_v%VERSION%_x64"
set "SLUG_NAME=%BIN_DIR%\%PLUGIN%_v%VERSION%_win32"
set "SLUGX64_NAME=%BIN_DIR%\%PLUGIN%_v%VERSION%_x64"
set "SLUG=%SLUG_NAME%.zip"
set "SLUGX64=%SLUGX64_NAME%.zip"
set "DOCS=.\%BIN_DIR%\Doc"

del /S /Q /F %BIN_DIR%\*.zip 2>NUL:
xcopy /DIY *.txt %DOCS%
xcopy /DIY README* %DOCS%
7z a -tzip "%SLUG%" "%PLUGIN_DLL%" %DOCS% -y
7z a -tzip "%SLUGX64%" "%PLUGINX64_DLL%" %DOCS% -y

ENDLOCAL
