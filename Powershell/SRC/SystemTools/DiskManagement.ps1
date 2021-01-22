# ==========================================================
# DESCRIPTION:
#
# ==========================================================
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted

$Working_Archive = ""
# ==========================================================
# Command Line Parameters
# Import:
#     Import-Module DiskManagement.ps1
# ==========================================================


function Disable_AutoMount{
((@"
automout disable
"@
)|diskpart)
}

function Enable_AutoMount{
((@"
automout enable
"@
)|diskpart)
}

class Disk {
    <#
  	.SYNOPSIS
			Disk class is a class to manage individual Disks, by
  	.DESCRIPTION

  	.EXAMPLE1
			$Disks = get-disk
			[Disk]$global:Disk = [Disk]::new($Disk[0])

  	#>
	$AssignedLetter

	$Disk

	Disk(
		[Microsoft.Management.Infrastructure.CimInstance]$Disk,
		[hashtable]$DiskFormat
		){
			$this.Disk = $Disk
			$DiskFormat = @{
				"PartitionStyle"     = "MBR";
				"FileSystem"         = "NTFS";
				"AllocationUnitSize" = 4096;
				"NewFileSystemLabel" = "Win_PE_Console"
			}
    }
		Disk(){

	  }


	[string]GetAvailableDriveLetter(){
		if ($Global:PS_Version -eq 5)
		{
			$AllLetters = 65..90 | ForEach-Object {[char]$_}

			#get-wmiobject deprecated
			$UsedLetters = get-wmiobject win32_logicaldisk | select -expand deviceid
		  #$UsedLetters = Get-CimInstance -ClassName Win32_Service -Filter "name='LISA_43_Dev_Batch'" | select Name,DisplayName,StartMode,State,StartName,SystemName,Description |Format-Table -AutoSize
			$FreeLetters = $AllLetters | Where-Object {$UsedLetters -notcontains $_}
			#write-host $FreeLetters
			return $FreeLetters | select-object -first 1
		}
		elseif($Global:PS_Version -eq 7)
		{
			$AllLetters = 65..90 | ForEach-Object {[char]$_}

			#get-wmiobject deprecated
			#$UsedLetters = get-wmiobject win32_logicaldisk | select -expand deviceid
		  $UsedLetters = Get-CimInstance -ClassName Win32_Service -Filter "name='LISA_43_Dev_Batch'" | select -expand deviceid
			$FreeLetters = $AllLetters | Where-Object {$UsedLetters -notcontains $_}
			#write-host $FreeLetters
			return $FreeLetters | select-object -first 1
		}
		Display_Error_Message -Message "Please Contact Engineering" -Message2 "PS_Version:$Global:PS_Version not supported by Disk.GetAvailableDriveLetter() "

		return ""
		#Following only filters local Drives
		#ls function:[d-z]: -n | ?{ !(test-path $_) } | random
	}

	#Get Non Admin Drives
	[string]Get_NADDrives(){
	  Start-Job -Name Get_NADDrives -ScriptBlock ${function:foo}
		#Invoke-Command -ScriptBlock  -argumentlist "Bye!"

	  #Do other stuff here
	  return Get-Job -Name Get_NADDrives | Wait-Job | Receive-Job
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

		$this.AssignedLetter = $DriveLetter
	}


	[object] ApplyFolderContents_AsJob($Source,$Source_HashCode){
		#-WorkingDirectory "$DIR"
		$XCOPY_CodeBlock = {
			Param(
					$Location,
					$Source,
					$Source_HashCode,
					$DriveLetter
				)
			write-host "$Location - $Source - $DriveLetter"
			import-module "$Location\SystemTools.ps1"
			PS_XCOPY_FileCount -Source "$Source" -Destination "$($DriveLetter)"
			#PS_XCOPY_CheckSum -Source "$Source\*" -Destination "$($DriveLetter):" -Source_HashCode $Source_HashCode
		}
		write-host "Starting Thread for Drive: $($this.AssignedLetter)"
		#PS_XCOPY_FileCount -Source "$($Source)*" -Destination "$($this.AssignedLetter):\"
		#return ""
		return Start-Job -scriptblock $XCOPY_CodeBlock -ArgumentList "$global:DIR", "$Source", "$Source_HashCode", "$($this.AssignedLetter):\"
	}

	[boolean] EquivalentTo([Disk]$GivenDisk){
			return $($GivenDisk.GetDiskNumber() -eq $this.GetDiskNumber())
	}

	[boolean] ApplyFFU([String]$Source){
		Param
		<#
		.SYNOPSIS

		.DESCRIPTION

		.EXAMPLE

		#>
		$DismEXE   = "x:\Windows\System32\DISM"
		$DrivePath = "\\.\PhysicalDrive$($this.getDriveNumber())"
		try
		{
			Display_Message -Mode "Information" -Message "Applying FFU IMAGE PLEASE WAIT" -Message2 "Source: $Source" -message3 "Destination: $DrivePath"
			#echo "$DISM /Apply-ffu /ImageFile:$Source /ApplyDrive:$Destination"
			iex "$DismEXE /Apply-ffu /ImageFile:$Source /ApplyDrive:$DrivePath"
			CheckForErrors -Message "Please Contact Engineering!!" -Message2 "DISM FFU FAILED"

		}
		catch
		{
			Display_Error_Message -Mode "Failure" -Message "DISM Call Failed with: $_ " -Message2 " Dism:$DismEXE /Apply-ffu /ImageFile:$Source /ApplyDrive:$DrivePath"
			return $False
			#Write-Error "DISM Call Failed: $_ `n $DISM /Apply-ffu /ImageFile:$Source /ApplyDrive:$Destination"
		}
		return $True
	}
	[string] GetDiskNumber(){
		return $this.Disk.number
	}
	[string] GetSerial(){
		write-host $this.Disk.SerialNumber.gettype()
		return Remove-InvalidFileNameChars( $this.Disk.SerialNumber.toString())
	}
	[string] GetDiskSize(){
		return $this.Disk.size
	}
	[string] GetFileCount(){
		return ( Get-ChildItem "$($this.AssignedLetter):\" -Recurse | Measure-Object ).Count
	}
	[string] GetVolumeName(){
		return $(Get-Volume -DriveLetter $this.AssignedLetter).FileSystemLabel
	}
	[string] GetFreeSpace(){
		return $(Get-Volume -DriveLetter $this.AssignedLetter).SizeRemaining
	}
	[string] GenerateLog($CID,$Order){

		$Attributes = @{}
		try
		{
			$Attributes["Serial Number"]     = ($this.GetSerial())
			$Attributes["Disk Space"] = ($this.GetDiskSize())
			$Attributes["Free Space"] = ($this.GetFreeSpace())
			$Attributes["Volume Name"] = $this.GetVolumeName()
			$Attributes["Files Copied"] = $this.GetFileCount()
			[string]$Logs = GenerateLog -CID $CID -OrderNumber $Order -DeviceAttributes $Attributes
			$Logs += " ----------------------------------------------------------------------- `n"
			$Logs += $this.Disk | Format-List | out-string
			$Logs += "`n ----------------------------------------------------------------------- `n"
			#$Logs += Get-ChildItem "$($this.AssignedLetter):\" -recurse
			$Logs += dir -r "$($this.AssignedLetter):\" | % { if ($_.PsIsContainer) { $_.FullName + "\" } else { $_.FullName } } | Format-List | out-string
			#$Logs +=
			$Logs += " ----------------------------------------------------------------------- `n"
			#write-host $Logs
			return $Logs
			#$Logs["FreeSpace"]  = ($this.GetSerial())
			#$Logs["VolumeName"] = ($this.GetSerial())


		}
		catch
		{
			Display_Error_Message -Message "Please Contact Engineering" -Message2 "Failed to save Logs. "
		}
		return ""
	}
}









class DiskManagement {
    <#
  	.SYNOPSIS

  	.DESCRIPTION

  	.EXAMPLE

  	#>
	$FilterOptions
	$DiskFormat
	$AllDisks
	$SelectedDisks  = @()
	DiskManagement([hashtable]$DiskFormat){
	<#
      .SYNOPSIS
      .DESCRIPTION
      .EXAMPLE
		Filter options example: $FilterOptions = @{"BusType"="USB"}
		[DiskManagement]$global:DiskManagement = [DiskManagement]::new(@{"BusType"="USB"})
    #>
		$this.AllDisks = get-disk
		$this.DiskFormat = @{
			"PartitionStyle"     = "MBR";
			"FileSystem"         = "NTFS";
			"AllocationUnitSize" = 4096;
			"NewFileSystemLabel" = "Win_PE_Console"
		}
		$this.DiskFormat = $DiskFormat
		$PartitionStyle     = @("Unknown","GPT","MBR")
		$FileSystem         = @("FAT", "FAT32", "exFAT", "NTFS", "ReFS")
		$AllocationUnitSize = @(4096)
		$NewFileSystemLabel = "Win_PE_Console"
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
		$this.FilterOptions = $FilterOptions
		$Disks = get-disk

		#Filter full list with Filter options. Filter options example: $FilterOptions = @{"BusType"="USB"}
		foreach($Option in ($FilterOptions.keys))
		{
			iex "`$Disks = `$Disks | Where-Object $Option -eq `"$($FilterOptions[$Option])`""
		}

		#for each disk in list Create Disk objects, and add to FilteredDisks list
 		foreach($Disk in $Disks)
		{
			[Disk]$DiskObject = [Disk]::new($Disk,$this.DiskFormat)

			$this.FilteredDisks += $DiskObject
		}
	}
	[void] Select_Disks([hashtable[]]$FilterOptions){
		<#
		.SYNOPSIS
		.DESCRIPTION
			Preps DiskManagement Object with filtered options.
			Should be called internally from initialization function.
		.EXAMPLE
			Filter options example: $FilterOptions = @{"BusType"="USB"}
			$this.Select_Disks(@{"BusType"="USB"})
		#>

		$FilterOptions | % {
			$FilteredDisks = $this.AllDisks
						
			foreach($Option in ($_.keys))
			{
				iex "`$FilteredDisks = `$FilteredDisks | Where-Object $Option -eq `"$($_[$Option])`""
			}
			
			$this.Add_Disks($FilteredDisks)
		}
	}
	[void] Add_Disks($FilteredDisks){
		foreach($Disk in $FilteredDisks)
		{
			$this.Add_Disk($Disk)
		} 
	}
	
	[void] Add_Disk($Disk){
		$AddDisk = $true 
		[Disk]$DiskObject = [Disk]::new($Disk,$this.DiskFormat)
		foreach($SelectedDisk in ($this.SelectedDisks))
		{			
			if ($SelectedDisk.EquivalentTo($DiskObject))
			{
				$AddDisk = $False
			}
		}

		if($AddDisk)
		{
			$this.SelectedDisks += $DiskObject
		}
		
	}

	<# Get count of found disks #>
	[int] GetCount(){
		if ($this.SelectedDisks -eq $NULL)
		{
			return 0
		}
		elseif ($this.SelectedDisks.gettype() -eq [Disk])
		{
			return 1
		}
		return $this.SelectedDisks.count
	}

	[void] PreCheck($Operator,$Expected){
		write-host $this.FilteredDisks.count
	}





	[void] PrepDisks($FileSystem){
		foreach($DiskObject in $this.FilteredDisks)
		{
			$DiskObject.PrepDisk()
		}

	}




	[void] ApplyFolderContents($Source,$Source_HashCode){
		$JOBS = @()
		foreach($DiskObject in $this.FilteredDisks)
		{
			$JOBS += $DiskObject.ApplyFolderContents_AsJob($Source,$Source_HashCode)
		}

		foreach($JOB in $JOBS)
		{
			$VAR = $JOB | Receive-Job -Keep 6>&1

			CheckJobsForErrors $JOBS
			$JOB | Wait-Job
			CheckForErrors -Message "Please Contact Engineering!! `n`t failed to Join Jobs using `"`| wait-job`" "
		}

		CheckJobsForErrors $JOBS
	}



	[void] SaveLogs($ResultsDrive,$CID,$Order){
		$Logs = @()
		write-host "`"$ResultsDrive`"", "`"$CID`"" + "\" + $Order +"\"

		$ResultsPath = MakePath($(Join-Path $ResultsDrive $CID))
		$ResultsPath = MakePath($(Join-Path $ResultsPath $Order))
		foreach($DiskObject in $this.FilteredDisks)
		{
			#write-host $DiskObject.GetSerial()
			$DriveLogs = $DiskObject.GenerateLog($CID,$Order)
			$SerialNumber = $DiskObject.GetSerial()
			try{
				$Result = MakePath($(Join-Path $ResultsPath $SerialNumber))
				$DriveLogs | Out-File -FilePath "$($Result)\Results.log"
			}
			catch{
				Display_Error_Message -Message "Please Contact Engineering" -Message2 "Failed to create Log folder:$ResultsPath $SerialNumber "
			}

			CheckForErrors -Message "Please Contact Engineering!! `n`t failed to save to $ResultsPath $SerialNumber \Results.log"
			#write-host $DriveLogs
			$Logs += $DriveLogs
		}
		$Logs


	}



}
