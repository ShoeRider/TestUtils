# PowershellUtils
Personal Powershell Utilities



Note: Some code is simple re declarations of already existing commands.

TestLine:
```
.\General_Test.ps1
```


Import Line:
```
$Dir = split-path -parent $MyInvocation.MyCommand.Definition
$global:Dir = $($Dir.Substring(0,$($Dir.Length)))
invoke-expression -Command ".\General.ps1"
```
