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
			write-host "------------------------------------------------------------------------------"
			write-host "Errors/Warnings:"
			write-host ""
			$Count = 0
			foreach ($ErrorMessage in $Error)
			{
				$Count++
				#$line = $_.InvocationInfo.ScriptLineNumber
        $File = $($ErrorMessage.InvocationInfo.ScriptName)
        write-host "$File"
				write-host "`t[$Count]Line $($ErrorMessage.InvocationInfo.ScriptLineNumber): $ErrorMessage"
			}
			write-host "------------------------------------------------------------------------------"
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
  			foreach ($ErrorMessage in $Error)
  			{
  			  write-host "------------------------------------------------------------------------------"
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
  			write-host "=============================================================================="
  		}
  		pause
  		return $true
  		#Display_Message -mode "Failure" -Message "No Option was selected please try again." -SleepFor 3
	 }
  );
  "Powershell" = @(
    "View Errors/Warnings",{
    exit(1)
    #Display_Message -mode "Failure" -Message "No Option was selected please try again." -SleepFor 3
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
		Display_Error_Message -Message "Test" -Message2 "Test"  -Message3 "Test"
	#>
	Param(
		[String]$Mode="Failure",
		[String]$Message=" Add Message",
		[String]$Message2="Contact Engineering!",
		[String]$Message3="",
		[Boolean]$ClearScreen=$True,
		[Boolean]$Pause=$True
	)

	#Stop-Transcript
	$continue = $true
	while($continue)
	{
		Display_Message -Mode $Mode -Message $Message -Message2 $Message2 -Message3 "Script: $SelfFile has encountered an issue." -ErrorMessage $Error -ClearScreen $ClearScreen -SleepFor 0
		[ErrorHandling]$ErrorHandling = [ErrorHandling]::new(@("View","Continue","Detailed","Powershell"))
		$continue = $ErrorHandling.InvokeOptionPrompt()

		#cmd /c pause | out-null

	}
	#ExitWithCode -exitcode 1
}

Function global:CheckForErrors{
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
