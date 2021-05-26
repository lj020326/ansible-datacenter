@echo off
SETLOCAL
SET PYTHON=c:\apps\python27\python-2.7.13.amd64\python
SET METEOR_INSTALLATION=%~dp0%
"%~dp0\packages\meteor-tool\1.6.1_1\mt-os.windows.x86_64\meteor.bat" %*
ENDLOCAL
EXIT /b %ERRORLEVEL%
rem %~dp0\packages\meteor-tool\1.6.1_1\mt-os.windows.x86_64\meteor.bat