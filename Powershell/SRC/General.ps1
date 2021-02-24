# ===================================================================================================
# DESCRIPTION:
#
# ===================================================================================================
# ==========================================================
# Command Line   Parameters
# Import:
#     Import-Module General.psm1
# ==========================================================

Function global:ContainsCharacter{
  param(
    $String,
    $Characters
  )

  foreach ($Character in $([char[]]$Characters)){
    #write-host "`"$String`" - `"$Character`" :$($String.contains($Character))"
    if ($String.contains($Character))
    {
      return $True
    }
  }
  return $False
}


Function Replace-InvalidFileNameChars {
  param(
    [Parameter(Mandatory=$true,
      Position=0,
      ValueFromPipeline=$true,
      ValueFromPipelineByPropertyName=$true)]
    [String]$Name
  )

  $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
  $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
  return ($Name -replace $re,$(Get-Random -Maximum 10))
}

Function Remove-InvalidFileNameChars {
  param(
    [Parameter(Mandatory=$true,
      Position=0,
      ValueFromPipeline=$true,
      ValueFromPipelineByPropertyName=$true)]
    [String]$Name
  )

  $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
  $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
  return ($Name -replace $re,"")
}




Function global:SaveModule
{
  try {
    #Import-Module PsIni

    Import-Module -FullyQualifiedName 'E:\Modules\XXX'
  } catch {
    #Install-Module PsIni | Save-Module -Path '$Dir\PsIni'
    #Import-Module PsIni
    Install-Module -name PSReleaseTools -Force
    Find-Module -name PSReleaseTools | Save-Module -Path "E:\PowershellEXE\General_Test\Utils\Powershell\ModuleManager\Modules"

    Find-Module -name PsIni | Save-Module -Path "E:\PowershellEXE\General_Test\Utils\Powershell\ModuleManager\Modules"
    Import-Module -FullyQualifiedName 'E:\Modules\XXX'
  }
}


function global:SaveModule {
  <#
  .SYNOPSIS
    Save a module by module name.
  .DESCRIPTION
		intended to help Save Modules to be used within WinPE.
  .EXAMPLE
    Example 1.
      SaveModule "PSReleaseTools" "E:\PowershellEXE\General_Test_4\SRC\SystemTools\ModuleManager\Modules"
  #>
  [CmdletBinding()]
 Param(
  		[  Parameter(Mandatory=$true)][string]$ModuleName,
    	[  Parameter(Mandatory=$true)][string]$StoragePath
  	)
    iex "Find-Module -name $ModuleName | Save-Module -Path `"$StoragePath`""
}


function global:OpenSavedModule {
  <#
  .SYNOPSIS
		Opens a saved module by a given path.
  .DESCRIPTION
		Intended to help Load Modules to be used within WinPE.
  .EXAMPLE
    Example 1.
		OpenSavedModule
  #>
  [CmdletBinding()] Param(
		[  Parameter(Mandatory=$true)][string]$DriveLetter
	)
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid()
    return New-Item -ItemType Directory -Path (Join-Path $parent $name)
}




function global:ParametersOfList {
  <#
  .SYNOPSIS
		example code for filtering a list of a given type.
  .DESCRIPTION
		simple code snippet to help convey how to's
  .EXAMPLE
    Example 1.
		ParametersOfList
  #>
  [CmdletBinding()] Param(
		[Parameter(Mandatory=$true)][hashtable[]]$StringList
	)
  write-host $StringList
  write-host $StringList.getType().fullname
}


filter isNumeric() {
    return $_ -is [byte]  -or $_ -is [int16]  -or $_ -is [int32]  -or $_ -is [int64]  `
       -or $_ -is [sbyte] -or $_ -is [uint16] -or $_ -is [uint32] -or $_ -is [uint64] `
       -or $_ -is [float] -or $_ -is [double] -or $_ -is [decimal]
}




#for some reason the contents of the temporary directory get removed quickly.
#https://stackoverflow.com/questions/34559553/create-a-temporary-directory-in-powershell
function global:New_TemporaryDirectory {
  <#
  .SYNOPSIS
    Simple function that creates a temporary file.
  .DESCRIPTION

  .EXAMPLE
    Example 1.
      $Folder = New-TemporaryDirectory
      $Folder.FullName
    Example 2.
    Advanced-sleep 5 "Closing application please wait"
  #>
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid()
    return New-Item -ItemType Directory -Path (Join-Path $parent $name)
}





#Works with Powershell 5, Might not work with Powershell 6+
Function GetTerminalEnviornment(){
	<#
	  .SYNOPSIS
		Simple function that creates a temporary file.
	  .DESCRIPTION

	  .EXAMPLE
		Example 1.
		  GetTerminalEnviornment
		Example 2.
		Advanced-sleep 5 "Closing application please wait"
	#>
	(dir 2>&1 *`|echo CMD);&<# rem #>echo PowerShell
	
	<#
	#Possable solution for Powershell 6+
	if ($myinvocation.line) {
		"run from cli"
	} else {
		"run via explorer right click"
		$x = read-host
	}
	#>
}









Function global:Using_WinPE {
  <#
  .SYNOPSIS

  .DESCRIPTION

  .EXAMPLE
    Example 1.
      Using-WinPE
    Example 2.
  #>
  return Test-Path -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlset\Control\MiniNT
}

Function global:PWSH_Version
{
  <#
  .SYNOPSIS

  .DESCRIPTION

  .EXAMPLE
    Example 1.
      $PWSH_Version = PWSH_Version
    Example 2.
  #>
  #return pwsh -command "get-host | select-object version"
}

Function global:PASSTo_PWSH_Test
{
  <#
  .SYNOPSIS

  .DESCRIPTION

  .EXAMPLE
    Example 1.
      $PWSH_Version = PWSH_Version
    Example 2.
  #>
  $Value = "String"
 # pwsh -command "write-host $Value"
  #pwsh -command "write-host $($Value.getType().FullName)"
  #[ErrorHandling]$ErrorHandling = [ErrorHandling]::new($Options)
  #pwsh -command "write-host $($ErrorHandling.getType().FullName)"

  #return pwsh -command "write-host $Value"
}



Function global:GetDrivePermissions {
	<#
	.SYNOPSIS
		Simple function that checks if current script has permisions for a given drive.
		If no drive permissions are present, the script will call EngNet.bat on the network.
	.DESCRIPTION

	.EXAMPLE
		Example 1.
		Set_WindowSize 100 40
	#>
  [CmdletBinding()] Param(
		[  Parameter(Mandatory=$true)][string]$DriveLetter
	)

	try
	{
		Display_Message -mode "Failure" -Message "If in Production, Please Contact Engineering" -Message2 "Please Remove '-SaveArchive `"True`"' from the calling CMD Script." -Message3 "If being Used by engineer ignore." -Pause $True
		#$TestPermissionsDIR = $($Source_Archive -split ":")[0]  + ":\TestWritePermissions.txt"
		$TestPermissionsDIR = $DriveLetter  + ":\TestWritePermissions.txt"
		#
		if($SaveArchive)
		{
			$VerifyingDriveAccess            = $True
			while($VerifyingDriveAccess)
			{
				try
				{
					"." > $TestPermissionsDIR
					$VerifyingDriveAccess = $False
				}
				catch
				{
					if(!(Test-Path -Path $EngNetPath))
					{
						Display_Error_Message -Message "Please Contact Engineering" -Message2 "EngNetPath Incorrect, If in Production Remove '-SaveArchive `"1`"' from the calling CMD Script."
					}
					Display_Message -Mode "Attention" -Message "Calling ENGNET" -Message2 " "
					iex "$EngNetPath"
					pause
				}
			}
		}
	}
	catch
	{
		#Display_Error_Message -message "Could not Resize Window"
	}
}



#https://serverfault.com/questions/11879/gaining-administrator-privileges-in-powershell#:~:text=If%20you%20want%20to%20always,select%20%22Run%20as%20Administrator%22.&text=This%20is%20how%20to%20set,anytime%2C%20from%20any%20PowerShell%20session!
# PowerShell 5 (old version built into windows)
function GoAdmin { Start-Process powershell –Verb RunAs }

# PowerShell Core (the latest PowerShell version from GitHub)
#function GoAdmin { Start-Process pwsh –Verb RunAs }



# ==========================================================
# OverWrite Existing Folder structure File
# ==========================================================
function SaveNewFolderStructureObject{
	if ($SaveArchive)
	{
		$Current_FolderStructureObject = GetFolderStructureObject $Source_Archive

		$Current_FolderStructureObject | Export-Clixml $Archived_FolderStructure
	}
}
#| Export-Clixml .\FolderStruct.xml
function GetFolderStructureObject{
	  [CmdletBinding()] Param(
		[string]$Path
	)
	return Get-ChildItem "$Path" -Recurse -Directory
}
#Archived_FolderStructure
function VerifyFolderStructure{
	  [CmdletBinding()] Param(
		[string]$Path
	)
	# Set Values for Folder Compare
	$Current_FolderStructureObject = GetFolderStructureObject $Path


	#Read File object
	$Archived_FolderObject = Import-Clixml $Archived_FolderStructure

	return ((CompareObjects -Object1 $Current_FolderStructureObject -Object2 $Archived_FolderObject))
<# 	{
		return $True
	}
	else
	{
		return $False
	} #>
}

function CompareObjects{
	  [CmdletBinding()] Param(
		[string]$Object1,
		[string]$Object2
	)
	#Write-Host $($Object1.equal($Object2))
	#pause
	if ($($Object1.equals($Object2)))#(!(Compare-Object -ReferenceObject $Object1 -DifferenceObject $Object2 -Property Name, Length))
	{
		return $True
	}
	else
	{
		return $False
	}
}
<#
#>
<#
CompareFolderStructure -Path1 -Path2
	Returns $True if Folderstructure match
#>
function CompareFolderStructure{
	  [CmdletBinding()] Param(
		[string]$Path1,
		[string]$Path2
	)
	$FolderChild1 = GetFolderStructureObject -Path $Path1
	$FolderChild2 = GetFolderStructureObject -Path $Path2
	return CompareObjects -Object1 $FolderChild1 -Object2 $FolderChild2
}


Function SetGetPath{
	  [CmdletBinding()] Param(
		[  Parameter(Mandatory=$true)][String]$Path
	)

	if(!(Test-Path -Path $Path))
    {
		New-Item -ItemType Directory -Force -Path $Path
    }
    return $Path
}

function global:MakePath {
    [CmdletBinding()] Param(
      [Parameter(Mandatory=$true)][string]$Path
    )
  try{
    if(!(Test-Path -Path $Path ))
    {
      return New-Item -ItemType Directory -Force -Path $Path
    }
  }
  catch{
    $path = $($Path | % {$ASCIIFirst[$_]})
    if(!(Test-Path -Path $path))
    {
      return New-Item -ItemType Directory -Force -Path $Path
    }
  }

	#write-host "MakePath returning:$($Path.ToString())"
	return $Path.ToString()
}





# ==========================================================
# Parse IniFile
# ==========================================================
Function global:Parse-IniFile ($File) {
	Try {
		$rPath = Resolve-Path -Path $File -ErrorAction Stop
		if(!(Test-Path $File))
		{
			#throw "ini File:$File missing"
			Write-Warning "ini File:$File missing"
			Display_Error_Message -Mode "Failure" -Message "ini File:$File missing" -Message2 "Please Contact Engineering" -ClearScreen $False
		}
	}
	Catch {
		#throw "ini File:$File missing"
		Write-Warning "ini File:$File missing"
		Display_Error_Message -Mode "Failure" -Message "ini File:$File missing" -Message2 "Please Contact Engineering" -ClearScreen $False
	}
	start-sleep 2
}


# ==========================================================
# ENTRY INFO
# ==========================================================
Function global:READ_SETENV{
	<#
	.SYNOPSIS
		This Function Prepares a GUI for adding Network drives to a system.
	.DESCRIPTION
		More indepth explination of the given function, and the underlining operations
	.EXAMPLE
		Example 1.
	#>
  [CmdletBinding()] Param(
		[String]$Path="r:\setenv.cmd"
	)

	if((Test-Path $Path) -eq $False){
		#TODO: Check Purpose of Command
		#inifile x:\windows\system32\config.ini [info] > r:\setenv.cmd
		inifile x:\windows\system32\config.ini [info] > r:\setenv.cmd

	}
	$global:SystemInfo = Parse-IniFile("x:\windows\system32\config.ini")
	write-host $SystemInfo["info"]["ip"]



	#Test for an existing $stknum value
	if($SystemInfo["info"]["ip"] -eq "")
	{
		Display_Error_Message -Message "System missing Configuration Info, " -Message2 "Please contact Engineering!"

	}


}








Function global:GetFileCount{
  [CmdletBinding()] Param(
		[string]$Path
	)
	return $((Get-ChildItem "$Path" -Recurse ) | where {$_ -is [System.IO.FileInfo]}).Count
}

Function global:RemovePath{
  [CmdletBinding()] Param(
		[string]$Path
	)
	 if(Test-Path -Path $Path )
      {
        Remove-Item $Path -Recurse -ErrorAction Ignore
      }
      return $Path
}


Function global:JoinPath{
  [CmdletBinding()] Param(
		[string]$List
	)
	$Path = ""
	foreach($Appendage in $List)
	{
		if ($Path -eq "")
		{
			$Path = $appendage
		}
		else
		{
			$Path = join-path $Path $Appendage
		}
	}
	return $Path
}

Function global:CleanFolder{
  [CmdletBinding()] Param(
		[string]$Path
	)
	<#
	.SYNOPSIS

	.DESCRIPTION

	.EXAMPLE

	#>
	try
	{
		if($Path.Substring($Path.get_Length()-1) -ne "\" )
		{
			$Path+="\"
		}
		if(Test-Path -Path $Path )
		{
			Remove-Item -Recurse -Force $Path*.*
		}
	}
	catch
	{
		write-host "Failed to Clean Results folder: `n" + $Error[0]
	}
}
