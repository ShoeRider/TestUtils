# ===================================================================================================
# DESCRIPTION:
#
# ===================================================================================================
# ==========================================================
# Command Line Parameters
# Import:
#     Import-Module General.psm1
# ==========================================================








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



Function global:Using_WinPE
{
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



Function global:GetDrivePermissions {
	<#
	.SYNOPSIS
		Simple function that Changes the size of the window to X Y values.
	.DESCRIPTION

	.EXAMPLE
		Example 1.
		Set_WindowSize 100 40
	#>
	Param(
		[Parameter(Mandatory=$true)][string]$DriveLetter
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





#$args[0]







function global:MakePath {
	Param(
		[Parameter(Mandatory=$true)][string]$Path
	)
	if(!(Test-Path -Path $Path ))
	{
		New-Item -ItemType Directory -Force -Path $Path
	}
	return $Path
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
	Param(
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
#READ_SETENV



function CheckParam{
	<#
	.SYNOPSIS

	.DESCRIPTION

	.EXAMPLE
		Example 1.

	#>
	Param(
		$Value,
		[int]$InputLength    = -1,
		[string]$CastType    = "string",
		[boolean]$Write_Host = $False
	)

	$SupportedCastType = @("string","int")
	if(-not $SupportedCastType -contains $($CastType).ToLower())
	{
		if($Write_Host)
		{
			Write-Host "Invalid CastType!, $Supported Cast Types: ($SupportedCastType)"
			Write-Host "Provided CastType: '$CastType'"
		}

		return 0
	}




	if (($InputLength -ne -1) -and ($Value.Length -ne $InputLength))
	{
		if($Write_Host)
		{
			Write-Host "Invalid String Length!, Expected Length ($InputLength) but received ($($Value.Length))"
			Write-Host "Entered Value: '$Value'"
		}

		return 0
	}


	try
	{
		#CHECKING FOR ERRORS, IF FOLLOWING COMMAND: iex FAILS, $ERROR.CLEAR() WILL REMOVE ALL ERRORS ENCOUNTERED
		CheckForErrors -Message "Please Contact Engineering!! `n`t  Unexpected Error has occurred"
		iex "`$Value = [$CastType]`$Value "
		#assign("last.warning", NULL, envir = baseenv())
	}
	catch
	{
		if($Write_Host)
		{
			Write-Host "Invalid Entry!, Expected input type ($CastType)"
			Write-Host "Entered Value: '$Value'"
		}
		$Error.clear()
		return 0
	}

	return 1
}






#TODO FIX -CastType Integer
Function global:RequestValue{
	<#
	.SYNOPSIS
		Function to request data from the user.
	.DESCRIPTION
		Preforms some InputLength Checking, If $InputLength flag set to -1, input length is ignored.
		Supported Types:
			-'String'  : String
			-'int'     : Integer
			-'float'   : float
	.EXAMPLE
		$Value = RequestValue -Message "Please Enter Value:"
	#>
	Param(
		[String]$Mode           = "Attention",
		[String]$Message        = "Missing Prompt",
		$PassThroughValue       = $NULL,
		[bool]$CheckInputPrompt = $False,
		[int]$InputLength       = -1,
		[string]$CastType       = "string"

	)
	#$Type.ToLower()

	if(($PassThroughValue -ne $NULL) -and (CheckParam -Value $PassThroughValue -InputLength $InputLength -CastType $CastType -Write_Host $False))
	{
		Write-Host "$Message : $PassThroughValue"
		return $PassThroughValue
	}

	Set_ScreenMode -Mode "$Mode"
	$AcceptedInput = $False
	$CorrectInput  = "Y"
	while(-not $AcceptedInput)
	{
		#Write-Host " "
		$GatheredInput = Read-Host -Prompt $Message

		if($CheckInputPrompt)
		{
			Write-Host "You Entered:'$GatheredInput'"
			$CorrectInput = Read-Host -Prompt "Is this Correct(Y/N)?"
		}


		if ($CorrectInput.ToLower() -eq "y" -and (CheckParam -Value $GatheredInput -InputLength $InputLength -CastType $CastType -Write_Host $True))
		{
			Write-Host "$Message : $GatheredInput" -InformationAction Ignore
			return $GatheredInput
		}

	}
	#cls
	#Set_ScreenMode -Mode "Information"

}


# ==========================================================
# ENTRY INFO
# ==========================================================




Function global:GetUSBDevices{
	<#
	.SYNOPSIS

	.DESCRIPTION

	.EXAMPLE

	#>
	$DiskList = Get-WmiObject -Class Win32_logicaldisk #Get-Disk # use get-psdrive -psprivider filesystem
	#$DiskList.Length
	#WmiObject
	$USBList = @()

	[int]$Count = 0
	foreach($Disk in $DiskList)
	{

		if (([int]$Disk.DriveType).equals(2))
		{
			<#
				$Disk.DriveType
				0 -- Unknown
				1 -- No Root directory
				2 -- Removable Disk
				3 -- Local Disk
				4 -- Network Drive
				5 -- Compact Disc
				6 -- Ram Disk
			#>
			$Count +=1
			$USBList += $Disk
			#@($Count, $USBList)
		}
	}
	return @($Count,$USBList)#For some reason returning a list of one and using .length is
}





Function CompareCheckSums{
	Param(
		[Parameter(Mandatory=$true)]$HashA,
		[Parameter(Mandatory=$true)]$HashB
	)
	<#
	.SYNOPSIS

	.DESCRIPTION

	.EXAMPLE
		CompareCheckSums -HashA "HELLO`n" -HashB "HELLO"
	#>
	$HashA = $HashA.tostring() #-replace "`n",""
	$HashB = $HashB.tostring() #-replace "`n",""

<# 	echo $HashA.equals($HashB)
	echo $HashA
	echo $HashB
	pause #>

	if ($HashA.equals($HashB))
	{
		return $True
	}
	else
	{
		return $False
	}


}


function Get-FolderHash ($folder){
	<#
	.SYNOPSIS

	.DESCRIPTION

	.EXAMPLE
		Get-FolderHash "C:\CustomFolder"
	#>

	try
	{
		write-host $folder
		pause
		dir $folder -Recurse | ?{!$_.psiscontainer} | %{[Byte[]]$contents += [System.IO.File]::ReadAllBytes($_.fullname)}
		$hasher = [System.Security.Cryptography.SHA1]::Create()
		[string]::Join("",$($hasher.ComputeHash($contents) | %{"{0:x2}" -f $_}))
	}
	catch
	{
		Display_Error_Message -message "Powershell's Get-FolderHash Failed"
		#Display_Error_Message -Mode "Failure" -Message "Please Contact Engineering" -Message2 "Powershell's Get-FolderHash Failed"
	}
}







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
	Param(
		[string]$Path
	)
	return Get-ChildItem "$Path" -Recurse -Directory
}

function CompareObjects{
	Param(
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
CompareFolderStructure -Path1 -Path2
	Returns $True if Folderstructure match
#>
function CompareFolderStructure{
	Param(
		[string]$Path1,
		[string]$Path2
	)
	$FolderChild1 = GetFolderStructureObject -Path $Path1
	$FolderChild2 = GetFolderStructureObject -Path $Path2
	return CompareObjects -Object1 $FolderChild1 -Object2 $FolderChild2
}


# ==========================================================
# OverWrite Existing Hash File
# ==========================================================
function SaveNewHashValue{
	if ($SaveArchive)
	{
		try
		{
			$Current_Hash = Get-FolderHash $Source_Archive
		}
		catch
		{
			Display_Error_Message -Message "Please Contact Engineering" -Message2 "Failed to generate HashValue from folder" -clearscreen $False
		}
		try
		{
			echo $Current_Hash > $Archived_HashFile
			Start-Sleep -Seconds 2
		}
		catch
		{
			Display_Error_Message -Message "Please Contact Engineering" -Message2 "Failed to Save File Hash File"
		}
	}
}



function VerifyHASH{
	Param(
		[string]$Path
	)
	#CompareHash -Path $Path

	Display_Message -Mode "Information" -Message "Checking CheckSum for Path:" -Message2 "`t'$Path'"
	Write-Host ""
	Write-Host "OverWriting CheckSum: $SaveArchive"
	Write-Host "Verifing Path:        '$Path'"




	try
	{
		$Current_Hash = Get-FolderHash $Path
	}
	catch
	{
		Write-Error "Failed to generate HashValue from folder"
		#Display_Error_Message -Message "Please Contact Engineering" -Message2 "Failed to generate HashValue from folder" -clearscreen $False
	}


	try
	{
		$Archived_Hash = [IO.File]::ReadAllText($Archived_HashFile).tostring() -replace "`n","" -replace ".$",""
	}
	catch
	{
		Display_Error_Message -Mode "Failure" -Message "Please Contact Engineering" -Message2 "Failed to Read File Hash '$Archived_HashFile' File"
	}


	Write-Host "Testing Hash: `t`'$Current_Hash`'  `t(Type: $($Current_Hash.GetType().name))"
	Write-Host "Archived Hash:`t`'$Archived_Hash`' `t(Type: $($Archived_Hash.GetType().name))"
	Start-Sleep -Seconds 4
	#pause
<# 	write-host $($Current_Hash.equals($Archived_Hash))
	Write-Host (CompareObjects -Object1 $Current_Hash -Object2 $Archived_Hash)
	pause #>
	return $($Current_Hash.equals($Archived_Hash))[0] # (CompareObjects -Object1 $Current_Hash -Object2 $Archived_Hash)
<# 	{


		Write-Host "VerifyHASH Passed"
		Write-Host CompareObjects -Object1 $Current_Hash -Object2 $Archived_Hash
		pause
		return $True
	}
	else
	{
		Write-Host "VerifyHASH Failed"
		Write-Host CompareObjects -Object1 $Current_Hash -Object2 $Archived_Hash
		pause
		return $False
	} #>
}



#Archived_FolderStructure
function VerifyFolderStructure{
	Param(
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


#PXE_XCOPY -Source S:\Path -Destination D:\
Function Verify_XCOPY{
	Param(
		[Parameter(Mandatory=$true)][String]$Source,
		[Parameter(Mandatory=$true)][String]$Destination
	)

	Display_Message -Mode "Information" -Message "Testing USB Checksum"
<# 	$VerifyHashTest = (VerifyHASH -Path $Destination)
	write-host " $VerifyHashTest "
	write-host "(Type: $($VerifyHashTest.GetType().name))"
	if($VerifyHashTest){write-host $True}else{}
	pause #>
	if((VerifyHASH -Path $Destination))
	{
		Display_Message -Mode "Information" -Message "USB Check Sum Test Passed"
	}
	else
	{
		Write-Error "Archived Check Sum Test Failed"
		#Display_Error_Message -Mode "Failure" -Message "Please Contact Engineering" -Message2 "Archived Check Sum Test Failed"
	}


	Display_Message -Mode "Information" -Message "Testing USB Folder structure"
<# 		$FolderStructureTest = (VerifyFolderStructure -Path $Destination)
	write-host $FolderStructureTest
	pause #>
	if((VerifyFolderStructure -Path $Destination))
	{
		Display_Message -Mode "Information" -Message "USB Folder structure Test: Passed"
	}
	else
	{
		Write-Error "USB Folder structure Test: Failed"
		#Display_Error_Message -Mode "Failure" -Message "Please Contact Engineering" -Message2 "USB Folder structure Test: Failed"
	}
}

#PXE_XCOPY -Source S:\Path -Destination D:\
#PXE_XCOPY
Function PS_XCOPY{
	Param(
		[Parameter(Mandatory=$true)][String]$Source,
		[Parameter(Mandatory=$true)][String]$Destination
	)
	<#
	.SYNOPSIS

	.DESCRIPTION

	.EXAMPLE
		PXE_XCOPY $Source $Destination
	#>

<# 	try
	{
		if(!(Test-Path -Path $Destination ))
		{
			New-Item -ItemType Directory -Force -Path $Destination
		}
		else
		{
			Display_Error_Message -message "Was Given an incorrect Destination folder:$Destination"
		}
	}
	catch
	{
		Display_Error_Message -message "Failed to create Destination folder:$Destination"
	}
 #>


	try
	{
		xcopy $Source $Destination /E /I /H /Y
	}
	catch
	{
		try
		{
			$lastexitcode = 0
			xcopy $Source $Destination"\" /E /I /H /Y
		}
		catch
		{
			Display_Error_Message -message "XCopy Failed"
		}
	}

}




Function PXE_XCOPY{
	Param(
		[Parameter(Mandatory=$true)][String]$Source,
		[Parameter(Mandatory=$true)][String]$Destination
	)
	<#
	.SYNOPSIS

	.DESCRIPTION

	.EXAMPLE
		PXE_XCOPY
	#>
	$XCopyAttempts = 0
	$MaxAttempts   = 3
	$AttemptXCOPY  = $True
	$Verify_CheckSum  = $True

	Display_Message -Mode "Information" -Message "Starting XCopy. Max Attempts: $MaxAttempts Attempts"
	while($AttemptXCOPY)
	{
		try
		{
			PS_XCOPY -Source $Source -Destination $Destination
			#CheckForErrors -Message "Please Contact Engineering `n`t  XCOPY Failed"

			Verify_XCOPY -Source $Source -Destination $Destination
			$AttemptXCOPY = $False
			#throw "Fail"
			#break
		}
		catch
		{
			Display_Message -Mode "Information" -Message "Failed to move Files $XCopyAttempts / $MaxAttempts Attempts" -Message2 "Error: $error"

			#Start-Sleep -Seconds 2
			$XCopyAttempts += 1
		}


		if ($XCopyAttempts -ge $MaxAttempts)
		{
			Display_Error_Message -Mode "Failure" -Message "Please Contact Engineering" -Message2 "Failed to move Files $XCopyAttempts / $MaxAttempts Attempts" -Message2 "Error: $error"
		}
	}
	#As XCOPY is attempted several times,
	$Error.clear()

}

Function PS_XCOPY_CheckSum{
	Param(
		[Parameter(Mandatory=$true)][String]$Source,
		[Parameter(Mandatory=$true)][String]$Destination,
		[Parameter(Mandatory=$true)][String]$Source_HashCode
	)
	<#
	.SYNOPSIS

	.DESCRIPTION

	.EXAMPLE
		PXE_XCOPY
	#>
	$XCopyAttempts = 0
	$MaxAttempts   = 3
	$AttemptXCOPY  = $True
	$Verify_CheckSum  = $True

#	PXE_XCOPY $Source $Destination
#	$Source_Hash  = Get-FolderHash $Destination
	
	while($AttemptXCOPY)
	{
		try
		{
			PS_XCOPY -Source $Source -Destination $Destination
			#CheckForErrors -Message "Please Contact Engineering `n`t  XCOPY Failed"
			

			$Destination_HashCode = Get-FolderHash "$($Destination)"
			if((CompareCheckSums $Source_HashCode $Destination_HashCode))
			{
				$AttemptXCOPY = $False
				write-host "Files were copied successfully"
				write-host "`tSource_HashCode:      $Source_HashCode" 
				write-host "`tDestination_HashCode: $Destination_HashCode"
			}
			else
			{
				#Clear Results Folder
				Get-ChildItem -Path $Destination -Include *.* -File -Recurse | foreach { $_.Delete()}
				XCopyAttempts+=1
				
			}
			
			#throw "Fail"
			#break
		}
		catch
		{
			Display_Message -Mode "Information" -Message "Failed to move Files $XCopyAttempts / $MaxAttempts Attempts" -Message2 "Error: $error"

			#Start-Sleep -Seconds 2
			$XCopyAttempts += 1
		}


		if ($XCopyAttempts -ge $MaxAttempts)
		{
			Display_Error_Message -Mode "Failure" -Message "Please Contact Engineering" -Message2 "Failed to move Files $XCopyAttempts / $MaxAttempts Attempts" -Message2 "Error: $error"
		}
	}
	
}



