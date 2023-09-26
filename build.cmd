@echo off
::
:: Copyright (c) 2023 Robert Di Pardo, MIT License
::
SETLOCAL

set "FPC_BUILD_TYPE=Debug"
set "FPC_CPU=x86_64"
set "PROJ_DIR=.\Source\Plugin"
set "BIN_DIR=%PROJ_DIR%\Bin"

if "%1" NEQ "" ( set "FPC_BUILD_TYPE=%1" )
if "%2" NEQ "" ( set "FPC_CPU=%2" )
call :%FPC_BUILD_TYPE% 2>NUL:
if %errorlevel%==1 ( goto :USAGE )

:Release
del /S /Q /F %BIN_DIR%\*.zip 2>NUL:

:Debug
set "BUILD_ALL="
if "%3"=="clean" (
  rmdir /S /Q %BIN_DIR% 2>NUL:
  set "BUILD_ALL=-B"
)

pushd %PROJ_DIR%
lazbuild %BUILD_ALL% --bm=%FPC_BUILD_TYPE% --cpu=%FPC_CPU% NPPFSIPlugin.lpi
popd
goto :END

:USAGE
echo Usage: ".\%~n0 [Debug,Release] [i386,x86_64] [clean]"

:END
exit /B %errorlevel%

ENDLOCAL
