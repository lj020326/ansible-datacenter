@REM wsadmin launcher
@echo off
@REM Usage: wsadmin arguments
setlocal
@REM was home should point to whatever directory you decide for your thin client environment
set WAS_HOME=c:\autobuild\sampleprojects\repos\was-thin-admin-client-7.0
@REM set USER_INSTALL_ROOT=c:\autobuild\autobuild\scripts\wasadmin\test\wasadmin
set USER_INSTALL_ROOT=c:\apps\wasclient
@REm Java home should point to where you installed java for your thinclient
@REM set JAVA_HOME="c:\was7\java"
set JAVA_HOME="C:\apps\jdk-8u60-windows-x64"

set WAS_LOGGING=-Djava.util.logging.manager=com.ibm.ws.bootstrap.WsLogManager -Djava.util.logging.configureByServer=true

if exist "%JAVA_HOME%\bin\java.exe" (
   set JAVA_EXE="%JAVA_HOME%\bin\java"
) else (
   set JAVA_EXE="%JAVA_HOME%\jre\bin\java"
)

@REM CONSOLE_ENCODING controls the output encoding used for stdout/stderr
@REM console - encoding is correct for a console window
@REM file - encoding is the default file encoding for the system
@REM other - the specified encoding is used.  e.g. Cp1252, Cp850, SJIS
@REM SET CONSOLE_ENCODING=-Dws.output.encoding=console

@REM For debugging the utility itself
@REM set WAS_DEBUG=-Djava.compiler=NONE -Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=7777

set CLIENTSOAP=-Dcom.ibm.SOAP.ConfigURL=file://localhost/autobuild/autobuild/scripts/wasadmin/test/wasadmin/soap.client.props
set CLIENTSAS=-Dcom.ibm.CORBA.ConfigURL=file:"%USER_INSTALL_ROOT%"\sas.client.props
set CLIENTSSL=-Dcom.ibm.SSL.ConfigURL=file://localhost/autobuild/autobuild/scripts/wasadmin/test/wasadmin/ssl.client.props

@REM the following are wsadmin property 
@REM you need to change the value to enabled to turn on trace
set wsadminTraceString=-Dcom.ibm.ws.scripting.traceString=com.ibm.*=all=disabled
set wsadminTraceFile=-Dcom.ibm.ws.scripting.traceFile="%USER_INSTALL_ROOT%"\logs\wsadmin.traceout
set wsadminValOut=-Dcom.ibm.ws.scripting.validationOutput="%USER_INSTALL_ROOT%"\logs\wsadmin.valout
@REM this will be the server host that you will connecting to
set wsadminHost=-Dcom.ibm.ws.scripting.host=localhost

@REM you need to make sure the port number is the server SOAP port number you want to connect to, in this example the server SOAP port is 8887
set wsadminConnType=-Dcom.ibm.ws.scripting.connectionType=SOAP
set wsadminPort=-Dcom.ibm.ws.scripting.port=8880

@REM you need to make sure the port number is the server RMI port number you want to connect to, in this example the server RMI Port is 2815
@REM set wsadminConnType=-Dcom.ibm.ws.scripting.connectionType=RMI
@REM set wsadminPort=-Dcom.ibm.ws.scripting.port=2815

@REM specify what language you want to use with wsadmin
set wsadminLang=-Dcom.ibm.ws.scripting.defaultLang=jython
@REM set wsadminLang=-Dcom.ibm.ws.scripting.defaultLang=jython

set SHELL=com.ibm.ws.scripting.WasxShell

:prop
set WSADMIN_PROPERTIES_PROP=
if not defined WSADMIN_PROPERTIES goto workspace
set WSADMIN_PROPERTIES_PROP="-Dcom.ibm.ws.scripting.wsadminprops=%WSADMIN_PROPERTIES%"

:workspace
set WORKSPACE_PROPERTIES=
if not defined CONFIG_CONSISTENCY_CHECK goto loop
set WORKSPACE_PROPERTIES="-Dconfig_consistency_check=%CONFIG_CONSISTENCY_CHECK%"

:loop
if '%1'=='-javaoption' goto javaoption
if '%1'=='' goto runcmd
goto nonjavaoption

:javaoption
shift
set javaoption=%javaoption% %1
goto again

:nonjavaoption
set nonjavaoption=%nonjavaoption% %1

:again
shift
goto loop


:runcmd
@REM Note jython.jar that overrides the one supplied with WAS
set C_PATH="\autobuild\autobuild\lib\jython\jython.jar;%WAS_HOME%\properties;%WAS_HOME%\com.ibm.ws.admin.client_7.0.0.jar;%WAS_HOME%\com.ibm.ws.security.crypto.jar;"

@REM set PERFJAVAOPTION=-Xms256m -Xmx256m -Xj9 -Xquickstart
set PERFJAVAOPTION=-Xms256m -Xmx256m 

if "%JAASSOAP%"=="" set JAASSOAP=-Djaassoap=off

@echo off

"%JAVA_EXE%" -Dpython.path=/autobuild/autobuild/scripts;/autobuild/autobuild/lib/jython  %PERFJAVAOPTION% %WAS_LOGGING% %javaoption% %CONSOLE_ENCODING% %WAS_DEBUG% "%CLIENTSOAP%" "%JAASSOAP%" "%CLIENTSAS%" "%CLIENTSSL%" %WSADMIN_PROPERTIES_PROP% %WORKSPACE_PROPERTIES% "-Duser.install.root=%USER_INSTALL_ROOT%" "-Dwas.install.root=%WAS_HOME%" %wsadminTraceFile% %wsadminTraceString% %wsadminValOut% %wsadminHost% %wsadminConnType% %wsadminPort% %wsadminLang% -classpath %C_PATH% com.ibm.ws.scripting.WasxShell %*


