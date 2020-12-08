# ===================================================================================================
# DESCRIPTION:
# 
# ===================================================================================================









function Using-WinPE
{
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



# ==========================================================
# RESIZE COMMAND PROMPT WINDOW
# ==========================================================
Function global:Set_WindowSize {
	<#
	.SYNOPSIS
		Simple function that Changes the size of the window to X Y values.
	.DESCRIPTION
		
	.EXAMPLE
		Example 1.
		Set_WindowSize 100 40
	#>
	Param(
		[int]$x=$host.ui.rawui.windowsize.width,
		[int]$y=$host.ui.rawui.windowsize.height
	)
		


	try
	{
<# 		$size=New-Object System.Management.Automation.Host.Size($X,$Y)
		$Script:host.ui.rawui.WindowSize=$size
		pause #>
		
		
		$pshost = get-host
		$pswindow = $pshost.ui.rawui
		$newsize = $pswindow.buffersize
		<# $newsize.height = $Y
		$newsize.width = $X
		$pswindow.buffersize = $newsize #>
		$newsize = $pswindow.windowsize
		$newsize.height = $Y
		$newsize.width = $X
		$pswindow.windowsize = $newsize
		write-host "Set screen size to: Width: $($host.ui.rawui.windowsize.width) Height:$($host.ui.rawui.windowsize.height)"
	}
	catch
	{
		#Display_Error_Message -message "Could not Resize Window"
	} 
}





# ==========================================================
# SCREEN COLOR
# ==========================================================
Function global:Set_ScreenMode{
	<#
	.SYNOPSIS
		This Function changes the terminal's color depending on the different display Mode.
	.DESCRIPTION
		Allows the terminal to display different colors to quickly convay the current state of 
		the script. Here are the different avaliable modes:
			# Screen Color Definition:
			# "Information" = blue
			# "Pass"        = green
			# "Attention"   = yellow 
			# "Failure"     = red
			# "Retry"       = aqua
	.EXAMPLE
		Set_ScreenMode -Mode "Retry"
	#>
	Param(
		[String]$Mode="Information"
	)
	
	switch -Regex ($Mode)
	{
		"Information"
			{
				$host.ui.rawui.backgroundcolor = "Blue"
				$host.ui.rawui.foregroundcolor = "White"
				
			}
		"Pass"
			{
				$host.ui.rawui.backgroundcolor = "Green"
				$host.ui.rawui.foregroundcolor = "Black"	
				#cls	
			}
		"Attention"
			{
				$host.ui.rawui.backgroundcolor = "Yellow"
				$host.ui.rawui.foregroundcolor = "Black"
				#cls
			}
		"Failure"
			{
				$host.ui.rawui.backgroundcolor = "DarkRed"
				$host.ui.rawui.foregroundcolor = "White"
				#cls
			}
		"Retry"
			{
				$host.ui.rawui.backgroundcolor = "Cyan"
				$host.ui.rawui.foregroundcolor = "Black"
				#cls
			}
		default 
			{
				#cls
				#echo "Invalid Mode! Please read Set_ScreenMode SYNOPSIS"
				Display_Error_Message -Message "Could not Initialize UnixUtils"
			}
	}

	
}
#Set_ScreenMode -Mood "Information"


# ==========================================================
# Terminal Messages
# ==========================================================
Function global:Display_Message{
	<#
	.SYNOPSIS
		This Function Prepares a GUI for adding Network drives to a system.
	.DESCRIPTION
		More indepth explination of the given function, and the underlining operations
	.EXAMPLE
		Display_Message -Mode "Retry" -Message "Looking Good"
	#>
	Param(
		[String]$Mode        = "Information",
		[String]$Message     = "Add Message",
		[String]$Message2    = "   ",
		[String]$Message3    = "   ",
		$ErrorMessages       = $False,
		$Pause               = $False,
		$SleepFor            = $DefaultStartSleep,
		[bool]$ClearScreen   = $True,
		[bool]$SetScreenMode = $True
	)
	if($SetScreenMode)
	{
		Set_ScreenMode -Mode "$Mode"
	}
	
	if($ClearScreen)
	{
		cls
	}
	write-host "`n`n"
	write-host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!`n"
	write-host "       $Message `n"
	write-host "       $Message2 `n"
	write-host "       $Message3 `n"
	write-host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!`n"

	
	
	if($Pause)
	{
		Pause
	}
	
	Start-Sleep -Seconds $SleepFor
	
}

Function global:Display_Error_Message{
	<#
	.SYNOPSIS
		Function to display Error, and Halt Program.
	.DESCRIPTION
		
	.EXAMPLE
		Display_Message -Mode $Mode -Message $Message -Message2 $Message2 -Message3 "An error has occured" -ErrorMessage $Error -ClearScreen $ClearScreen -SleepFor 0
	#>
	Param(
		[String]$Mode="Failure",
		[String]$Message=" Add Message",
		[String]$Message2="Contact Engineering!",
		[Boolean]$ClearScreen=$True,
		[Boolean]$Pause=$True
	)

	#Stop-Transcript
	write-hoost $Manifest
	pause
	while($true)
	{
		Display_Message -Mode $Mode -Message $Message -Message2 $Message2 -Message3 "Script: $SelfFile has encountered an issue." -ErrorMessage $Error -ClearScreen $ClearScreen -SleepFor 0

			#(new-Object Management.Automation.Host.ChoiceDescription "&Terminal","Start Terminal"),
		$choices = [Management.Automation.Host.ChoiceDescription[]] ( `
			(new-Object Management.Automation.Host.ChoiceDescription "&View","View Errors/Warnings"),
			(new-Object Management.Automation.Host.ChoiceDescription "&Logs","View Logs"),
			(new-Object Management.Automation.Host.ChoiceDescription "&Folder","Open Scripts Folder"),
			(new-Object Management.Automation.Host.ChoiceDescription "&Results","Open Results Folder"),
			(new-Object Management.Automation.Host.ChoiceDescription "&Shutdown","Shutdown System"),
			(new-Object Management.Automation.Host.ChoiceDescription "&Restart","Restart System"));
		$answer = $host.ui.PromptForChoice("","Select one of the following options:",$choices,0)
		switch -Regex ($answer)
		{
			0 #default 
				{
					if ($Error)
					{
						write-host "------------------------------------------------------------------------------"
						write-host "Errors/Warnings:"
						write-host ""
						$Count = 0
						foreach ($ErrorMessage in $Error)
						{
							$Count++
							#$line = $_.InvocationInfo.ScriptLineNumber
							write-host "[$Count]Line $($ErrorMessage.InvocationInfo.ScriptLineNumber): $ErrorMessage"
							
						}
						write-host "------------------------------------------------------------------------------"
					}
					pause
					#Display_Message -mode "Failure" -Message "No Option was selected please try again." -SleepFor 3 
				}
			
			1 #"View Logs"
				{
					#Get-EventLog -List
					write-host "iex '$LocalLogs'"
					iex "notepad $LocalLogs"
				}
			2 #"Open Source Folder"
				{
					#Get-EventLog -List
					ii $SelfFolder
				}
			3 #"Open Results Folder"
				{
					#Get-EventLog -List
					ii $ResultPath
				}
			4 #"Shutdown"
				{
					Display_Message -Message "System Shutdown Selected"
				
					#stop-computer 
					Write-Host -Object "Shuting down ......"
					Start-sleep -s 20
				}
			5 #"Restart"
				{
					Display_Message -Message "System Restart Selected"
					
					#restart-computer 
					Write-Host -Object "Rebooting ......"
					Start-sleep -s 20
				}

		}
		#cmd /c pause | out-null
		
	}
	ExitWithCode -exitcode 1
}







Function CheckForErrors{
	<#
	.SYNOPSIS
		Function to display Error, and Halt Program.
	.DESCRIPTION
		
	.EXAMPLE
		Display_Error_Message -Message "Something Went wrong" 
	#>
	Param(
		[String]$Mode="Failure",
		[String]$Message=" Add Message",
		[String]$Message2="Contact Engineering!",
		[Boolean]$ClearScreen=$True,
		[Boolean]$Pause=$True
	)

	if($lastexitcode -or $Error)
	{
		if($lastexitcode)
		{
			$Message2="lastexitcode: $lastexitcode"
		}
		Display_Error_Message -Mode $Mode -Message $Message -Message2 $Message2 -ClearScreen $ClearScreen -Pause $Pause
	}
}


# ==========================================================
# Parse IniFile
# ==========================================================
Function Parse-IniFile ($File) {
	if((Test-Path $File) -eq $False){
		Display_Error_Message -Mode "Failure" -Message "ini File:$File missing" -Message2 "Please Contact Engineering"
	}
	
  $ini = @{}

  # Create a default section if none exist in the file. Like a java prop file.
  $section = "NO_SECTION"
  $ini[$section] = @{}

  switch -regex -File $File {
    "^\[(.+)\]$" {
      $section = $matches[1].Trim()
      $ini[$section] = @{}
    }
    "^\s*([^#].+?)\s*=\s*(.*)" {
      $name,$value = $matches[1..2]
      # skip comments that start with semicolon:
      if (!($name.StartsWith(";"))) {
        $ini[$section][$name] = $value.Trim()
      }
    }
  }
  return $ini
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
		PXE_XCOPY
	#>
	
	try
	{
		if(!(Test-Path -Path $Destination ))
		{
			New-Item -ItemType Directory -Force -Path $Destination
		}
	}
	catch
	{
		Display_Error_Message -message "Failed to create Destination folder:$Destination"
	}
	
	
	
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
			$XCopyAttempts+=1	
		}
		
		
		if ($XCopyAttempts -ge $MaxAttempts)
		{
			Display_Error_Message -Mode "Failure" -Message "Please Contact Engineering" -Message2 "Failed to move Files $XCopyAttempts / $MaxAttempts Attempts" -Message2 "Error: $error"
		}
	}
	#As XCOPY is attempted several times, 
	$Error.clear()

}




# ==========================================================
# Log EXIT: Delete duplicate entries & write to scripts.log
# ==========================================================

Function ImageDrive{
	<#
	.SYNOPSIS
		
	.DESCRIPTION
		Short Function to Image USB drive and create Log files.
	.EXAMPLE
		ImageDrive -OrderNumber 12345678 -CID 88888887 -Source_Archive T:\88888887\Scripts\USB_Contents -ResultPath "U:\88888887\10718239"
		ImageDrive -OrderNumber $OrderNumber -CID $CID -Source_Archive $Source_Archive -ResultPath $ResultPath
	#>
	Param(
		[int]$OrderNumber,
		[int]$CID,
		[string]$Source_Archive,
		[string]$ResultPath
	)


<#   	while ($(GetUSBDevices)[0] -ne 0)
	{	
		$Message1 = "Please Remove USB Storage"
		$Message2 = "Devices Found:"+((GetUSBDevices)[0]).ToString()
		Display_Message -Mode "Attention" -Message $Message1  -Message2 $Message2 -Pause "Pause"
	}   #>
	
	
	#Verify that the one(1) USBs (BOM ITEM) is connected to computer
	while ($(GetUSBDevices)[0] -ne 1)
	{
		Display_Message -Mode "Retry" -Message "Please Connect one USB BOM Item" -Message2 "press any key to continue" -Pause "Pause"
	} 
	Display_Message -Mode "Pass" -Message "Detected USB Please wait"


	try 
	{
		$USB         = ([string]$(GetUSBDevices)[1].DeviceID)
		#PXE_XCOPY -Source $Source_Archive -Destination $USB
		PXE_XCOPY -Source $Source_Archive -Destination $USB
		Display_Message -Mode "Pass" -Message "Finished Copying Files to USB" -Message2 ""
	}
	catch 
	{
		Display_Error_Message -Mode "Failure" -Message "Please Contact Engineering" -Message2 "XCOPY Failed"
	}
	
	
	$DevSerial = $(gwmi Win32_USBControllerDevice |%{[wmi]($_.Dependent)} | Where-Object {($_.Description -like '*mass*')} ).DeviceID.split("\")[-1]
	
	if(!(Test-Path -Path $ResultPath ))
	{
		New-Item -ItemType Directory -Force -Path $ResultPath
	}
	$ResultPath = $ResultPath+"\"+$DevSerial.ToString()

	#$ResultsPath = $ResultsPath+$DrivesImaged.ToString()+"\"

	if(!(Test-Path -Path $ResultPath ))
	{
		New-Item -ItemType Directory -Force -Path $ResultPath
	}

	

	try 
	{
		$Drive = (GetUSBDevices)[1]
		$LogPath = $ResultPath+"\Results.log"
		" ----------------------------------------------------------------------- " > $LogPath
		"Imaged On:             "+(Get-Date) >> $LogPath
		"CID:                   "+$CID.ToString() >> $LogPath
		"OrderNumber:           "+$OrderNumber.ToString() >> $LogPath
		"SerialNumber:          "+$DevSerial.ToString() >> $LogPath
		" ----------------------------------------------------------------------- " >> $LogPath
		"DriveType:             "+$Drive.DriveType >> $LogPath
		"Size:                  "+$Drive.Size >> $LogPath
		"FreeSpace:             "+$Drive.FreeSpace >> $LogPath
		"VolumeName:            "+$Drive.VolumeName >> $LogPath
		"  " >> $LogPath

		" ----------------------------------------------------------------------- " >> $LogPath
		"DriveType Key:
		0 -- Unknown
		1 -- No Root directory
		2 -- Removable Disk
		3 -- Local Disk
		4 -- Network Drive
		5 -- Compact Disc
		6 -- Ram Disk" >> $LogPath
		" ----------------------------------------------------------------------- " >> $LogPath
		"Files Moved to Drive:  " >> $LogPath
		dir -r $Drive.DeviceID | % { if ($_.PsIsContainer) { $_.FullName + "\" } else { $_.FullName } } >> $LogPath
		
		" ----------------------------------------------------------------------- " >> $LogPath
		"Files From Archived Folder:"+$Source_Archive.ToString()>> $LogPath
		dir -r $Source_Archive | % { if ($_.PsIsContainer) { $_.FullName + "\" } else { $_.FullName } } >> $LogPath
		" ----------------------------------------------------------------------- " >> $LogPath
	}
	catch 
	{
		Display_Error_Message -Mode "Failure" -Message "Please Contact Engineering" -Message2 "Failed to save Logs. " 
	}


 	#Verify that all USBs (BOM ITEM) have been removed from the computer
	#Display_Message -Mode "Attention" -Message "Finished Moving Files" -Message2 "Please Remove USB Drive" -Pause "Pause"
	while ($(GetUSBDevices)[0] -ne 0)       
	{
		Display_Message -Mode "Attention" -Message "Finished Moving Files" -Message2 "Please Remove USB Drive" -Pause "Pause"
	}  

}


#====================================================================================================
# GUI Functions
#====================================================================================================
Function Add_Label{
	[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
	[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
	Add-Type -AssemblyName System.Windows.Forms
}




#====================================================================================================
# Add_Label
#====================================================================================================
Function Add_Label{
	[OutputType([string])]
	Param (
		[Parameter(Mandatory=$True)]$Form,
		[Parameter(Mandatory=$True)][int]$XAxis,
		[Parameter(Mandatory=$True)][int]$YAxis,
		[Parameter(Mandatory=$True)]$UniqueLabel,
		[Parameter(Mandatory=$false)]$Text = "Give Me Text",
		[Parameter(Mandatory=$false)]$Width=150,
		[Parameter(Mandatory=$false)]$Height=20,
		[Parameter(Mandatory=$false)]$AutoSize=$false,
		[Parameter(Mandatory=$false)]$Font='Microsoft Sans Serif,8'
	)
	<#
	.SYNOPSIS
		
	.DESCRIPTION
		
	.EXAMPLE
		$Label_Obj   = Add_Label -Form $Form -XAxis 10  -YAxis 510 -UniqueLabel "VisualConfirmation" -Text "Visual Confirmation"  -Width 200
	#>
		$S1 = "`$global:Label_$($UniqueLabel)            = New-Object system.Windows.Forms.Label";
		iex "$S1";    #echo $S1;
		$S2 = "`$global:Label_$($UniqueLabel).Text       = '$Text'";
		iex "$S2";    #echo $S2;    
		$S3 = "`$global:Label_$($UniqueLabel).AutoSize   = `$false";
		iex "$S3";    #echo $S3;
		$S4 = "`$global:Label_$($UniqueLabel).width      = $Width";
		iex "$S4";    #echo $S4;
		$S5 = "`$global:Label_$($UniqueLabel).height     = $Height";
		iex "$S5";    #echo $S5;    
		$S6 = "`$global:Label_$($UniqueLabel).location   = New-Object System.Drawing.Point($XAxis,$YAxis)";
		iex "$S6";    #echo $S6;
		$S7 = "`$global:Label_$($UniqueLabel).Font       = '$Font'";
		iex "$S7";    #echo $S7;    
		
            

		
		$S10 = "`$Form.controls.AddRange(@(`$global:Label_$($UniqueLabel)))";
		iex "$S10";    #echo $S10; 
		
		$oReturn = "Label_$($UniqueLabel)"
		return $oReturn
	}

#====================================================================================================
# Add_PictureBox
#====================================================================================================
Function Add_PictureBox{
	[OutputType([string])]
	Param (
		[Parameter(Mandatory=$True)]$Form,
		[Parameter(Mandatory=$True)][int]$XAxis,
		[Parameter(Mandatory=$True)][int]$YAxis,
		[Parameter(Mandatory=$True)]$UniqueLabel,
		[Parameter(Mandatory=$false)]$location = "X:\VisualInspection.JPG",
		[Parameter(Mandatory=$false)][int]$Width=500,
		[Parameter(Mandatory=$false)][int]$Height=500
	)
	<#
	.SYNOPSIS
		
	.DESCRIPTION
		
	.EXAMPLE
		$CheckBox_Obj   = Add_CheckBox -Form $Form -XAxis 10  -YAxis 510 -UniqueLabel "VisualConfirmation" -Text "Visual Confirmation"  -Width 200
	#>
	if(!(Test-Path -Path $location))
	{
		Display_Error_Message -Message "Please Contact Engineering" -Message2 "Missing Image"
	}
	
	$S1 = "`$global:PictureBox_$($UniqueLabel)                   = New-Object system.Windows.Forms.PictureBox";
	iex "$S1";   write-host $S1;
	$S2 = "`$global:PictureBox_$($UniqueLabel).imageLocation     = '$location'";
	iex "$S2"; 	 write-host $S2;
	$S4 = "`$global:PictureBox_$($UniqueLabel).width             = $Width";
	iex "$S4";   write-host $S4; 
	$S5 = "`$global:PictureBox_$($UniqueLabel).height            = $Height";
	iex "$S5";   write-host $S5;     
	$S6 = "`$global:PictureBox_$($UniqueLabel).location          = New-Object System.Drawing.Point($XAxis,$YAxis)";
	iex "$S6"; 	 write-host $S6;
	$S7 = "`$global:PictureBox_$($UniqueLabel).SizeMode          = [System.Windows.Forms.PictureBoxSizeMode]::zoom";
	iex "$S7";   write-host $S7;	
	$S8 = "`$Form.controls.AddRange(@(`$global:PictureBox_$($UniqueLabel)))";
	iex "$S8";	 write-host "$S8";
	$oReturn = "PictureBox_$($UniqueLabel)"
	return $oReturn
	}

#====================================================================================================
# Add_CreateButton
#====================================================================================================
Function Add_Button{
	[OutputType([string])]
	Param (
		[Parameter(Mandatory=$True)]$Form,
		[Parameter(Mandatory=$True)][int]$XAxis,
		[Parameter(Mandatory=$True)][int]$YAxis,
		[Parameter(Mandatory=$True)]$Width=150,
		[Parameter(Mandatory=$True)]$Height=20,
		[Parameter(Mandatory=$True)]$UniqueLabel,
		[Parameter(Mandatory=$false)]$Text = "Give Me Text",
		[Parameter(Mandatory=$false)]$Font='Microsoft Sans Serif,10',
		[Parameter(Mandatory=$false)]$FontSize=10,
		$OnClick
	)
	<#
	.SYNOPSIS
		
	.DESCRIPTION
		
	.EXAMPLE
		$Button_Obj = Add_Button -Form $Form -XAxis 10  -YAxis 10 -UniqueLabel "Verify" -Text "Press Me" -Height 100 -Width 200
	#>
	
	$S1 = "`$global:Button_$($UniqueLabel)                   = New-Object system.Windows.Forms.Button";
	iex "$S1";   write-host $S1;
	$S2 = "`$global:Button_$($UniqueLabel).text              = `"$Text`"";
	iex "$S2"; 	 write-host $S2;
	$S4 = "`$global:Button_$($UniqueLabel).width             = $Width";
	iex "$S4";   write-host $S4; 
	$S5 = "`$global:Button_$($UniqueLabel).height            = $Height";
	iex "$S5";   write-host $S5;     
	$S6 = "`$global:Button_$($UniqueLabel).location          = New-Object System.Drawing.Point($XAxis,$YAxis)";
	iex "$S6"; 	 write-host $S6;
	$S7 = "`$global:Button_$($UniqueLabel).Font              = New-Object System.Drawing.Font('$Font',$FontSize) ";
	iex "$S7";   write-host $S7;	
	$S8 = "`$global:Button_$($UniqueLabel).ForeColor   = [System.Drawing.ColorTranslator]::FromHtml(`"#000000`")";
	iex "$S8";    #echo $S8;
	$S9 = "`$global:Button_$($UniqueLabel).BackColor       = [System.Drawing.ColorTranslator]::FromHtml(`"#fcfcfc`")";
	iex "$S9";    #echo $S9;   
	$oReturn = "Button_$($UniqueLabel)"

	$RUNString = "`$global:Button_$($UniqueLabel).Add_Click({
		$OnClick
	})"

	write-host $RunString 
	iex $RunString 
	#pause
	$S8 = "`$Form.controls.AddRange(@(`$global:Button_$($UniqueLabel)))";
	iex "$S8";	 write-host "$S8";


	return $oReturn
	}


#====================================================================================================
# Add_CheckBox
#====================================================================================================
Function Add_CheckBox{
	[OutputType([string])]
	Param (
		[Parameter(Mandatory=$True)]$Form,
		[Parameter(Mandatory=$True)][int]$XAxis,
		[Parameter(Mandatory=$True)][int]$YAxis,
		[Parameter(Mandatory=$True)]$UniqueLabel,
		[Parameter(Mandatory=$false)]$Text = "Give Me Text",
		[Parameter(Mandatory=$false)][int]$Width=150,
		[Parameter(Mandatory=$false)][int]$Height=20,
		[Parameter(Mandatory=$false)]$AutoSize=$false,
		[Parameter(Mandatory=$false)]$Font='Microsoft Sans Serif,10'
	)
	<#
	.SYNOPSIS
		
	.DESCRIPTION
		
	.EXAMPLE
		$Box_Obj = Add_CheckBox -Form "this.AddNetworkDrivesForm" -XAxis 10  -YAxis $YSlide -UniqueLabel $DriveCount -Text "$($Letter) :$Address"  -Width 200
	#>
		$S1 = "`$global:CheckBox_$($UniqueLabel)                   = New-Object system.Windows.Forms.CheckBox";
		iex "$S1";   #write-host $S1;
		$S2 = "`$global:CheckBox_$($UniqueLabel).text              = '$Text'";
		iex "$S2";   #write-host $S2;
		$S3 = "`$global:CheckBox_$($UniqueLabel).AutoSize          = `$$($AutoSize)";
		
		iex "$S3";   #write-host $S3;     
		$S4 = "`$global:CheckBox_$($UniqueLabel).width             = $Width";
		iex "$S4";   #write-host $S4; 
		$S5 = "`$global:CheckBox_$($UniqueLabel).height            = $Height";
		iex "$S5";   #write-host $S5;     
		$S6 = "`$global:CheckBox_$($UniqueLabel).location          = New-Object System.Drawing.Point($XAxis,$YAxis)";
		iex "$S6"; 	 #write-host $S6;
		$S7 = "`$global:CheckBox_$($UniqueLabel).Font              = New-Object System.Drawing.Font('$Font',10)";
		iex "$S7";   #write-host $S7;	
		$S8 = "`$Form.controls.AddRange(@(`$CheckBox_$($UniqueLabel)))";
		iex "$S8";	 write-host "$S8";
		$oReturn = "CheckBox_$($UniqueLabel)"
		#$S8 = "`$Form.controls.AddRange(@(`$oReturn))";
		#iex "$S8";   write-host $S8;	
		return $oReturn
	}



function CallVisualInspection{
	<#
	.SYNOPSIS
		
	.DESCRIPTION
		Short Function to Image USB drive and create Log files.
	.EXAMPLE
		CallVisualInspection -ImagePath "X:\" -TagPath "X:\VisualInspection.tag"
	#>
	Param(
		[string]$ImagePath = "X:\VisualInspection.JPG",
		[string]$TagPath   = "X:\VisualInspection.tag"
		
	)

	
	$Form = New-Object System.Windows.Forms.Form
	$Form.ClientSize                 = New-Object System.Drawing.Point(750,600)
	$Form.BackColor                  = [System.Drawing.ColorTranslator]::FromHtml("#f8e71c")
	#$checkBox1 = New-Object System.Windows.Forms.CheckBox
	#$button1    = New-Object System.Windows.Forms.Button
 
	$Title_Obj        = Add_Label      -Form $Form -XAxis 250 -YAxis 5   -UniqueLabel "Title" -Text "Visual Inspection" -Height 45 -Width 500 -Font 'Microsoft Sans Serif,30'
	$Instruction_Obj  = Add_Label      -Form $Form -XAxis 50  -YAxis 50  -UniqueLabel "Instruction" -Text "Please Preform the following Visual Inspection: " -Height 25 -Width 1000 -Font 'Microsoft Sans Serif,15'
	$Description_Obj  = Add_Label      -Form $Form -XAxis 75  -YAxis 75  -UniqueLabel "Description" -Text "Please confirm the following LED is blinking Green/Yellow.`nAfter checking, Click the `"Visual Confirmation`" CheckBox, and Validate Button below."  -Height 50 -Width 1000 -Font 'Microsoft Sans Serif,13'#
	$PictureBox_Obj   = Add_PictureBox -Form $Form -XAxis 1   -YAxis 125 -UniqueLabel "VisualConfirmationIMG" -Width 750 -Height 400 -location $ImagePath
	$CheckBox_Obj     = Add_CheckBox   -Form $Form -XAxis 225 -YAxis 550 -UniqueLabel "VisualConfirmation" -Text "Visual Confirmation" -Width 175 

	$OnClick = 	"If (`$$($CheckBox_Obj).Checked -eq `$true){
		echo `".`"> $TagPath ; 
		`$Form.Close() | Out-Null ;
	}"

	$Button_Obj       = Add_Button     -Form $Form -XAxis 400 -YAxis 540 -UniqueLabel "Verify" -Text "Validate" -Height 40 -Width 200 -FontSize 20 -OnClick $OnClick
	#VisualConfirmation_Button_Code = {}
	#iex
	
	$Form.ShowDialog()| Out-Null
}











