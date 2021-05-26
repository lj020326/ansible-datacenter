@REM wsadmin launcher
@echo off

@REM call getopt.bat %*

@REM Set the location of wsadmin.bat
set WAS_HOME=%~dp0
@REM echo %WAS_HOME:~0,-1%
set WAS_HOME=%WAS_HOME:~0,-1%
echo %WAS_HOME%

@REM C_PATH is the class path.  Add to it as needed. 
set SOAP_CONFIG=-Dcom.ibm.SOAP.ConfigURL=file:/%WAS_HOME%\properties\soap.client.props
set SSL_CONFIG=-Dcom.ibm.SSL.ConfigURL=file:/%WAS_HOME%\properties\ssl.client.props
set AUTH_CONFIG=-Djava.security.auth.login.config=file:/%WAS_HOME%\properties\wsjaas_client.conf
set USER_INSTALL_ROOT=-Duser.install.root=%WAS_HOME%
set WAS_INSTALL_ROOT=-Dwas.install.root=%WAS_HOME%
set WAS_LIBS=%WAS_HOME%\lib
echo %WAS_LIBS%

@REM set JAVA_HOME="C:\Program Files\Java\jre1.8.0_65"
@REM set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_HOME=C:\apps\jdk-8u60-windows-x64\jre

echo JAVA_HOME=%JAVA_HOME%
if not exist %JAVA_HOME%\bin\java.exe (
  echo Can not find a java.exe 
  exit
)

set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%\bin\java
echo JAVA_EXE=%JAVA_EXE%

set JYTHON_HOME=C:\apps\jython2.7.0

set WAS_LOGGING=-Djava.util.logging.manager=com.ibm.ws.bootstrap.WsLogManager -Djava.util.logging.configureByServer=true 
set WAS_LOGGING=%WAS_LOGGING% -Dcom.ibm.ws.scripting.traceString=com.ibm.*=all=disabled 
set WAS_LOGGING=%WAS_LOGGING% -Dcom.ibm.ws.scripting.traceFile=%WAS_HOME%\logs\wsadmin.traceout
set WAS_LOGGING=%WAS_LOGGING% -Dcom.ibm.ws.scripting.validationOutput=%WAS_HOME%\logs\wsadmin.valout

set WAS_SCRIPT_LIBS=-Dwsadmin.script.libraries=%JYTHON_HOME%\Lib
set PYTHON_LIBS=-Dpython.path=%JYTHON_HOME%\Lib
@REM set JYTHON_LIB=-Dwsadmin.jython.libraries=%JYTHON_HOME%\jython.jar
@REM set JYTHON_LIB=-Dwsadmin.jython.libraries=%WAS_LIBS%\jython\Lib
set JYTHON_LIB=-Dwsadmin.jython.libraries=%JYTHON_HOME%\Lib

@REM set JAVA_OPTS=-Xms256m -Xmx256m -Djavax.net.ssl.trustStoreType=JKS
@REM set JAVA_OPTS=-Xms256m -Xmx256m -Djavax.net.ssl.trustStoreType=JKS %JYTHON_LIB% %PYTHON_LIBS%
set JAVA_OPTS=-Xms256m -Xmx256m -Djavax.net.ssl.trustStoreType=JKS "%JYTHON_LIB%" "%PYTHON_LIBS%"

set TC=-Dcom.ibm.websphere.thinclient=true

@REM set C_PATH=%WAS_HOME%\properties;%WAS_LIBS%\com.ibm.ws.admin.client_8.5.0.jar;%WAS_LIBS%\com.ibm.ws.security.crypto.jar
@REM set C_PATH=%C_PATH%;%JYTHON_HOME%\jython.jar
set C_PATH=%JYTHON_HOME%\jython.jar;%WAS_HOME%\properties;%WAS_LIBS%\com.ibm.ws.admin.client_8.5.0.jar;%WAS_LIBS%\com.ibm.ws.security.crypto.jar
set C_PATH=%C_PATH%;%WAS_LIBS%\ibmkeycert.jar;%WAS_LIBS%\ibmpkcs.jar

@REM set C_PATH=%C_PATH%;%WAS_HOME%\jsoup-1.7.2.jar

%JAVA_EXE% %JAVA_OPTS% %TC% %SOAP_CONFIG% %AUTH_CONFIG% %SSL_CONFIG% %USER_INSTALL_ROOT% %WAS_INSTALL_ROOT% %WAS_LOGGING% -classpath %C_PATH% com.ibm.ws.scripting.WasxShell %* 

