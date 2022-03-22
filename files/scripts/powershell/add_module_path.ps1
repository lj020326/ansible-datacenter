
#Save the current value in the $p variable.
$p = [Environment]::GetEnvironmentVariable("PSModulePath")

#Add the new path to the $p variable. Begin with a semi-colon separator.
$p += ";C:\apps\powershell\modules\"

#Add the paths in $p to the PSModulePath value.
[Environment]::SetEnvironmentVariable("PSModulePath",$p)
