rem
rem ref: https://stackoverflow.com/questions/26324486/properly-installing-java-8-along-with-java-7
rem

@echo off
if "%1"=="" goto report
set _version=%1
shift
if "%1"=="DBG" shift & echo on
set _command=%1 %2 %3 %4 %5

set _jdkdir=
set _jdkver=
for /D %%f in ("C:\Program Files\java\"jdk1.%_version%.*) do call :found "%%f"
if "%_jdkdir%"=="" goto notfound

set java_home=C:\Program Files\java\%_jdkdir%
call :javapath
path %new_path%
goto :report

:javapath
    setlocal enabledelayedexpansion
    set _jdirs=
    for /D %%j in ("C:\Program Files\java\*") do set _jdirs=!_jdirs!#%%~fj\bin
    set _jdirs=%_jdirs%#

    set _javabin=%java_home%\bin
    set _fpath="%PATH:;=" "%"
    call :checkpath %_fpath%
    endlocal & set new_path=%_javabin%
goto :eof

:checkpath
    if _%1==_ goto :eof
    echo %_jdirs% | find /i "#%~1#" 1>nul 2>&1
    set _err=%errorlevel%
    if not %_err%==0 set _javabin=%_javabin%;%~1
    if %_err%==0 echo Removed %~1 from path
    shift
    goto :checkpath

:report
javac -version
%_command%
goto :eof

:notfound
echo No JDK matching [C:\Program Files\java\jdk1.%_version%.*] found.
goto :eof

:found
set _jdkdir=%~n1%~x1
for /F "tokens=2,3 delims=." %%a in ("%_jdkdir%") do set _jdkver=1.%%a.%%b
goto :eof
