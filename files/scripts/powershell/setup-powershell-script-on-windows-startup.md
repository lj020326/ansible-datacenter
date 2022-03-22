
Powershell at startup
===

This is useful when you want to run any automation created using PowerShell on Windows Startup. To run PowerShell script on startup.

Create a **Windows Command Script (.cmd file)** i.e. create a file and save it with **`.cmd`** extension.

![script.cmd](./img/image-109.png)

**Write the below command in .cmd file.**

**powerShell path\\to\\powershell\_script.ps1 >> “path\\to\\log\_file.log”**

![script.cmd](./img/image-110.png)

If you want to run the script in background. Add **`-windowstyle hidden`** after **powershell**.

![script.cmd](./img/image-112.png)

Place the file or its shortcut file at below path.

**C:\\Users\\<user\_name>\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup**

OR

**%APPDATA%\\Microsoft\\Windows\\Start Menu\\Programs\\Startup**


![script.cmd](./img/image-111.png)

**Restart the computer** and **you can track its execution in log file.**

___

