# ==========================================================
# Command Line Parameters
# ==========================================================
#write-host "Calling SystemTools"

<# [String]$script:ManifestPath     = $args
write-host "SystemTools ManifestPath: '$global:ManifestPath', '$args'"

#[String]$global:ManifestPath     = "D:\PowershellEXE\General_Test_1\SRC\..\Temp.ini"
#"$SelfFolder\Manifest.ini"
# ==========================================================
# Set Script Values
# ==========================================================

write-host "V0"
write-host "ManifestPath: $global:ManifestPath, '$args'" #>


#DMS Work Order Length Check

$Dir = split-path -parent $MyInvocation.MyCommand.Definition
$script:SelfFolder                      = $($Dir.Substring(0,$($Dir.Length)))
$script:SelfFile                        = $Dir + "\"+ $MyInvocation.MyCommand.Name



write-host "$Dir\SystemTools\"
# ==========================================================
# Impoorting .psm1 and .ps1 scripts
# ==========================================================
#$allscripts = Get-ChildItem -Path  "$SelfFolder\SystemTools\" -Filter "*.psm1" | Select-Object -ExpandProperty FullName

$allscripts = Get-ChildItem -Path "$Dir\SystemTools\" | where-object{$_.Name.endswith(".ps1")  } | Select-Object -ExpandProperty FullName
foreach ($script in $allscripts) {
	#write-host "Importing $script"
	#Import-Module "$script"
	$ScriptPath = $script.Split(".")
	#write-host $script $script.GetType() $ScriptPath
	if(-not $($ScriptPath[0]).EndsWith("_test"))
	{
		#write-host "Import-Module:$script $ManifestPath"
		Import-Module "$script" -Verbose:$false
		#Import-Module "$script '$ManifestPath'" -Verbose:$false
		#Invoke-expression "powershell.exe $script $ManifestPath"
	}
}
$allscripts = Get-ChildItem -Path "$Dir\SystemTools\" | where-object{$_.Name.endswith(".psm1")  } | Select-Object -ExpandProperty FullName
foreach ($script in $allscripts) {
	#write-host "Importing $script"
	#Import-Module "$script"
	$ScriptPath = $script.Split(".")
	#write-host $script $script.GetType() $ScriptPath
	if(-not $($ScriptPath[0]).EndsWith("_test"))
	{
		#write-host "Import-Module:$script $ManifestPath"
		iex "using module $script"
		#Import-Module "$script '$ManifestPath'" -Verbose:$false
		#Invoke-expression "powershell.exe $script $ManifestPath"
	}
}



$allscripts = Get-ChildItem -Path "$Dir\TestTools\" | where-object{$_.Name.endswith(".ps1")  } | Select-Object -ExpandProperty FullName
foreach ($script in $allscripts) {
	#write-host "Importing $script"
	#Import-Module "$script"
	$ScriptPath = $script.Split(".")
	#write-host $script $script.GetType() $ScriptPath
	if(-not $($ScriptPath[0]).EndsWith("_test"))
	{
		#write-host "Import-Module:$script $ManifestPath"
		Import-Module "$script" -Verbose:$false
		#Import-Module "$script '$ManifestPath'" -Verbose:$false
		#Invoke-expression "powershell.exe $script $ManifestPath"
	}
}



Function Global:ImportDirectory{
	<#
	.SYNOPSIS

	.DESCRIPTION

	.EXAMPLE
		ImportDirectory "$DIR\TestTools\"
		ImportDirectory "$DIR\SystemTools\"
	#>
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true)][String]$Directory,
		[Parameter(Mandatory=$false)][String]$FileExtention = ".ps1"
	)
	$allscripts = Get-ChildItem -Path "$Directory" | where-object{$_.Name.endswith(".ps1")  } | Select-Object -ExpandProperty FullName
	foreach ($script in $allscripts) {
		$ScriptPath = $script.Split(".")

		if(-not $($ScriptPath[0]).EndsWith("_test"))
		{
			write-host "Import-Module:$script $ManifestPath"
			Import-Module "$script" -Verbose:$false -Force -Scope Global #-- Global #-Global
			#iex "using module $script"
			#using module $script -Verbose:$false -Force -Scope Global
			#Import-Module "$script '$ManifestPath'" -Verbose:$false
			#Invoke-expression "powershell.exe $script $ManifestPath"
		}
	}

	$allscripts = Get-ChildItem -Path "$Directory" | where-object{$_.Name.endswith(".psm1")  } | Select-Object -ExpandProperty FullName
	foreach ($script in $allscripts) {
		$ScriptPath = $script.Split(".")

		if(-not $($ScriptPath[0]).EndsWith("_test"))
		{
			write-host "using module:$script"
			#Import-Module "$script" -Verbose:$false -Force -Scope Global #-Global
			iex "using module $script"
			#Import-Module "$script" -Verbose:$false -Force -Scope Global #-Global
			#using module $script -Verbose:$false -Force -Scope Global
			#Import-Module "$script '$ManifestPath'" -Verbose:$false
			#Invoke-expression "powershell.exe $script $ManifestPath"
		}
	}
	[ErrorHandling]$ErrorHandling = [ErrorHandling]::new(@("View","Continue","Detailed","Exit"))
	#[ErrorHandling]
	#[ErrorHandling] | get-member
	Get-Module
	CheckForErrors -Message "Something Went wrong"
	pause
}



#write-host $Dir
#write-host "$ManifestPath.ini"

$Global:PS_FULLVERSION = get-host | select-object version
$Global:PS_Version = $PS_FULLVERSION.Version.major


# ==========================================================
# Setting Global Variables
# ==========================================================
<# write-host "ManifestPath: '$global:ManifestPath', '$args'"
$global:Manifest = Parse-IniFile "$global:ManifestPath"
$global:WorkOrderLength                 = 8
$global:DefaultStartSleep               = 4


$global:WINPESystem                     = Using_WinPE
$global:TestCartSystem                  = !(Using_WinPE)

#Redeclared Drive as global to avoid "" error
$global:Drive                           = $($((Get-Location).path).tostring() -split ":")[0]
#$Drive                    = $Drive

$global:FileNameWithoutExtension = $([io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))

$global:DefaultStartSleep        = $Manifest.manifest.DefaultStartSleep

$global:ResultsDIR               = "$($ResultsDrive):\$CID\$OrderNumber\$SerialNumber\" #"X:\.txt"#
$global:ResultsPath              = "$($ResultsDIR)Scripts.log" #"X:\.txt"#
$VerbosePreference               = 'Continue'



$global:DetailedLogsDIR          = "$((Get-Location).path)"
$global:DetailedLogsPath         = "$($DetailedLogsDIR)\RunTime.log"
#Start-Transcript -path $LocalLogsPath #-append

$global:LocalDIR                 = "$((Get-Location).path)\RunTime.log" #"X:\.txt"#
$global:LocalLogsPath            = "$((Get-Location).path)\RunTime.log" #"X:\.txt"#

$global:Archived_HashFile        = $PSScriptRoot+"\Archived_HashFile.txt"
$global:Archived_FolderStructure = $PSScriptRoot+"\Archived_FolderStructure.xml" #>




#Display_Message -Mode $Mode -Message $Message -Message2 $Message2 -Message3 "An error has occured" -ClearScreen $True -SleepFor 0
#Archive Check Variables
#FilePath for Saved Hash Value.


#Engnet.cmd is a script to request network access permissions for engineers
#Start Engnet code: "iex "$EngNetPath"LocalLogs


#Default Sleep timeout for displaying messages (in seconds)
