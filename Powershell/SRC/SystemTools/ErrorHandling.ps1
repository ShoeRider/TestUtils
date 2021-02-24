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


##Invoke-command $ErrorOptions[$Option][0]




$global:ErrorOptions = @{
  "View" = @(
    "View Errors/Warnings",
    {
  		if ($Error)
  		{
        #$global:Error = $Error
  			write-host "=============================================================================="
  			write-host "Errors/Warnings:"
  			write-host ""
  			$Count = 0
  			foreach ($ErrorMessage in $Error)
  			{
  			  write-host "------------------------------------------------------------------------------"
  				$Count++
  				#$line = $_.InvocationInfo.ScriptLineNumber
				$File = $($ErrorMessage.InvocationInfo.ScriptName)
				write-host "$File"
  				write-host "[$Count]Line $($ErrorMessage.InvocationInfo.ScriptLineNumber): $ErrorMessage"

    			write-host "------------------------------------------------------------------------------"
  			}
  			write-host "=============================================================================="
  		}
  		pause
		return $true
  		#Display_Message -mode "Failure" -Message "No Option was selected please try again." -SleepFor 3
	 }
  );
  "Detailed" = @(
    "View Errors/Warnings",
    {
  		if ($Error)
  		{
        #$global:Error = $Error
  			write-host "=============================================================================="
  			write-host "Errors/Warnings:"
  			write-host ""
  			$Count = 0

			write-host "------------------------------------------------------------------------------"
  			foreach ($ErrorMessage in $Error)
  			{
				try
				{
					  $Count++
					  #$line = $_.InvocationInfo.ScriptLineNumber
					  $File = $($ErrorMessage.InvocationInfo.ScriptName)
					  write-host "$File"
					  write-host "[$Count]Line $($ErrorMessage.InvocationInfo.ScriptLineNumber): $ErrorMessage"
					  $ScriptStackTrace = "`n`t" + $($ErrorMessage.ScriptStackTrace).replace("`n","`n`t")
					  write-host "$ScriptStackTrace`n" -Separator "`t"
					  #write-host ($ErrorMessage.Exception | Format-List -Force | Out-String)      -ErrorAction Continue
					  #write-host ($ErrorMessage.InvocationInfo | Format-List -Force | Out-String) -ErrorAction Continue
					  #powershell.exe
					  #throw
					  write-host "------------------------------------------------------------------------------"
				}
				catch
				{

				}
				pause
  			}

  			write-host "=============================================================================="

  		}
  		pause
		return $true
  		#Display_Message -mode "Failure" -Message "No Option was selected please try again." -SleepFor 3
	 }
  );
  "Powershell" = @(
    "View Errors/Warnings",{
    return $true
    #Display_Message -mode "Failure" -Message "No Option was selected please try again." -SleepFor 3
  }
  );
   "Exit" = @(
    "Exit Powershell script",{
    Exit
  }
  );
  "Logs" = @(
    "View Logs",
    {
      #Get-EventLog -List
      ii $SelfFolder
      return $true
    }
  );
  "Folder" = @(
    "Open Scripts Folder",
    {
      #Get-EventLog -List
      ii $SelfFolder
      return $true
    }
  );
  "Results" = @(
    "Open Results Folder",
    {
      #Get-EventLog -List
      ii $ResultPath
      return $true
    }
  );
  "Continue" = @(
    "Continue running program",
    {
      $Error.clear()
      return $false
    }
  );
  "Shutdown" = @(
    "Shutdown System",
    {
      Display_Message -Message "System Shutdown Selected"

      #stop-computer
      Write-Host -Object "Shuting down ......"
      Start-sleep -s 20
    }
  );
  "Restart" = @(
    "Restart System",
    {
      Display_Message -Message "System Restart Selected"
      #restart-computer
      Write-Host -Object "Rebooting ......"
      Start-sleep -s 20
    }
  );
}


class ErrorHandling {
    <#
  	.SYNOPSIS

  	.DESCRIPTION

  	.EXAMPLE

  	#>
	$GivenManifest = ""
	$CodeOptions = @()
	$SelectedOptions = @()
	$OptionObject

	ErrorHandling([string]$ManifestPath){
		Try {
			$this.GivenManifest	= Resolve-Path -Path $ManifestPath -ErrorAction Stop
		}
		Catch {
			Write-Warning "ini File:$ManifestPath missing"
		}
		$this.InitializeOptions()
    }
	ErrorHandling([array]$Options){
		$this.InitializeOptions($Options)
    }
		[string] DeclareTest(){
      <#
      .SYNOPSIS

      .DESCRIPTION

      .EXAMPLE

      #>

      return ""
    }

	[void] InitializeOptions([array]$Options){
		<#
		.SYNOPSIS

		.DESCRIPTION

		.EXAMPLE
		#>
		$this.SelectedOptions = @()
		foreach ($Option in $Options)
		{
			if($global:ErrorOptions.ContainsKey($Option))
			{
			  $this.SelectedOptions += New-Object System.Management.Automation.Host.ChoiceDescription "&$Option",$global:ErrorOptions[$Option][0]
			  $this.CodeOptions += $global:ErrorOptions[$Option][1]
			  #Invoke-expression
			}
		}
		$this.OptionObject = [System.Management.Automation.Host.ChoiceDescription[]]($this.SelectedOptions)
	}



	[void] InitializeOptions(){
		$this.InitializeOptions(@("View","Logs","Continue"))
	}




	[Boolean] InvokeOptionPrompt(){
		#$Options = $
		$result = $global:host.ui.PromptForChoice("","Select one of the following options:",$this.OptionObject, 0)
		#write-host $this.CodeOptions[$result]
    if ($result -gt $this.CodeOptions.count)
    {
      Display_Message -Message "No Option was selected please try again." -SleepFor 3
    }

		return Invoke-expression $this.CodeOptions[$result].ToString()
		#$answer = $host.ui.PromptForChoice("","Select one of the following options:",$choices,0)
	}


}






Function global:Display_Error_Message{
	<#
	.SYNOPSIS
		Function to display Error, and Halt Program.
	.DESCRIPTION

	.EXAMPLE
		Display_Error_Message -Mode $Mode -Message $Message -Message2 $Message2 -Message3 "An error has occured" -ErrorMessage $Error -ClearScreen $True -SleepFor 0
		Display_Error_Message -Mode "Failure"`
						-Message "Please Contact Engineering"`
						-Message2 "Failed to move Files $XCopyAttempts / $MaxAttempts Attempts" `
						-Message3 "Error: $error"
	#>
	Param(
		[String]$Mode="Failure",
		[String]$Message=" Add Message",
		[String]$Message2="Contact Engineering!",
		[String]$Message3="",
		[Array]$Options = @("View","Continue","Detailed","Exit"),
		[Boolean]$ClearScreen=$True,
		[Boolean]$Pause=$True
	)
	
	Write-Error -Message "Something Failed, Failsafe Path"
	#Stop-Transcript
	$continue = $true
	while($continue)
	{
		Display_Message -Mode $Mode -Message $Message -Message2 $Message2 -Message3 "Script: $SelfFile has encountered an issue." -ErrorMessage $Error -ClearScreen $ClearScreen -SleepFor 0
		[ErrorHandling]$ErrorHandling = [ErrorHandling]::new($Options)
		$continue = $ErrorHandling.InvokeOptionPrompt()

		#cmd /c pause | out-null

	}
	#ExitWithCode -exitcode 1
}




Function global:CheckJobsForErrors{
	<#
	.SYNOPSIS
		Function to display Error, and Halt Program.
	.DESCRIPTION

	.EXAMPLE
		CheckForErrors -Message "Something Went wrong"
	#>
	Param(
		$JOBS,
		[String]$Mode="Failure",
		[String]$Message=" Add Message",
		[String]$Message2="Contact Engineering!",
		[Boolean]$ClearScreen=$True,
		[Boolean]$Pause=$True
	)
  start-sleep 5
	foreach($JOB in $JOBS)
	{

		
		$JOB | Receive-Job -Keep -OutVariable MyOut -ErrorVariable MyError 6>&1
		if($MyError)
		{
			write-host $JOB.JobStateInfo.Reason.Message
			Display_Error_Message -Mode $Mode -Message "Job Failed:$MyError" -Message2 "$($JOB.JobStateInfo.Reason.Message)" -ClearScreen $ClearScreen -Pause $Pause
		}

		#Display_Error_Message -Mode $Mode -Message $Message -Message2 $Message2 -ClearScreen $ClearScreen -Pause $Pause
	}

}


Function global:CheckForErrors{
	<#
	.SYNOPSIS
		Function to check for system errors, and Halt Program with prompt.
	.DESCRIPTION
		quick one line function to verify no errors have occured.
	.EXAMPLE
		CheckForErrors -Message "Something Went wrong"
	#>
	Param(
		[String]$Mode="Failure",
		[String]$Message=" Add Message",
		[String]$Message2="Contact Engineering!",
		[String]$Message3="",
		[Boolean]$ClearScreen=$True,
		[Boolean]$Pause=$True
	)

	if($lastexitcode -or $Error)
	{
		$Message2+="`n Error:$Error"
		if($lastexitcode)
		{
			$Message2="lastexitcode: $lastexitcode"
		}
		if($Error)
		{
			
		}
		Display_Error_Message -Mode $Mode -Message $Message -Message2 $Message2 -ClearScreen $ClearScreen -Pause $Pause
		#If Continue is selected from Display_Error_Message, return 1 as error has occured.
		return 1
	}
	#Return 0 as no errors have been detected.
	return 0
}
