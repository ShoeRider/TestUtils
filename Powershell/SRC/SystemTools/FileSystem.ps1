


function GetAvailableDriveLetter(){
	$AllLetters = 65..90 | ForEach-Object {[char]$_}

	#get-wmiobject deprecated
	$UsedLetters = @()
	$(get-wmiobject win32_logicaldisk | select -expand deviceid) | % {
		$UsedLetters += $_[0]
	}
	#$UsedLetters = Get-CimInstance -ClassName Win32_Service -Filter "name='LISA_43_Dev_Batch'" | select Name,DisplayName,StartMode,State,StartName,SystemName,Description |Format-Table -AutoSize
	$FreeLetters = $AllLetters | Where-Object {$UsedLetters -notcontains $_[0]}
	#write-host $UsedLetters
	#write-host $FreeLetters
	return $FreeLetters | select-object -first 1
}

Function GetFileList($Path){
	#$FullList = New-Object System.Collections.Generic.List[System.Object]
	return $(get-childitem $Path -recurse) | where {$_ -is [System.IO.FileInfo]} | foreach-object {"$($_.FullName)"}
}


class CheckSum {
    <#
  	.SYNOPSIS
		CheckSum Class to help manage simple CheckSum commands.
  	.DESCRIPTION
		CheckSum Will allow for simple checksum commands, such as:
			.Get_StringHash
			.GetFileHash
			.GetFileHash_AsJob
			.GetLogs

			TODO:

			.CompareWithArchive

  	.EXAMPLE
				[CheckSum]$global:CheckSum = [CheckSum]::new()
				$Hash = $CheckSum.GetFolderHash("D:\PowershellEXE\General_Test_4\SRC\Tests\DiskManagement\ZIP\Source\I-20233-3759\I-20233-3759\","MD5")
				$CheckSum.GetLogs()
  	#>
	#Format:
	#	$HashedFiles = @(
	#		@("FilePath","Hash")
	#)
	[array]$JOBS = @()
	$JobsTable
	[switch]$Verbose
	[string]$BaseDirectory
	[string]$FolderCheckSum
	[string]$HashType
	[Object]$ArchivedXML
	CheckSum(
    )
		{
			$This.BaseDirectory = ""
			#	[switch]$Verbose
			#[switch]$this.Verbose = $Verbose
	}

	[string]Get_StringHash([String] $String,$HashName = "MD5"){
		$StringBuilder = New-Object System.Text.StringBuilder
		[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{
			[Void]$StringBuilder.Append($_.ToString("x2"))
		}
		return $StringBuilder.ToString()
	}

	[string]GetFileHash_Algorithm(
		$File,
		$HASHTYPE="MD5"
		){
			<#
			.SYNOPSIS

			.DESCRIPTION
				Uses Certutil Windows checksum algorithm. Supported Algorithms: MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512
			.EXAMPLE
					[CheckSum]$global:CheckSum = [CheckSum]::new()
					$CheckSum.GetFileHash("E:\PowershellEXE\General_Test_4\SRC\Tests\DiskManagement\ZIP\Source\I-20233-3759\I-20233-3759\sources\boot.wim")
			#>

		#certutil.exe will return an error for empty files. Here is some Logic to Return a Hash of 0.
		$FileSize = $File | Get-ChildItem | % {[int]($_.length)}
		if (-not $FileSize)
		{
			return 0
		}

		#certutil System Call
		$Results = certutil -hashfile $File $HASHTYPE
		#Check Output For Success.
		if ($Results -split '-' -contains "hashfile command completed successfully.")
		{
			return $($Results.split(":"))[3]
		}


		#An error has occurred, following logic handles exceptions.
		 # Calling CheckForErrors because Display_Error_Message Sometimes Misses Error Context.
		CheckForErrors `
					-Message "CertutilCheckSum Failed"`
					-Message2 "$Results"

		# Calling Display_Error_Message if ErrorCode is reported from Certutil or caught by CheckForErrors.
		Display_Error_Message `
					-Message "CertutilCheckSum Failed"`
					-Message2 "$Results"

		# Pass through default 0 If Engineer continues Program.
		return 0
	}



	#Calls helper function $this.GetFileHash_Algorithm to get algorithm result
	[string]GetFileHash(
		$File,
		$HASHTYPE="MD5"
		){
		<#
			.SYNOPSIS

			.DESCRIPTION
				Supported Algorithms MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512
				Uses Certutil windows checksum algorithm
			.EXAMPLE
					[CheckSum]$global:CheckSum = [CheckSum]::new()
					$CheckSum.GetFileHash("E:\PowershellEXE\General_Test_4\SRC\Tests\DiskManagement\ZIP\Source\I-20233-3759\I-20233-3759\sources\boot.wim")
		#>
		$this.HashType      = $HashType
		$Hash = $This.GetFileHash_Algorithm($File,$HASHTYPE)

		if($This.BaseDirectory.length -ne 0){
			$ShortPath = $File.replace($This.BaseDirectory,"")
		}
		else
		{
			$ShortPath =$File
		}

		$this.JOBS += [pscustomobject]@{
			File     = $ShortPath
			HASHTYPE = "$HASHTYPE"
			HASH     =  $Hash
		}
		return $Hash
	}


	[object]GetFileHash_AsJob(
			$File,
			$HASHTYPE="MD5"
	){
		$CodeBlock = {
			Param(
				$Location,
				$ObjectType,
				$File,
				$HASHTYPE
				)
			#write-host "$Location - $File - $HASHTYPE"
			import-module "$Location\SystemTools.ps1"
			iex "[$ObjectType]`$CheckSum = [$ObjectType]::new()"
			#write-Host "[$ObjectType]`$CheckSum = [$ObjectType]::new()"
			CheckForErrors -Message "Job Failed to create [$ObjectType]`$CheckSum"


			$Hash = $CheckSum.GetFileHash_Algorithm($File,$HASHTYPE)
			CheckForErrors -Message "Job Failed execute [$ObjectType]`$CheckSum.GetFileHash_Algorithm($File,$HASHTYPE)" -message2 "Hash generated: $Hash" -ClearScreen $False
			#write-Host "FT Hash:$Hash"

			return $Hash
		}

		#Standard Global Report to Display Logic to Keep Test output clean
		if($Global:ReportToDisplay -eq $NULL -or $Global:ReportToDisplay)
		{
			$ShortPath = $File.replace($This.BaseDirectory,"")
			write-host "Starting Thread for File: .\$ShortPath"
		}


		return Start-Job -scriptblock $CodeBlock -ArgumentList "$global:DIR",$this.getType(), "$File", "$HASHTYPE"
	}



	[string]GetFolderHash(
		[string]$Path,
		$HASHTYPE="MD5"
	){
		<#
		.SYNOPSIS

		.DESCRIPTION
			Supported Algorithms MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512
			Uses Certutil windows checksum algorithm
		.EXAMPLE
				[CheckSum]$global:CheckSum = [CheckSum]::new()
				$HASH = $CheckSum.GetFolderHash("E:\PowershellEXE\General_Test_4\SRC\Tests\DiskManagement\ZIP\Source\I-20233-3759\I-20233-3759\","MD5")
		#>
		$this.HashType      = $HashType
		$This.BaseDirectory = $Path
		#TODO Move FileSystem Methods to individual Functions for easy access | From FileSystem Class call functions for consistency.
		[FileSystem]$FileSystem = [FileSystem]::new()

		#Check If Folder is empty
		$FileList = GetFileList($Path) | Sort
		if ($FileList.count -eq 0)
		{
			write-warning "`$Filesystem.GetFolderHash Given Empty Directory Please verify"
		}

		#Sort List of Paths to create Consistancy in logs
		


		#Start Jobs ......
		$JobsStarted = 0
		foreach($File in $FileList)
		{
			$ShortPath = $File.replace($This.BaseDirectory,"")
				$this.JOBS += [pscustomobject]@{
					File     = $ShortPath
					HASHTYPE = "$HASHTYPE"
					Job      =  $this.GetFileHash_AsJob("$File", "$HASHTYPE")
				}
			$JobsStarted += 1
			#Start-Job -scriptblock $this.GetFileHash -ArgumentList "$global:DIR", "$File", "MD5" #-Credential $psCredentials
		}


		#Recieve Jobs ....
		$JobsRecieved = 0
		$MergedString="";
		foreach($JOB in $this.JOBS)
		{
			#When testing and having issues with Threads, comment out "Job | Wait-job 6>&1" inorder to recieve inline comments from individual Jobs.
			$JOB.Job         | Wait-Job 6>&1
			$Hash = $Job.Job | Receive-Job -Keep 6>&1
			$JOB             | Add-Member -MemberType NoteProperty -Name Hash -Value $Hash
			#write-host "Hash:$Hash"
			$MergedString += $JOB.Hash

			CheckForErrors -Message "Please Contact Engineering!! `n`t failed to Join Jobs using `"`| wait-job | Receive-Job`" "
			$JobsRecieved += 1
		}

		#Combine $MergedString into one small Hash
		$this.FolderCheckSum = $this.Get_StringHash($($MergedString -replace " ",""),"MD5").toString().replace(" ","")
		CheckForErrors -Message "Please Contact Engineering!! `n`t failed to merge final Hash `"`$this.Get_StringHash`" "

		return $this.FolderCheckSum
	}




		<#
		#Join Objects at element
		if (Get-Module -ListAvailable -Name Join) {
			Write-Host "Module exists"
		} else {
			Install-Script -Name Join
		}

		#>
		[string]GetLogs(){
			#Get Longest File Path Length for Log formating
			$LongestAttribute = @(@( $this.Jobs | foreach-object {iex "`$_.File.length"}) | Measure-Object -Maximum).Maximum

			write-host $LongestAttribute
			$appropreateLength = $($LongestAttribute+15)


			$Logs = CreateHeaderMessage `
				"Folder Hash: `t`'$($This.FolderCheckSum)`'           `t(Type: $($This.FolderCheckSum.GetType().name))" `
				"Archived Hash:`t`'$($this.ArchivedXML.FolderCheckSum)`' `t(Type: $($this.ArchivedXML.FolderCheckSum.GetType().name))"

			$Logs += $this.JobsTable | out-string

			<#
			foreach($Job in $this.Jobs)
			{
				$Logs += $(EvenSpace "$($Job.HASHTYPE),$($Job.File)," $Job.Hash $($LongestAttribute+8))
			}
			#>
			CheckForErrors -Message "Please Contact Engineering!! `n`t failed to merge final Hash `"`$this.Get_StringHash`" "
			return $Logs
		}



		[Boolean]AddXML([PSObject]$XMLDictionary){
			$This.ArchivedXML = $XMLDictionary
			$this.JobsTable = $This.ArchivedXML.Jobs | leftJoin $this.Jobs -On File -Property @{ File = 'Left.File'; HASHTYPE = 'Left.HASHTYPE'; Job = 'Left.Job'; Hash = 'Left.Hash';},@{ ArchivedHash = 'Right.Hash';} | Format-Table -Property File,HASHTYPE,Hash,ArchivedHash
			return $True
		}


		[boolean]CompareWithArchive([string]$Path){
			<#
			.SYNOPSIS

			.DESCRIPTION
				Supported Algorithms MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512
				Uses Certutil windows checksum algorithm
			.EXAMPLE
					[CheckSum]$global:CheckSum = [CheckSum]::new()
					$HASH = $CheckSum.GetFolderHash("E:\PowershellEXE\General_Test_4\SRC\Tests\DiskManagement\ZIP\Source\I-20233-3759\I-20233-3759\","MD5")
					$CheckSum.CompareWithArchive("C:\ArchivedCheckSum.xml")
					$CheckSum.GetLogs() | Out-File -FilePath "$($ResultsPath)\Results$($drive).log"
			#>

			#Standard Global Report to Display Logic to Keep Test output clean
			if($Global:ReportToDisplay -eq $NULL -or $Global:ReportToDisplay)
			{
				write-host "Comparing:  with Saved XML Table"
			}
			return $this.CompareWithArchive($(Import-Clixml $Path))
		}

		[boolean]CompareWithArchive([PSObject]$XMLDictionary){
			<#
			.SYNOPSIS
				Returns $True if Hash Values Match, False if they dont
			.DESCRIPTION
				Supported Algorithms MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512
				Uses Certutil windows checksum algorithm
			.EXAMPLE

			#>
			$This.AddXML($XMLDictionary)

			if($Global:ReportToDisplay -eq $NULL -or $Global:ReportToDisplay)
			{
				Display_Message -Mode "Information" -Message "Checking CheckSum for Path:" -Message2 "`t'$($this.BaseDirectory)'" -SleepFor 0
				#write-host "Comparing: $XMLDictionary.FolderCheckSum"
				Write-Host "Testing Hash: `t`'$($This.FolderCheckSum)`'           `t(Type: $($This.FolderCheckSum.GetType().name))"
				Write-Host "Archived Hash:`t`'$($XMLDictionary.FolderCheckSum)`' `t(Type: $($XMLDictionary.FolderCheckSum.GetType().name))"
			}
			if( $((Compare-Object $this.FolderCheckSum $XMLDictionary.FolderCheckSum)))
			{
				Write-Host "FolderCheckSum's did not match!"
				return $False
			}

			CheckForErrors -Message "Please Contact Engineering!!" -Message2 "Failed to check FolderCheckSum"

			if($Global:ReportToDisplay -eq $NULL -or $Global:ReportToDisplay)
			{
				write-host $this.getLogs()
			}
			if( $((Compare-Object $this.Jobs.Hash $XMLDictionary.Jobs.Hash)))
			{
				Write-Host "FolderCheckSum's did not match!"
				return $False
			}

			CheckForErrors -Message "Please Contact Engineering!!" -Message2 "Failed to check Jobs.FolderCheckSum"
			return $True
		}





		[boolean]SaveAsXML($Path){
			if($Global:ReportToDisplay -eq $NULL -or $Global:ReportToDisplay)
			{

			}
			$this | Export-Clixml $Path
			CheckForErrors -Message "Failed to Save CheckSum Object as xml File "
			return $true
		}
}


class FileSystem {
	FileSystem(
		){
			<#
				.SYNOPSIS
					Disk class is a class to manage individual Disks, by
				.DESCRIPTION

				.EXAMPLE
					[FileSystem]$global:FileSystem = [Disk]::new()
				#>

		}

	[string]GetAvailableDriveLetter(){
			$AllLetters = 65..90 | ForEach-Object {[char]$_}

			#get-wmiobject deprecated
			$UsedLetters = @()
			$(get-wmiobject win32_logicaldisk | select -expand deviceid) | % {
				$UsedLetters += $_[0]
			}
			#$UsedLetters = Get-CimInstance -ClassName Win32_Service -Filter "name='LISA_43_Dev_Batch'" | select Name,DisplayName,StartMode,State,StartName,SystemName,Description |Format-Table -AutoSize
			$FreeLetters = $AllLetters | Where-Object {$UsedLetters -notcontains $_[0]}
			#write-host $UsedLetters
			#write-host $FreeLetters
			return $FreeLetters | select-object -first 1
	}
	#(Get-Item c:\fso) -is [System.IO.DirectoryInfo]
	#Select-Object
	[array]GetFileList($Path){
		#$FullList = New-Object System.Collections.Generic.List[System.Object]
		return $(get-childitem $Path -recurse) | where {$_ -is [System.IO.FileInfo]} | foreach-object {"$($_.FullName)"}
	}
	#(Get-Item c:\fso) -is [System.IO.DirectoryInfo]
	[string] GetFileCount($Path){
		return $((Get-ChildItem "$Path" -Recurse ) | where {$_ -is [System.IO.FileInfo]}).Count
	}
	[string] GetFolderList($Path){
		return $((Get-ChildItem "$Path" -Recurse ) | where {$_ -is [System.IO.DirectoryInfo]})
	}
	[string] GetFolderCount($Path){
		return $((Get-ChildItem "$Path" -Recurse ) | where {$_ -is [System.IO.DirectoryInfo]}).Count
	}
	[string] GetFileFolderCount($Path){
		return ( Get-ChildItem "$Path" -Recurse | Measure-Object ).Count
	}

}

#MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512
Function PS_CopyItem{
	Param(
		[Parameter(Mandatory=$true)][String]$Source,
		[Parameter(Mandatory=$true)][String]$Destination,
		[ValidateSet("MD2","MD4","MD5","SHA1","SHA256","SHA384","SHA512")][string]$CheckSum
	)
	#,ErrorMessage="Value '{0}' is invalid. Try one of: {1}"
	<#
	.SYNOPSIS
		Copies from $Source to $Destination. Additional functionality included through parameters.

	.DESCRIPTION
		Will attempt to use CopyItem multiple times(Default 3) and move contents from one folder to another.
		If Destination doesn't exist, the folder will be created.

		If [String]CheckSum provided, CheckSum Object will be created to verify contents Moved were correctly copied.
			- Returns logs with the list of Files moved with Source and Destination checkSums shown within Table.

	.OUTPUTS
        If NO CheckSum String string is provided, PS_CopyItem Returns $True/$False.

		If A CheckSum String is Provided, PS_CopyItem Returns CheckSum Object of $Destination folder,
			With either the Stored .$($CheckSum).XML, or $Source $CheckSum Column Appended to the
			returned CheckSum.GetLogs()

	.EXAMPLE
		PXE_XCOPY ".\Source\" ".\Destination\"
	#>
	$XCopyAttempts = 0
	$MaxAttempts   = 3
	$ContinueAttempting  = $True

	#Check If Source Folder Exists, if not Throw Error, and Halt.
	if(!(Test-Path -Path "$Source"))
	{
		throw "PS_CopyItem Was Given an incorrect Source folder:`n`t`t$Source"
		Display_Error_Message `
				-Message  "Please Contact Engineering"`
				-Message2 "PS_CopyItem Was Given an incorrect Source folder:`n`t`t$Source"
	}


	#Check If Destination Folder Exists, if not Create Path.
	if(!(Test-Path -Path "$Destination"))
	{
		New-Item -ItemType Directory -Force -Path "$Destination"
	}
	CheckForErrors -Message "PS_CopyItem Was Given an incorrect Destination folder:`n`t`t$Destination"


	#Standard Global Report to Display Scripts Progress.
	Display_Message -Mode "Information" `
			-Message "Starting XCopy. Max Attempts: $MaxAttempts Attempts" `
			-Message2 "Source:$Source`n`tDestination:$Destination" -sleep 0

	while($ContinueAttempting)
	{
		#Iterate progress
		$XCopyAttempts+=1

		#Standard Global Report to Display Scripts Progress.
		Display_Message -Mode "Information"`
				-Message "Failed to move Files. Attempting: $XCopyAttempts / $MaxAttempts"`
				-Message2 "Source:$Source`n`tDestination:$Destination"


		#Attempt to Copy $Source to $Destination
		Copy-Item -Path "$Source" -Destination "$Destination" -Recurse -Force


		#If CheckSum String Provided, Preform CheckSum Operations
		if($CheckSum)
		{
			#Create CheckSum Object to Contain $Destination CheckSum Data.
			[CheckSum]$DestinationCheckSum = [CheckSum]::new()
			$DestinationCheckSum.GetFolderHash("$Destination","$CheckSum")


			#Check if $Source is a Folder or File.
			if((Get-Item $Source) -is [System.IO.FileInfo])
			{
				#$Source is a File
				#Create Would-be Archive Path       !!Path Might not exist!!
				$ArchivedCheckSumFile = (Get-Item $Source).DirectoryName+"\"+(Get-Item $Source).BaseName+".$CheckSum.xml"

			}
			elseif((Get-Item $Source) -is [System.IO.DirectoryInfo])
			{
				#$Source is a Folder
				#Create Would-be Archive Path       !!Path Might not exist!!
				$ArchivedCheckSumFile = "$Source\..\$((Get-Item $Source).BaseName).$CheckSum.xml"

			}

			#Check if $Source Directory has an Archive of CheckSum data.
			if(!$(Test-Path -Path $ArchivedCheckSumFile))
			{

				#CheckSum Archive NOT Found. Preform CheckSum on $Source Archive on the fly.
				[CheckSum]$ArchiveCheckSum = [CheckSum]::new()
				$ArchiveCheckSum.GetFolderHash("$Source","$CheckSum")

				#Compare Both $CheckSum Results
				#NOTE: $([CheckSum]$DestinationCheckSum).CompareWithArchive([CheckSum]$ArchiveCheckSum) Adds Log data to [CheckSum]$DestinationCheckSum).
				$CheckSumObjectsMatch = $DestinationCheckSum.CompareWithArchive($ArchiveCheckSum)
			}
			else
			{
				#CheckSum Archive Found. Compare Loged File with DestinationCheckSum Object.
				#NOTE: $([CheckSum]$DestinationCheckSum).CompareWithArchive([String]$ArchivedCheckSumFile) Adds Log data to [CheckSum]$DestinationCheckSum).
				$CheckSumObjectsMatch = $DestinationCheckSum.CompareWithArchive("$ArchivedCheckSumFile")
			}


			#Check If $Source and $Destination CheckSum's Match.
			if($CheckSumObjectsMatch)
			{
				#CheckSum's match, return $DestinationCheckSum, for logs and further use.
				return $DestinationCheckSum
			}
			else{
				#CheckSum's dont match, Display message, and allow for multiple attempts.
				Display_Message -Mode "Failure" -pause -ClearScreen $False `
									-Message "Archive CheckSum doesnt match Result." `
									-Message2 "If this message Continues Please Contact Engineering."`
									-Message3 "Press Enter to continue"
				#If Maximum attempts achieved,
				if ($XCopyAttempts -ge $MaxAttempts)
				{
					#Display_Message -Mode "Failure" -Message "Please Contact Engineering" -Message2 "Failed to move Files $XCopyAttempts / $MaxAttempts Attempts" -Message3 "Something Unexpected happened." -pause
					Display_Error_Message -Mode "Failure"`
									-Message "Please Contact Engineering"`
									-Message2 "Failed to move Files $XCopyAttempts / $MaxAttempts Attempts" `
									-Message3 "Error: $error"
				}
			}

		}
		else{
			return $True
		}


		if ($XCopyAttempts -ge $MaxAttempts)
		{
			#Display_Message -Mode "Failure" -Message "Please Contact Engineering" -Message2 "Failed to move Files $XCopyAttempts / $MaxAttempts Attempts" -Message3 "Something Unexpected happened." -pause
			CheckForErrors -Message "Failed to move Files $XCopyAttempts / $MaxAttempts Attempts" -ClearScreen $False
			Display_Error_Message -Mode "Failure" -Message "Please Contact Engineering" -Message2 "Failed to move Files $XCopyAttempts / $MaxAttempts Attempts" -Message3 "Error: $error"
		}


		#If CopyItem failed, Clean Destination folder, and try again.
		CleanFolder($Destination)

	}
	#As Copy-Item, and CheckSum is attempted several times, errors might have built up, Remove Error List to prevent them being detected lator.
	$Error.clear()

}


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
	$XCopyAttempts    = 0
	$MaxAttempts      = 3
	$AttemptXCOPY     = $True
	$Verify_CheckSum  = $True

	if(!(Test-Path -Path "$Destination"))
	{
		write-host "New-Item -ItemType Directory -Force -Path $Destination"
		New-Item -ItemType Directory -Force -Path $Destination
	}
	CheckForErrors -Message "Was Given an incorrect Destination folder: $Destination "

	#Standard Global Report to Display Logic to Keep Test output clean
	Display_Message -Mode "Information" -Message "Starting XCopy. Max Attempts: $MaxAttempts Attempts" -sleep 0



	while($AttemptXCOPY)
	{
		try
		{
			#PS_XCOPY -Source $Source -Destination $Destination
			#write-host
			Display_Host "Attempting XCOPY $Source $Destination"
			xcopy $Source $Destination /E /I /H /Y
			#CheckForErrors -Message "Please Contact Engineering `n`t  XCOPY Failed"

			#Verify_XCOPY -Source $Source -Destination $Destination
			$AttemptXCOPY = $False
			#throw "Fail"
			#break
		}
		catch
		{
			#Standard Global Report to Display Logic to Keep Test output clean
			if($Global:ReportToDisplay -eq $NULL -or $Global:ReportToDisplay)
			{
				Display_Message -Mode "Information" -Message "Failed to move Files $XCopyAttempts / $MaxAttempts Attempts" -Message2 "Error: $error"
			}

			#Start-Sleep -Seconds 2
			$XCopyAttempts+=1
		}


		if ($XCopyAttempts -ge $MaxAttempts)
		{
			Display_Error_Message -Mode "Failure" -Message "Please Contact Engineering" -Message2 "Failed to move Files $XCopyAttempts / $MaxAttempts Attempts" -Message2 "Error: $error"
		}
	}
	#As XCOPY is attempted several times,
	#$Error.clear()

}







