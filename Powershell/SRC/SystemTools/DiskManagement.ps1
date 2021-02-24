

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



function GetFileSystem{
((@"
list volume
"@
)|diskpart)
}


class DiskPartition : FileSystem  {
    <#
  	.SYNOPSIS
			Disk class is a class to manage individual Disks, by
  	.DESCRIPTION

  	.EXAMPLE1
			[DiskPartition]$global:DiskPartition = [DiskPartition]::new($DiskNumber,$PartitionNumber)

  	#>
	$DiskNumber
	$PartitionNumber
	$PartitionObject
	$PartitionLetter
	

	
	DiskPartition(
		[int]$DiskNumber,
		[int]$PartitionNumber,
		$PartitionLetter
		){
			$this.__init__($DiskNumber,$PartitionNumber,$PartitionLetter)
    }


	DiskPartition(
		[int]$DiskNumber,
		[int]$PartitionNumber
		){
			$Letter = GetAvailableDriveLetter
			$this.__init__($DiskNumber,$PartitionNumber,$Letter)
    }

	[void]__init__(
	[int]$DiskNumber,
	[int]$PartitionNumber,
	$PartitionLetter
	){
		$this.DiskNumber            = $DiskNumber
		$this.PartitionNumber       = $PartitionNumber
		$this.PartitionObject       = Get-Partition -disknumber $DiskNumber -partitionnumber $PartitionNumber | Set-Partition -NewDriveLetter $PartitionLetter
		$this.PartitionLetter = $PartitionLetter
		Display_Host "Searching for Partition with `n`tDiskNumber :$($this.DiskNumber) `n`tPartition:$($this.PartitionNumber)`n`tPartitionLetter:$($this.PartitionLetter)"
		$this.UsablePartition()
    }
	
	[boolean] UsablePartition(){
		if($this.PartitionObject.IsSystem)
		{
			#Critical Errors may occur if Continuing on Boot Partition, and ReImaging over Current Image
			Display_Error_Message -message "Given Partition is a Boot Partition! " -Options = @("View","Detailed","Exit")
			return $False
		}
		return $true
	}
	
	
	[boolean] ChangeDriveLabel($Label){
		Set-Volume -NewFileSystemLabel $Label -DriveLetter $this.PartitionLetter
		return CheckForErrors -Message "Failed to ChangeDriveLabel"
	}
	
		[boolean] FormatVolume($FileSystem,$BlockSize){
		$this.FormatVolume($FileSystem,$This.PartitionLetter,$BlockSize)
		return CheckForErrors -Message "Failed to Format-Volume"
	}
	
	[boolean] FormatVolume($FileSystem,$PartitionLetter,$BlockSize){
		#$This.PartitionLetter = $PartitionLetter
		Format-Volume -FileSystem $FileSystem -DriveLetter $this.PartitionLetter -AllocationUnitSize $BlockSize
		return CheckForErrors -Message "Failed to Format-Volume"
	}
	
	
	[object] ApplyFolderContents_AsJob($SourcePath){
		<#
		.SYNOPSIS
			Takes $SourcePath, and applies Directories content to Given Disk. (As Job) Returns Job Object to track Job.
		.DESCRIPTION

		.EXAMPLE
			ApplyFolderContents_AsJob("/ArchiveFolderPath/")
		#>

		$XCOPY_CodeBlock = {
			Param(
					$Location,
					$SourcePath,
					$DriveLetter
				)
			#Display_Host "$Location - $SourcePath - $DriveLetter"
			import-module "$Location\SystemTools.ps1"
			PS_XCOPY -Source "$SourcePath" -Destination "$($DriveLetter)"
			#PS_XCOPY_FileCount -Source "$SourcePath" -Destination "$($DriveLetter)"
			CheckForErrors -Message "Thread Failed to Move Files"
		}
		Display_Host "Starting Thread for Drive: $($this.PartitionLetter)"

		return Start-Job -scriptblock $XCOPY_CodeBlock -ArgumentList "$global:DIR", "$SourcePath", "$($this.GetDrivePath())"
	}
	
	[boolean] ApplyFFU([String]$Source){

		<#
		.SYNOPSIS

		.DESCRIPTION

		.EXAMPLE

		#>
		$DismEXE   = "x:\Windows\System32\DISM"
		$DrivePath = "\\.\PhysicalDrive$($this.getDriveNumber())"
		try
		{
			Display_Message -Mode "Information"                `
					-Message  "Applying FFU IMAGE PLEASE WAIT" `
					-Message2 "Source:      $Source"           `
					-Message3 "Destination: $DrivePath"

			#echo "$DISM /Apply-ffu /ImageFile:$Source /ApplyDrive:$Destination"
			iex "$DismEXE /Apply-ffu /ImageFile:$Source /ApplyDrive:$DrivePath"

			CheckForErrors `
						-Message "Please Contact Engineering!!" `
						-Message2 "DISM FFU FAILED."

		}
		catch
		{
			Display_Error_Message -Mode "Failure" -Message "DISM Call Failed with: $_ " -Message2 " Dism:$DismEXE /Apply-ffu /ImageFile:$Source /ApplyDrive:$DrivePath"
			return $False
			#Write-Error "DISM Call Failed: $_ `n $DISM /Apply-ffu /ImageFile:$Source /ApplyDrive:$Destination"
		}
		return $True
	}


	[boolean] CaptureFFU([String]$Source){

		<#
		.SYNOPSIS

		.DESCRIPTION

		.EXAMPLE

		#>
		$DismEXE   = "x:\Windows\System32\DISM"
		$DrivePath = "\\.\PhysicalDrive$($this.getDriveNumber())"
		try
		{
			Display_Message -Mode "Information"                `
					-Message  "Applying FFU IMAGE PLEASE WAIT" `
					-Message2 "Source:      $Source"           `
					-Message3 "Destination: $DrivePath"

			#echo "$DISM /Apply-ffu /ImageFile:$Source /ApplyDrive:$Destination"
			iex "$DismEXE /Apply-ffu /ImageFile:$Source /ApplyDrive:$DrivePath"
<#- dism /capture-ffu /imagefile:%directory%:\%stknum%\%stknum%.ffu /capturedrive:\\.\PhysicalDrive0 /name:%stknum% /description:"%customername% FFU Image"
#>
			CheckForErrors `
						-Message "Please Contact Engineering!!" `
						-Message2 "DISM FFU FAILED."

		}
		catch
		{
			Display_Error_Message -Mode "Failure" -Message "DISM Call Failed with: $_ " -Message2 " Dism:$DismEXE /Apply-ffu /ImageFile:$Source /ApplyDrive:$DrivePath"
			return $False
			#Write-Error "DISM Call Failed: $_ `n $DISM /Apply-ffu /ImageFile:$Source /ApplyDrive:$Destination"
		}
		return $True
	}
	
		
	[string] GetVolumeSize(){
		return $($this.PartitionObject).Size
	}
		
	[string] GetFreeSpace(){
		return $(Get-Volume -DriveLetter $this.PartitionLetter).SizeRemaining
	}
	
	[string] GetUsedSpace(){
		return	$($this.GetVolumeSize() - $this.GetFreeSpace())
	}
	
	[int] GetBlockSize(){
		#write-host $(Get-CimInstance -ClassName Win32_Volume)
		#write-host $($(Get-CimInstance -ClassName Win32_Volume | where-object -property DriveLetter -value "$($this.PartitionLetter):" -eq))
		#write-host $($(Get-CimInstance -ClassName Win32_Volume | where-object -property DriveLetter -value "$($this.PartitionLetter):" -eq).blockSize)
		return $($(Get-CimInstance -ClassName Win32_Volume | where-object -property DriveLetter -value "$($this.PartitionLetter):" -eq).blockSize)
	}
	
	[string] GetPartitionStyle(){
		return ""
	}
	
	[string] GetVolumeLabel(){
		return $(Get-Volume -DriveLetter $this.PartitionLetter).FileSystemLabel
	}

	[string]GetFileSystem(){
		return $(Get-Volume -DriveLetter $this.PartitionLetter).FileSystem
	}

	[string] GetDrivePath(){
		return "$($this.PartitionLetter):\"
	}
	[string] GetFileCount(){
		return ( Get-ChildItem "$($this.PartitionLetter):\" -Recurse | Measure-Object ).Count
	}

	[string] GenerateLog(){
		$Logs = " ----------------------------------------------------------------------- `n"
		$Logs += $(EvenSpace "Volume Name:"     $this.GetVolumeLabel()  20)
		$Logs += $(EvenSpace "Partition Space:" $this.GetVolumeSize()   20)
		$Logs += $(EvenSpace "Free Space:"      $this.GetFreeSpace()    20)
		$Logs += $(EvenSpace "Space Used:"      $this.GetUsedSpace()    20)
		#
		$Logs += $(EvenSpace "File System:"     $this.GetFileSystem()   20)
		$Logs += $(EvenSpace "Files Copied:"    $this.GetFileCount()    20)
		$Logs += $(EvenSpace "Block Size:"      $this.GetBlockSize()    20)
		$Logs += "`t Please note: The Embedded SN doesnt always match the Drive's Label SN."
		$Logs += " ----------------------------------------------------------------------- `n"
		$Logs += $this.Disk | Format-List | out-string
		$Logs += "`n ----------------------------------------------------------------------- `n"
		$Logs += dir -r "$($this.PartitionLetter):\" | % { if ($_.PsIsContainer) { $_.FullName + "\" } else { $_.FullName } } | Format-List | out-string
		$Logs += " ----------------------------------------------------------------------- `n"
		CheckForErrors -Message "Failed to generate Logs."
		return $Logs
		try
		{

		}
		catch
		{
			Display_Host -Message "$_"
			Display_Error_Message -Message "Please Contact Engineering" -Message2 "Failed to generate Logs. $_ " -ClearScreen $FALSE
		}
		return ""
	}
}



class Disk : FileSystem  {
    <#
  	.SYNOPSIS
			Disk class is a class to manage individual Disks, by
  	.DESCRIPTION

  	.EXAMPLE1
			$Disks = get-disk
			[Disk]$global:Disk = [Disk]::new($Disk[0])

  	#>
	$Partitions = @()
	$DiskFormat = @()
	$Disk
	$PartitionStyle

	Disk([int]$DriveNumber){
		write-host "Privided Disk Number:" $DriveNumber
		if ($DriveNumber -eq $NULL)
		{
			Display_Error_Message -Mode "Failure"`
				-Message "Please Contact Engineering"`
				-Message2 "Provided Disk Number was NULL." `
				-Message3 ""
		}
		pause
		$this.Disk = Get-Disk | Where-Object -FilterScript {$_.Number -Eq $DriveNumber}
		write-host $this.Disk
		pause
	  }
	  

	Disk([Object]$PSDriveObject){
		if ($PSDriveObject -eq $NULL)
		{
			Display_Error_Message -Mode "Failure"`
				-Message "Please Contact Engineering"`
				-Message2 "Provided Disk Number was NULL." `
				-Message3 ""
		}
		$this.Disk = $PSDriveObject
		
		if($this.Disk.IsSystem )
		{
			#Critical Errors may occur if Continuing on Boot Partition, and ReImaging over Current Image
			Display_Error_Message -message "Given Partition is a Boot Partition! " -Options = @("View","Detailed","Exit")
		}
	  }





	[void]Clear_Disk(){
		$this.Disk | Clear-Disk -RemoveData -RemoveOEM -Confirm:$false -PassThru
		CheckForErrors -Message "Clear-Disk -RemoveData Failed"
	}


	[boolean]InitializeDisk($PartitionStyle){
		$this.Disk | Initialize-Disk -PartitionStyle $PartitionStyle >$null 2>&1
		return CheckForErrors -Message "Failed to initialize disk"
	}

#Returns created Partition Number
	[object]CleanDisk($PartitionStyle){
		$ExampleDiskPartitions = @{
			PartitionStyle     = "MBR";
	}
	$this.PartitionStyle = $PartitionStyle
		$This.Clear_Disk()
		$This.InitializeDisk($PartitionStyle)
		#$This.CreateNewPartition($DiskPartitions.PartitionSize,$DiskPartitions.FileSystem,$DiskPartitions.BlockSize)
		#$This.ChangeDriveLabel($DiskPartitions.Label)
		return $NULL
	}

	[object] CreatePartition($PartitionSize){
		$PartitionLetter = GetAvailableDriveLetter
		
		if ($PartitionSize -eq "ALL")
		{
			$PartitionInfo = $this.Disk | New-Partition -UseMaximumSize -IsActive -DriveLetter $PartitionLetter
		}
		else{
			Display_Host $($PartitionSize)
			$PartitionInfo = $this.Disk | New-Partition -Size $PartitionSize -IsActive -DriveLetter $PartitionLetter
		}
		
		return [DiskPartition]::new($this.Disk.Number,$PartitionInfo.PartitionNumber,$PartitionLetter)
	}

	[boolean] CreateCustomPartition([hashtable]$PartitionFormat){
		$ExamplePartitionFormat = @{
									PartitionStyle     = "MBR";
									PartitionSize      = 100MB;
									FileSystem         = "NTFS";
									BlockSize          = 4096;
									Label              = "Win_PE_Console_1";
									ApplyZIP           = $NULL;
							}
		$GeneratedPartition = $this.CreateCustomPartition($PartitionFormat.PartitionSize,$PartitionFormat.FileSystem,$PartitionFormat.BlockSize,$PartitionFormat.Label)
		$this.Partitions += $GeneratedPartition
		return $GeneratedPartition
	}
		#Get-Partition -disknumber $DiskNumber -partitionnumber $PartitionNumber | Set-Partition -NewDriveLetter $PartitionLetter
		
		
		
	[boolean] CreateCustomPartition($PartitionSize,$FileSystem,$BlockSize,$Label){
		$Partition = $this.CreatePartition($PartitionSize)
		$Partition.FormatVolume($FileSystem,$BlockSize)
		$Partition.ChangeDriveLabel($Label)
		$This.Partitions += $Partition
		
		return CheckForErrors -Message "Failed to create new partition:New-Partition"
	}
	
	
	
	#Returns created Partition Number
		[void]ApplyPartitions([array]$DiskPartitions){
			$DiskPartitions | % {
				
				$this.CreateCustomPartition($_)
			}
		}

	#Returns created Partition Number
		[void]ApplyPartitions_AsJob([array]$DiskPartitions){
			$DiskPartitions | % {

			}
		}
		
		
#TODO Change Method Name, Name Should indivate Active Disks
	[boolean] EquivalentTo([Disk]$GivenDisk){
			return $($GivenDisk.GetDiskNumber() -eq $this.GetDiskNumber())
	}


	
	[int] GetDiskNumber(){
		write-host "this.Disk: $($this.Disk)"
		write-host "this.Disk.number: $($this.Disk.number)"
		try
		{
			return $this.Disk.number
		}
		catch
		{
			Write-Error -Message "Failed to get `$Disk.GetDiskNumber()"

			Display_Error_Message                                    `
					-Message  "Please Contact Engineering"            `
					-Message2 "Failed to get `$Disk.GetDiskNumber()"
		}
		return $NULL
	}



	[string] GetSerial(){
		return Replace-InvalidFileNameChars( $this.Disk.SerialNumber.toString())
	}




	[string]GetHealthStatus(){
		return $($this.Disk.HealthStatus)
	}


	[string]GetDriveNumber(){
		write-host $this.Disk
		write-host $this.Disk.Number
		pause
		
		return $this.Disk.Number #$this.Disk.partitionStyle
	}
	
	[array]GetPartitions(){
		#write-host $this.Disk.partitionStyle
		
		return Get-Partition -disknumber $this.Disk.Number
	}
	

	[string]GetPartitionStyle(){
		#write-host $this.Disk.partitionStyle
		return $this.Disk.partitionStyle #$this.Disk.partitionStyle
	}

	[string] GetDiskSize(){
		return $this.Disk.size
	}







	[boolean]CheckDisk([hashtable]$DiskFormat,[hashtable[]]$DiskPartitions){
<# 		Display_Message -Message "Checking Disk,"
		Display_Host "PartitionStyle: $($this.GetPartitionStyle() -eq $DiskFormat.PartitionStyle)"
		Display_Host "              Applied  : `"$($this.GetPartitionStyle())`""
		Display_host "              Required : `"$($DiskFormat.PartitionStyle)`""
		Display_host ""
		start-sleep 1

		Display_Host "FileSystem:     $($this.GetFileSystem()     -eq $DiskFormat.FileSystem)"
		Display_Host "              Applied  : `"$($this.GetFileSystem())`""
		Display_host "              Required : `"$($DiskFormat.FileSystem)`""
		Display_host ""
		start-sleep 1

		Display_Host "BlockSize:      $($this.GetBlockSize()      -eq $DiskFormat.BlockSize)"
		Display_Host "              Applied  : `"$($this.GetBlockSize())`""
		Display_host "              Required : `"$($DiskFormat.BlockSize)`""
		Display_host ""
		start-sleep 1

		Display_Host "VolumeLabel:    $($this.GetVolumeLabel()    -eq $DiskFormat.NewFileSystemLabel)"
		Display_Host "              Applied  : `"$($this.GetVolumeLabel())`""
		Display_host "              Required : `"$($DiskFormat.NewFileSystemLabel)`""
		Display_host ""
		start-sleep 1

		start-sleep 2
		if ( `
			$this.GetPartitionStyle() -eq $DiskFormat.PartitionStyle     -and `
			$this.GetFileSystem()     -eq $DiskFormat.FileSystem         -and `
			$this.GetBlockSize()      -eq $DiskFormat.BlockSize          -and `
			$this.GetVolumeLabel()    -eq $DiskFormat.NewFileSystemLabel  `
			)
		{
			return $True
		}
		 #>
		
		###Check Drive Partitions
		return $False
		return $This.CheckPartitions($DiskPartitions)
	}

		
	[boolean]CheckPartition([hashtable]$PartitionFormat,[DiskPartition]$Partition){
		$ExamplePartitionFormat = @{
									PartitionStyle     = "MBR";
									PartitionSize      = 100MB;
									FileSystem         = "NTFS";
									BlockSize          = 4096;
									Label              = "Win_PE_Console_1";
									ApplyZIP           = $NULL;
							}
		#$PartitionStyle     = @("Unknown","GPT","MBR")
		#$FileSystem         = @("FAT", "FAT32", "exFAT", "NTFS", "ReFS")
		#$AllocationUnitSize = @(4096)
		#$NewFileSystemLabel = "Win_PE_Console"
		
		#PartitionSize
		Display_Message -Message "Checking Disk,"
		Display_Host "PartitionStyle: $($Partition.GetPartitionStyle() -eq $PartitionFormat.PartitionSize)"
		Display_Host "              Applied  : `"$($Partition.GetPartitionStyle())`""
		Display_host "              Required : `"$($PartitionFormat.PartitionSize)`""
		Display_host ""
		start-sleep 1
		#ApplyZIP
		
		Display_Message -Message "Checking Disk,"
		Display_Host "PartitionStyle: $($Partition.GetPartitionStyle() -eq $PartitionFormat.PartitionStyle)"
		Display_Host "              Applied  : `"$($Partition.GetPartitionStyle())`""
		Display_host "              Required : `"$($PartitionFormat.PartitionStyle)`""
		Display_host ""
		start-sleep 1

		Display_Host "FileSystem:     $($Partition.GetFileSystem()     -eq $PartitionFormat.FileSystem)"
		Display_Host "              Applied  : `"$($Partition.GetFileSystem())`""
		Display_host "              Required : `"$($PartitionFormat.FileSystem)`""
		Display_host ""
		start-sleep 1

		Display_Host "BlockSize:      $($Partition.GetBlockSize()      -eq $PartitionFormat.BlockSize)"
		Display_Host "              Applied  : `"$($Partition.GetBlockSize())`""
		Display_host "              Required : `"$($PartitionFormat.BlockSize)`""
		Display_host ""
		start-sleep 1

		Display_Host "VolumeLabel:    $($Partition.GetVolumeLabel()    -eq $PartitionFormat.Label)"
		Display_Host "              Applied  : `"$($Partition.GetVolumeLabel())`""
		Display_host "              Required : `"$($PartitionFormat.Label)`""
		Display_host ""
		start-sleep 1

		start-sleep 2
		if ( `
			$Partition.GetPartitionStyle() -eq $PartitionFormat.PartitionStyle     -and `
			$Partition.GetFileSystem()     -eq $PartitionFormat.FileSystem         -and `
			$Partition.GetBlockSize()      -eq $PartitionFormat.BlockSize          -and `
			$Partition.GetVolumeLabel()    -eq $PartitionFormat.Label  `
			)
		{
			return $True
		}
		return $False
	}
	
	[boolean]CheckPartitions()
	{
		$this.Partitions | % {
			Display_Host $this.Partitions
		}
		pause
		return $False 
	}
	


	[string] GenerateLog(){
		$Logs = " ----------------------------------------------------------------------- `n"
		$Logs += $(EvenSpace "Volume Name:"     $this.GetVolumeLabel()    20)
		$Logs += $(EvenSpace "Free Space:"      $this.GetFreeSpace()      20)
		$Logs += $(EvenSpace "Disk Space:"      $this.GetDiskSize()       20)
		$Logs += $(EvenSpace "Files Copied:"    $this.GetFileCount()      20)
		$Logs += $(EvenSpace "Partition Style:" $this.GetPartitionStyle() 20)
		$Logs += $(EvenSpace "HealthStatus:"    $this.GetHealthStatus()   20)
		$Logs += $(EvenSpace "Embedded SN:"     $this.GetSerial()         20)
		$Logs += "`t Please note: The Embedded SN doesnt always match the Drive's Label SN."
		$Logs += " ----------------------------------------------------------------------- `n"
		$Logs += $this.Disk | Format-List | out-string
		$Logs += "`n ----------------------------------------------------------------------- `n"
		#$Logs += dir -r "$($this.AssignedLetter):\" | % { if ($_.PsIsContainer) { $_.FullName + "\" } else { $_.FullName } } | Format-List | out-string
		$Logs += " ----------------------------------------------------------------------- `n"
		CheckForErrors -Message "Failed to generate Logs."
		return $Logs
		try
		{

		}
		catch
		{
			Display_Host -Message "$_"
			Display_Error_Message -Message "Please Contact Engineering" -Message2 "Failed to generate Logs. $_ " -ClearScreen $FALSE
		}
		return ""
	}
}









class DiskManagement {
    <#
  	.SYNOPSIS

  	.DESCRIPTION

  	.EXAMPLE
		$USBFilters = @(
			@{"BusType"="USB";"FriendlyName"="JetFlash Transcend 4GB";},
			@{"BusType"="USB";"FriendlyName"="IS917 innostor";}
			)
			[DiskManagement]$global:DiskManagement = [DiskManagement]::new($USBFilters)
  	#>
	$FilterOptions
	$DiskFormat
	$AllDisks
	$SelectedDisks  = @()
	DiskManagement($FilterOptions){
	<#
	.EXAMPLE
	$USBFilters = @(
		@{"BusType"="USB";"FriendlyName"="JetFlash Transcend 4GB";},
		@{"BusType"="USB";"FriendlyName"="IS917 innostor";}
		)
		[DiskManagement]$global:DiskManagement = [DiskManagement]::new($USBFilters)
    #>
			$this.AllDisks = get-disk
			$this.FilterOptions = $FilterOptions
			$this.Select_Disks()
    }




	[void] Select_Disks(){
		$This.Select_Disks($this.FilterOptions)
	}


	[void] Select_Disks([hashtable]$FilterOptions){
		<#
		.SYNOPSIS
		.DESCRIPTION
			Preps DiskManagement Object with filtered options.
			Should be called internally from initialization function.
		.EXAMPLE
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
			[Disk]$DiskObject = [Disk]::new($Disk) #.Number

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
		if ($FilteredDisks.count -ne 0)
		{
			foreach($Disk in $FilteredDisks)
			{
				$this.Add_Disk($Disk)
			}
		}
		
	}

	#Takes get-disk Child object(ei. $(get-disk)[0]), and adds it to the $This.SelectedDisks List
	#Filters Duplicate Disks
	[void] Add_Disk($Disk){
		if ($Disk -ne $NULL)
		{
			$AddDisk = $true
			[Disk]$DiskObject = [Disk]::new($Disk)
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
		Display_Host $this.SelectedDisks.count
	}





	[void] CleanDisks($FileSystem){
		foreach($DiskObject in $this.SelectedDisks)
		{
			$DiskObject.CleanDisk($FileSystem)
		}

	}

#TODO: Posibly rename to better fit functionality 
	[void] PrepDisks(
		[string]$FileSystem,
		[array]$DiskPartitions
		){
		foreach($DiskObject in $this.SelectedDisks)
		{
			$DiskObject.CleanDisk($FileSystem)
			$DiskObject.ApplyPartitions($DiskPartitions)
		}
		

	}


	[boolean] CheckDisks([hashtable[]]$DiskPartitions){
		foreach($DiskObject in $this.SelectedDisks)
		{
			#[hashtable]$DiskFormat
			if(-not $DiskObject.CheckDisk($DiskPartitions))
			{
				return $False
			}

		}
		return $True

	}



	[void] ApplyFolderContents($Path){
		$JOBS = @()

		foreach($DiskObject in $this.SelectedDisks)
		{
			$JOBS += $DiskObject.ApplyFolderContents_AsJob($Path)
		}

		foreach($JOB in $JOBS)
		{
			#$JOB | Wait-Job
			$VAR = $JOB | Receive-Job -Keep 6>&1

			CheckJobsForErrors $JOBS
			$JOB | Wait-Job
			CheckForErrors -Message "Please Contact Engineering!! `n`t failed to Join Jobs using `"`| wait-job`" "
		}

		CheckJobsForErrors $JOBS
	}

	[void] ApplyZip($Path){
		<#
		.SYNOPSIS
		.DESCRIPTION
			After PrepDisk(), use to apply Zip's content to $DiskManagement.Disks .
			Unzips contents to a local Directory, creates Local Tag indicating so. If Tag is found, Use already extracted contents.
		.EXAMPLE
			$DiskManagement.ApplyZip("/ArchiveDirectory/Folder.ZIP")
		#>
		$ExpandedZIP_TagPath = "$($Global:DIR)\ExpandedZIP.tag"
		$ExtractedDestination = Join-path $Global:Dir $(gci $Path | % {$_.BaseName})
		if(!(Test-Path -Path $ExpandedZIP_TagPath))
		{
			Expand-Archive -path "$Path" -DestinationPath $Global:Dir -force
			Display_Host "Saving Expanded ZIP Tag: $($Global:DIR)\$ExtractedDestination.ZipTag"
			echo "." > $ExpandedZIP_TagPath
		}

		#[io.path]::GetFileNameWithoutExtension($Path)
		Display_Host "Extracted to: $ExtractedDestination"
		Display_Host "Calling ApplyFolderContents: $ExtractedDestination"
		$This.ApplyFolderContents($ExtractedDestination)
	}



	#Returns created Partition Number
		[void]SpecifyPartitions([Array]$DiskPartitions){
			$ExampleDiskPartitions = @(
					@{
						PartitionStyle     = "MBR";
						PartitionSize      = 100MB;
						FileSystem         = "NTFS";
						BlockSize          = 4096;
						Label              = "Win_PE_Console_0";
						ApplyZIP           = $Global:TestZip;
				},
					@{
						PartitionStyle     = "MBR";
						PartitionSize      = 100MB;
						FileSystem         = "NTFS";
						BlockSize          = 4096;
						Label              = "Win_PE_Console_1";
						ApplyZIP           = $NULL;
				}
			)

			$DiskPartitions | % {
				$NewPartition = $This.AddPartition($DiskPartition)
				write-host $NewPartition.DiskNumber
				write-host $NewPartition.PartitionNumber
				write-host $NewPartition.DriveLetter

			}

		}


	[array] GetDrivePaths(){
		<#
		.SYNOPSIS
			Returns list of each $DiskManagement.Disks Path.
		#>
		return $this.SelectedDisks | foreach {$_.GetDrivePath()}
	}

	[array] GetDiskNumbers(){
		<#
		.SYNOPSIS
			Returns list of each $DiskManagement.Disks Path.
		#>
		write-host  $($this.SelectedDisks)
		write-host "$($this.SelectedDisks.count)"
		return $this.SelectedDisks | foreach {$_.GetDiskNumber()}
	}

	[string[]] GetLogs(){
		<#
		.SYNOPSIS
		.DESCRIPTION
			After PrepDisk(), use to apply Zip's content to $DiskManagement.Disks .
			Unzips contents to a local Directory, creates Local Tag indicating so. If Tag is found, Use already extracted contents.
		.EXAMPLE
			$DiskManagement.ApplyZip("/ArchiveDirectory/Folder.ZIP")
		#>
		$Logs = @()

		foreach($DiskObject in $this.SelectedDisks)
		{
			#write-host $DiskObject.GetSerial()

			$DriveLogs = $DiskObject.GenerateLog()
			CheckForErrors -Message "Please Contact Engineering" -Message2 "Failed to create Logs for drive $($DiskObject.GetDiskNumber) "
			$Logs += $DriveLogs
		}
		return $Logs
	}

	[void] SaveLogs($ResultsDrive,$CID,$OrderNumber){
		#TODO REMOVE, ADD to External Operation

		$Logs = $this.GetLogs()

		$ResultsPath = MakePath($(Join-Path $ResultsDrive $CID))
		$ResultsPath = MakePath($(Join-Path $ResultsPath $OrderNumber))
		CheckForErrors -Message "Please Contact Engineering" -Message2 "Failed to MakePath Log folder:$ResultsDrive $CID $OrderNumber "

		$HeaderLogs = GenerateLogHeader $CID $OrderNumber
		$drive = 0
		$Logs | % {
			$DrivesLog = $HeaderLogs
			$DrivesLog += $_

			CheckForErrors -Message "Please Contact Engineering" -Message2 "Failed to create Log folder:$ResultsPath $SerialNumber "

			$DriveLogs | Out-File -FilePath "$($ResultsPath)\Results$($drive).log"
			$drive += 1
		}

	}



}
