# ==========================================================
# DESCRIPTION:
#
# ==========================================================
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted
#[String]$script:ManifestPath     = $args
#write-host "Manifest:$script:ManifestPath args:$args"

$Working_Archive = ""
# ==========================================================
# Command Line Parameters
# Import:
#     Import-Module ErrorHandling.ps1
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

<#
Get-WmiObject Win32_DiskDrive | ForEach-Object {
  $disk = $_
  $partitions = "ASSOCIATORS OF " +
                "{Win32_DiskDrive.DeviceID='$($disk.DeviceID)'} " +
                "WHERE AssocClass = Win32_DiskDriveToDiskPartition"
  Get-WmiObject -Query $partitions | ForEach-Object {
    $partition = $_
    $drives = "ASSOCIATORS OF " +
              "{Win32_DiskPartition.DeviceID='$($partition.DeviceID)'} " +
              "WHERE AssocClass = Win32_LogicalDiskToPartition"
    Get-WmiObject -Query $drives | ForEach-Object {
      New-Object -Type PSCustomObject -Property @{
        Disk        = $disk.DeviceID
        DiskSize    = $disk.Size
        DiskModel   = $disk.Model
        Partition   = $partition.Name
        RawSize     = $partition.Size
        DriveLetter = $_.DeviceID
        VolumeName  = $_.VolumeName
        Size        = $_.Size
        FreeSpace   = $_.FreeSpace
      }
    }
  }
}
#>



<#
function Create-BootableUSBStick {

# .SYNOPSIS
# Create-BootableUSBStick is an advanced PowerShell function to create a bootable USB stick for the installation of Windows OS.

# .DESCRIPTION
# The main idea is to avoid the use of 3rd party tools or tools like the Windows 7 USB tool.

# .PARAMETER
# USBDriveLetter
# Mandatory. Provide the drive letter where your usb is connected

# .PARAMETER
# ImageFiles
# Mandatory. Enter the drive letter of your mounted ISO (OS Files)

# .EXAMPLE
# Create-BootableUSBStick -USBDriveLetter F: -ImageFiles D:

# .NOTES
# Author:Patrick Gruenauer
# Web:https://sid-500.com
# https://sid-500.com/2019/01/08/create-a-bootable-usb-stick-with-powershell-create-bootableusbstick/

[CmdletBinding()]

param

(

[Parameter()]
$USBDriveLetter,

[Parameter()]
$ImageFiles

)

$USBDriveLetterTrim=$USBDriveLetter.Trim(':')

Format-Volume -FileSystem NTFS -DriveLetter $USBDriveLetterTrim -Force

bootsect.exe /NT60 $USBDriveLetter

xcopy ($ImageFiles +'\') ($USBDriveLetter + '\') /e

Invoke-Item $USBDriveLetter

}
#>


<#

#>


<#
((@"
Rescan
List Disk
Select Disk 1
List Partition
"@
)|diskpart)


$DiskNumber = 0
((@"
Rescan
List Disk
Select Disk $DiskNumber
List Partition
"@
)|diskpart)




$DiskNumber = 0
((@"
Rescan
List Disk
Select Disk $DiskNumber
format fs=ntfs quick unit=4096
convert mbr
"@
)|diskpart)
$part=gwmi Win32_DiskPartition -filter 'name="Disk #$DiskNumber, Partition #0"'
$part.GetRelated('Win32_LogicalDisk')|select DeviceID
label $DriveLetter "Win_PE_Console"
#>

class Disk {
    <#
  	.SYNOPSIS

  	.DESCRIPTION

  	.EXAMPLE1
			$Disks = get-disk
			[Disk]$global:Disk = [Disk]::new($Disk[0])
	
  	#>
	$AssignedLetter
	$Disk
	
	Disk([CimInstance]$Disk){
		$this.Disk = $Disk
    }
	

	
	[string]GetAvailableDriveLetter(){
			$AllLetters = 65..90 | ForEach-Object {[char]$_}
			$UsedLetters = get-wmiobject win32_logicaldisk | select -expand deviceid
			$FreeLetters = $AllLetters | Where-Object {$UsedLetters -notcontains $_}
			#write-host $FreeLetters
			return $FreeLetters | select-object -first 1
		#Following only filters local Drives
		#ls function:[d-z]: -n | ?{ !(test-path $_) } | random
	}
	
	[void]PrepDisk(){
		$DriveLetter = $this.GetAvailableDriveLetter().toString()

		$this.Disk | Clear-Disk -RemoveData -RemoveOEM -Confirm:$false -PassThru



		CheckForErrors -Message "Something unexpected happened"
		$this.Disk | Initialize-Disk -PartitionStyle MBR >$null 2>&1
		$global:error.clear()

		$this.Disk | New-Partition -UseMaximumSize -IsActive -DriveLetter $DriveLetter
		CheckForErrors -Message "Failed to create new partition:New-Partition"
		
		Format-Volume -FileSystem 'NTFS' -DriveLetter $DriveLetter -AllocationUnitSize 4096
		CheckForErrors -Message "Failed to Format-Volume"
		
		Set-Volume -NewFileSystemLabel "Win_PE_Console" -DriveLetter $DriveLetter
		CheckForErrors -Message "Failed to Set-Volume"

		$this.AssignedLetter += $DriveLetter		
	}
	[void] ApplyFolderContents($Source){
		$JOBS = @()
		foreach($DriveLetter in $this.AssignedLetters)
		{
			#-WorkingDirectory "$DIR"
			$XCOPY_CodeBlock = {
				Param(
						$Location,
						$Source,
						$DriveLetter
					)
				import-module "$Location\SystemTools.ps1"
				PS_XCOPY -Source "$Source\*" -Destination "$($DriveLetter):"
			}

			$JOBS += Start-Job -scriptblock $XCOPY_CodeBlock -ArgumentList "$global:DIR", "$Source", "$DriveLetter"
		}


		foreach($JOB in $JOBS)
		{
			$VAR = Receive-Job -Job $job -Keep #6>&1

			$JOB | Wait-Job
		}

		while($JOBS[0].state -eq "Running")
		{
			#write-host "Running"
		}
		#CheckJobsForErrors $JOBS

	}
	
	[string]GenerateLog()
	{
		$Logs = ""
		try
		{
			
<# 				$Drive = (GetUSBDevices)[1]
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
			" ----------------------------------------------------------------------- " >> $LogPath #>
		}
		catch
		{
			Display_Error_Message -Mode "Failure" -Message "Please Contact Engineering" -Message2 "Failed to save Logs. "
		}
		return $Logs
	}
}



class DiskManagement {
    <#
  	.SYNOPSIS

  	.DESCRIPTION

  	.EXAMPLE

  	#>
	$FilteredDisks = @()
	$FilterOptions
	DiskManagement([hashtable]$FilterOptions){
	<#
      .SYNOPSIS
      .DESCRIPTION
      .EXAMPLE
			Filter options example: $FilterOptions = @{"BusType"="USB"}
			[DiskManagement]$global:DiskManagement = [DiskManagement]::new(@{"BusType"="USB"})
    #>
		$this.FilterOptions = $FilterOptions

		#write-host $this.FilteredDisks
		$this.Select_Disks($FilterOptions)
		#write-host $this.FilteredDisks
		#pause
    }
	[void] Select_Disks([hashtable]$FilterOptions){
		<#
		.SYNOPSIS
		.DESCRIPTION
			Preps DiskManagement Object with filtered options.
			Should be called internally from initialization function.
		.EXAMPLE
			Filter options example: $FilterOptions = @{"BusType"="USB"}
			$this.Select_Disks(@{"BusType"="USB"})
		#>
		#Get full disk list
		$Disks = get-disk
		
		#Filter full list with Filter options. Filter options example: $FilterOptions = @{"BusType"="USB"}
		foreach($Option in ($FilterOptions.keys))
		{
			iex "`$Disks = `$Disks | Where-Object $Option -eq `"$($FilterOptions[$Option])`""
		}
		
		#for each disk in list Create Disk objects, and add to FilteredDisks list
 		foreach($Disk in $Disks)
		{
			[Disk]$DiskObject = [Disk]::new($Disk)

			$this.FilteredDisks += $DiskObject
		}


	}

	<# Get count of found disks #>
	[int] GetCount(){
		if ($this.FilteredDisks -eq $NULL)
		{
			return 0
		}
		elseif ($this.FilteredDisks.gettype() -eq [Disk])
		{
			return 1
		}
		return $this.FilteredDisks.count
	}

	[void] PreCheck($Operator,$Expected){
		write-host $this.FilteredDisks.count
	}




	
	[void] PrepDisks($FileSystem){

		foreach($DiskObject in $this.PrepedDisks)
		{
			$DiskObject.PrepDisk()
		}

	}




	

	[void] ApplyFolderContents($Source){
		$JOBS = @()
		foreach($DriveLetter in $this.AssignedLetters)
		{
			#-WorkingDirectory "$DIR"
			$XCOPY_CodeBlock = {
				Param(
						$Location,
						$Source,
						$DriveLetter
					)
				import-module "$Location\SystemTools.ps1"
				PS_XCOPY -Source "$Source\*" -Destination "$($DriveLetter):"
			}

			$JOBS += Start-Job -scriptblock $XCOPY_CodeBlock -ArgumentList "$global:DIR", "$Source", "$DriveLetter"
		}


		foreach($JOB in $JOBS)
		{
			$VAR = Receive-Job -Job $job -Keep #6>&1


			$JOB | Wait-Job
		}

		while($JOBS[0].state -eq "Running")
		{
			#write-host "Running"
		}
		#CheckJobsForErrors $JOBS

	}


}
