@REM wsadmin launcher 
@echo off 
@REM Usage: wsadmin arguments setlocal 
@REM WAS_HOME should point to whatever directory you decide for your thin client environment 

@setlocal

set WAS_HOME=%~dp0
set WAS_HOME=%WAS_HOME:~0,-1%
echo WAS_HOME=%WAS_HOME%
set WAS_LIBS=%WAS_HOME%\lib
echo WAS_LIBS=%WAS_LIBS%

set USER_INSTALL_ROOT=%WAS_HOME%
echo USER_INSTALL_ROOT=%USER_INSTALL_ROOT%

@REM Java home should point to where java is installed in the thin client directory
@REM or where an IBM Java is installed on the machine where that thin client is going to run. 
@REM set JAVA_HOME="%WAS_HOME%\java"
set WAS_LOGGING=-Djava.util.logging.manager=com.ibm.ws.bootstrap.WsLogManager -Djava.util.logging.configureByServer=true
set THIN_CLIENT=-Dcom.ibm.websphere.thinclient=true

@REM Echoing JAVA_HOME is useful for debugging
@REM echo wsadmin thin client JAVA_HOME is: %JAVA_HOME%
@REM Quoting the argument to exist leads to not finding java.exe. Go figure.
if exist %JAVA_HOME%\bin\java.exe (
  set JAVA_EXE=%JAVA_HOME%\bin\java
) else (
  echo Can not find a java.exe & goto END
)

	
@REM CONSOLE_ENCODING controls the output encoding used for stdout\stderr 
@REM console - encoding is correct for a console window 
@REM file - encoding is the default file encoding for the system 
@REM other - the specified encoding is used.  e.g. Cp1252, Cp850, SJIS 
@REM SET CONSOLE_ENCODING=-Dws.output.encoding=console  
@REM For debugging the utility itself 
@REM set WAS_DEBUG=-Djava.compiler=NONE -Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=7777  

set CLIENTSOAP=-Dcom.ibm.SOAP.ConfigURL=file:%WAS_HOME%\properties\soap.client.props
@REM set CLIENTSAS=-Dcom.ibm.CORBA.ConfigURL=file:%WAS_HOME%\properties\sas.client.props
set CLIENTSSL=-Dcom.ibm.SSL.ConfigURL=file:%WAS_HOME%\properties\ssl.client.props
set CLIENTIPC=-Dcom.ibm.IPC.ConfigURL=file:%WAS_HOME%\properties\ipc.client.props
set JAASSOAP=-Djava.security.auth.login.config=%WAS_HOME%\properties\wsjaas_client.conf

@REM the following are wsadmin properties 
@REM you need to change the value to enabled to turn on trace 
set wsadminTraceString=-Dcom.ibm.ws.scripting.traceString=com.ibm.*=all=disabled
set wsadminTraceFile=-Dcom.ibm.ws.scripting.traceFile=%WAS_HOME%\logs\wsadmin.traceout
set wsadminValOut=-Dcom.ibm.ws.scripting.validationOutput=%WAS_HOME%\logs\wsadmin.valout

@REM this will be the server host that you will connecting to 
@REM set wsadminHost=-Dcom.ibm.ws.scripting.host=bogushost
@REM set wsadminHost=-Dcom.ibm.ws.scripting.host=30.142.103.77

@REM you need to make sure the port number is the server SOAP port number you want to connect to, in this example the server SOAP port is 8887 
@REM set wsadminConnType=-Dcom.ibm.ws.scripting.connectionType=SOAP
@REM set wsadminPort=-Dcom.ibm.ws.scripting.port=8887
@REM set wsadminConnType=-Dcom.ibm.ws.scripting.connectionType=SOAP
@REM set wsadminPort=-Dcom.ibm.ws.scripting.port=8879

@REM you need to make sure the port number is the server RMI port number you want to connect to, in this example the server RMI Port is 2815 
@REM set wsadminConnType=-Dcom.ibm.ws.scripting.connectionType=RMI 
@REM set wsadminPort=-Dcom.ibm.ws.scripting.port=2815  

@REM you need to make sure the port number is the server JSR160RMI port number you want to connect to, in this example the server JSR160RMI Port is 9809
@REM set wsadminConnType=-Dcom.ibm.ws.scripting.connectionType=JSR160RMI 
@REM set wsadminPort=-Dcom.ibm.ws.scripting.port=9809  

@REM you need to make sure the port number is the server IPC port number you want to connect to, in this example the server IPC Port is 9632 and the host for IPC should be localhost 
@REM set wsadminHost=-Dcom.ibm.ws.scripting.ipchost=localhost 
@REM set wsadminConnType=-Dcom.ibm.ws.scripting.connectionType=IPC 
@REM set wsadminPort=-Dcom.ibm.ws.scripting.port=9632  

@REM specify what language you want to use with wsadmin 
@REM set wsadminLang=-Dcom.ibm.ws.scripting.defaultLang=jacl 
set wsadminLang=-Dcom.ibm.ws.scripting.defaultLang=jython

set SHELL=com.ibm.ws.scripting.WasxShell

:prop set WSADMIN_PROPERTIES_PROP=
if not defined WSADMIN_PROPERTIES goto workspace
set WSADMIN_PROPERTIES_PROP="-Dcom.ibm.ws.scripting.wsadminprops=%WSADMIN_PROPERTIES%"

:workspace set WORKSPACE_PROPERTIES=
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

@REM set WAS_SCRIPT_LIBS=-Dwsadmin.script.libraries=%JYTHON_HOME%\Lib
set WAS_SCRIPT_LIBS=-Dwsadmin.script.libraries=%JYTHON_HOME%
set PYTHON_LIBS=-Dpython.path=%JYTHON_HOME%\Lib
@REM set JYTHON_LIB=-Dwsadmin.jython.libraries=%JYTHON_HOME%\jython.jar
@REM set JYTHON_LIB=-Dwsadmin.jython.libraries=%WAS_LIBS%\jython\Lib
set JYTHON_LIB=-Dwsadmin.jython.libraries=%JYTHON_HOME%\Lib

@REM The Jython JAR needs to appear in the classpath befor the admin client JAR in order to properly load the latest Jython.
@REM The admin client JAR name changes based on the version of WAS in use, e.g., 7.0 changes to 8.0 or 8.5
@REM set C_PATH="%WAS_HOME%\lib\jython\jython.jar;%WAS_HOME%\properties;%WAS_HOME%\lib\com.ibm.ws.admin.client_7.0.0.jar;%WAS_HOME%\lib\com.ibm.ws.security.crypto.jar;%WAS_HOME%\lib\classes;%WAS_HOME%\lib\ext\*;"

@REM set C_PATH=%WAS_HOME%\lib\jython\jython.jar;%WAS_HOME%\properties;%WAS_LIBS%\com.ibm.ws.admin.client_8.5.0.jar;%WAS_LIBS%\com.ibm.ws.security.crypto.jar;%JAVA_HOME%\lib\classes;%JAVA_HOME%\lib\ext\*;
@REM set C_PATH=%JYTHON_HOME%\jython.jar;%WAS_HOME%\properties;%WAS_LIBS%\com.ibm.ws.admin.client_8.5.0.jar;%WAS_LIBS%\com.ibm.ws.security.crypto.jar;%WAS_LIBS%\ibmkeycert.jar;%WAS_LIBS%\ibmpkcs.jar
set C_PATH=%WAS_HOME%\properties;%WAS_LIBS%\com.ibm.ws.admin.client_8.5.0.jar;%WAS_LIBS%\com.ibm.ws.security.crypto.jar;%WAS_LIBS%\ibmkeycert.jar;%WAS_LIBS%\ibmpkcs.jar;%JYTHON_HOME%\jython.jar

@REM set PERFJAVAOPTION=-Xms256m -Xmx256m -Xj9 -Xquickstart
set PERFJAVAOPTION=-Xms256m -Xmx256m

if "%JAASSOAP%"=="" set JAASSOAP=-Djaassoap=off

@REM For debugging purposes echo out the command that launches the thin client
echo About to execute:
echo %JAVA_EXE% %PERFJAVAOPTION% %WAS_LOGGING% %javaoption% %CONSOLE_ENCODING% %WAS_DEBUG% %THIN_CLIENT% %JAASSOAP% %CLIENTSOAP% %CLIENTIPC% %CLIENTSSL% %WSADMIN_PROPERTIES_PROP% %WORKSPACE_PROPERTIES% -Duser.install.root=%USER_INSTALL_ROOT% -Dwas.install.root=%WAS_HOME% %wsadminTraceFile% %wsadminTraceString% %wsadminValOut% %wsadminHost% %wsadminConnType% %wsadminPort% %wsadminLang% %PYTHON_LIBS% -classpath %C_PATH% %SHELL% %*
%JAVA_EXE% %PERFJAVAOPTION% %WAS_LOGGING% %javaoption% %CONSOLE_ENCODING% %WAS_DEBUG% %THIN_CLIENT% %JAASSOAP% %CLIENTSOAP% %CLIENTIPC% %CLIENTSSL% %WSADMIN_PROPERTIES_PROP% %WORKSPACE_PROPERTIES% -Duser.install.root=%USER_INSTALL_ROOT% -Dwas.install.root=%WAS_HOME% %wsadminTraceFile% %wsadminTraceString% %wsadminValOut% %wsadminHost% %wsadminConnType% %wsadminPort% %wsadminLang% %PYTHON_LIBS% -classpath %C_PATH% %SHELL% %*

set RC=%ERRORLEVEL%

goto END

:END

@endlocal & set MYERRORLEVEL=%ERRORLEVEL% 

if defined PROFILE_CONFIG_ACTION exit %MYERRORLEVEL% else exit /b %MYERRORLEVEL%

GOTO :EOF
