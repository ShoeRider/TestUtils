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



Imported Libraries
```
Join-Object from .AUTHOR iRon
.VERSION 3.3.0
.PROJECTURI https://github.com/iRon7/Join-Object
.LICENSE https://github.com/iRon7/Join-Object/LICENSE
.TAGS Join-Object Join InnerJoin LeftJoin RightJoin FullJoin CrossJoin Update Merge Combine Table
```
