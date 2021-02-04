

class CheckSum {
    <#
  	.SYNOPSIS
		CheckSum Class to help manage simple CheckSum commands.
  	.DESCRIPTION
		CheckSum Will allow for simple checksum commands, such as:
			.Get_StringHash
			.GetFileHash
			.GetFileHash_AsJob

			TODO:
			.GetHashLogs
			.SaveFileHash
			.CompareSavedHash

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
	[array]$Directories
	[switch]$Verbose

	CheckSum(
    )
		{

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
				Supported Algorithms MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512
				Uses Certutil windows checksum algorithm
			.EXAMPLE
					[CheckSum]$global:CheckSum = [CheckSum]::new()
					$CheckSum.GetFileHash("E:\PowershellEXE\General_Test_4\SRC\Tests\DiskManagement\ZIP\Source\I-20233-3759\I-20233-3759\sources\boot.wim")
			#>
		#write-host certutil -hashfile $File $HASHTYPE

		#write-host "certutil -hashfile $File $HASHTYPE"
		#certutil will return an error for empty files
		$FileSize = $File | Get-ChildItem | % {[int]($_.length)}
		if (-not $FileSize)
		{
			return 0
		}


		$Results = certutil -hashfile $File $HASHTYPE
		if ($Results -split '-' -contains "hashfile command completed successfully.")
		{
			#write-host $($Results.split(":"))[3]
			return $($Results.split(":"))[3]
		}
		#write-host "Results:$Results"
		#write-error $Results
		#pause
		Display_Error_Message -Message "CertutilCheckSum Failed" -Message2 "$Results"
		return -1
		#PS_XCOPY_CheckSum -Source "$Source\*" -Destination "$($DriveLetter):" -Source_HashCode $Source_HashCode
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
		$Hash = $This.GetFileHash_Algorithm($File,$HASHTYPE)
		$this.JOBS += [pscustomobject]@{
			File     = "$File"
			HASHTYPE = "$HASHTYPE"
			HASH     =  $Hash
		}
		return $Hash
	}


	[object]GetFileHash_AsJob(
			$File,
			$HASHTYPE="MD5"
			){
				#[CheckSum]$global:CheckSum = [CheckSum]::new()
				#-WorkingDirectory "$DIR"
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
				write-host "Starting Thread for File: $($File)"
				#PS_XCOPY_FileCount -Source "$($Source)*" -Destination "$($this.AssignedLetter):\"
				#return ""

				#write-host $this.getType()
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
						$CheckSum.GetFolderHash("E:\PowershellEXE\General_Test_4\SRC\Tests\DiskManagement\ZIP\Source\I-20233-3759\I-20233-3759\","MD5")
				#>
				#( Get-ChildItem $Destination -Recurse | Get-FileHash -algorithm $HashName).hash
				[FileSystem]$FileSystem = [FileSystem]::new()
				$FileList = $FileSystem.GetFileList($Path) | Sort
				#write-host "FileList:$FileList"



				  #$psCredentials = #New-Object PSCredential #-ArgumentList @("Username", (ConvertTo-SecureString $password -AsPlainText -Force))
				  #$psCredentials = Get-Credential
				  
				  $JobsStarted = 0
				  foreach($File in $FileList)
				  {
							$this.JOBS += [pscustomobject]@{
								File     = "$File"
								HASHTYPE = "$HASHTYPE"
								Job      =  $this.GetFileHash_AsJob("$File", "$HASHTYPE")
							}
						$JobsStarted += 1
						#Start-Job -scriptblock $this.GetFileHash -ArgumentList "$global:DIR", "$File", "MD5" #-Credential $psCredentials
				  }

				  $JobsRecieved = 0
				  $MergedString="";
				  foreach($JOB in $this.JOBS)
				  {
						#When testing and having issues with Threads, comment out "Job | Wait-job 6>&1" inorder to recieve inline comments from individual Jobs.
						$JOB.Job         | Wait-Job 6>&1
						$Hash = $Job.Job | Receive-Job -Keep 6>&1
						$JOB             | Add-Member -MemberType NoteProperty -Name Hash -Value $Hash

						$MergedString += $JOB.Hash

						CheckForErrors -Message "Please Contact Engineering!! `n`t failed to Join Jobs using `"`| wait-job | Receive-Job`" "
						$JobsRecieved += 1
				  }
				#write-host "MergedString:$MergedString"
				#write-host "JobsStarted:$JobsStarted"
				#write-host "JobsRecieved:$JobsRecieved"
				$Hash = $this.Get_StringHash($($MergedString -replace " ",""),"MD5").toString()
				CheckForErrors -Message "Please Contact Engineering!! `n`t failed to merge final Hash `"`$this.Get_StringHash`" "
				return $Hash -replace " ",""
			}

		[string]GetLogs(){
			$LongestAttribute = LongestLength_ofAttribute $this.Jobs File
			write-host $LongestAttribute
			$appropreateLength = $($LongestAttribute+15)
			$Logs = " ----------------------------------------------------------------------- `n"
			foreach($Job in $this.Jobs)
			{
				$Logs += $(EvenSpace "$($Job.HASHTYPE),$($Job.File)," $Job.Hash $($LongestAttribute+8))
			}
			CheckForErrors -Message "Please Contact Engineering!! `n`t failed to merge final Hash `"`$this.Get_StringHash`" "
			return $Logs
		}
}


