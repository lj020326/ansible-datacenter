@REM wsadmin launcher
@REM @echo off

@REM call getopt.bat %*

@REM Set the location of wsadmin.bat
set WAS_HOME=%~dp0
@REM echo %WAS_HOME:~0,-1%
set WAS_HOME=%WAS_HOME:~0,-1%
echo WAS_HOME=%WAS_HOME%

echo JAVA_HOME=%JAVA_HOME%
if not exist "%JAVA_HOME%\bin\java.exe" (
  echo Can not find a java.exe 
  exit
)

echo JYTHON_HOME=%JYTHON_HOME%
if not exist "%JYTHON_HOME%\jython.jar" (
  echo Can not find a jython.jar 
  exit
)

set SOAP_CONFIG=-Dcom.ibm.SOAP.ConfigURL=file:/%WAS_HOME%\properties\soap.client.props
set SSL_CONFIG=-Dcom.ibm.SSL.ConfigURL=file:/%WAS_HOME%\properties\ssl.client.props
set AUTH_CONFIG=-Djava.security.auth.login.config=file:/%WAS_HOME%\properties\wsjaas_client.conf
set USER_INSTALL_ROOT=-Duser.install.root=%WAS_HOME%
set WAS_INSTALL_ROOT=-Dwas.install.root=%WAS_HOME%
set WAS_LIBS=%WAS_HOME%\lib

set WAS_LOGGING=-Djava.util.logging.manager=com.ibm.ws.bootstrap.WsLogManager -Djava.util.logging.configureByServer=true 
set WAS_LOGGING=%WAS_LOGGING% -Dcom.ibm.ws.scripting.traceString=com.ibm.*=all=disabled 
set WAS_LOGGING=%WAS_LOGGING% -Dcom.ibm.ws.scripting.traceFile=%WAS_HOME%\logs\wsadmin.traceout
set WAS_LOGGING=%WAS_LOGGING% -Dcom.ibm.ws.scripting.validationOutput=%WAS_HOME%\logs\wsadmin.valout

set WAS_SCRIPT_LIBS=-Dwsadmin.script.libraries="%JYTHON_HOME%\Lib"
set PYTHON_LIBS=-Dpython.path="%JYTHON_HOME%\Lib"
@REM set PYTHON_LIBS=-Dpython.path=%WAS_LIBS%\jython\Lib

set JYTHON_HOME=%JAVA_HOME:"=%
@REM set JYTHON_LIB=-Dwsadmin.jython.libraries=%WAS_LIBS%\jython
set JYTHON_LIB=-Dwsadmin.jython.libraries="%JYTHON_HOME%\Lib"

set JAVA_HOME=%JAVA_HOME:"=%
@REM echo JAVA_HOME=%JAVA_HOME%
set JAVA_EXE="%JAVA_HOME%\bin\java"
echo JAVA_EXE=%JAVA_EXE%
set JAVA_OPTS=-Xms256m -Xmx256m -Djavax.net.ssl.trustStoreType=JKS %PYTHON_LIBS% %JYTHON_LIB%

set TC=-Dcom.ibm.websphere.thinclient=true

set C_PATH="%WAS_HOME%\properties;%WAS_LIBS%\com.ibm.ws.admin.client_8.5.0.jar;%WAS_LIBS%\com.ibm.ws.security.crypto.jar;%WAS_LIBS%\ibmkeycert.jar;%WAS_LIBS%\ibmpkcs.jar;%WAS_LIBS%\jsoup-1.7.2.jar;%JYTHON_HOME%\jython.jar"
@REM set C_PATH=%JYTHON_HOME%\jython.jar;%WAS_HOME%\properties;%WAS_LIBS%\com.ibm.ws.admin.client_8.5.0.jar;%WAS_LIBS%\com.ibm.ws.security.crypto.jar;%WAS_LIBS%\ibmkeycert.jar;%WAS_LIBS%\ibmpkcs.jar;%WAS_LIBS%\jsoup-1.7.2.jar

%JAVA_EXE% %JAVA_OPTS% %TC% %SOAP_CONFIG% %AUTH_CONFIG% %SSL_CONFIG% %USER_INSTALL_ROOT% %WAS_INSTALL_ROOT% %WAS_LOGGING% -classpath %C_PATH% com.ibm.ws.scripting.WasxShell %* 
