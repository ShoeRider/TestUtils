


function Advanced-sleep {
  Param(
    $Seconds,
    [string]$Context= "Loading please wait"
  )
  <#
  .SYNOPSIS
    Simple function that simulates the built in Start-Sleep function, with a progress bar
  .DESCRIPTION

  For future Testing:
    Measure-Command { Advanced-sleep 0 "d" }
  .EXAMPLE
    Example 1.
    Advanced-sleep 5
    Example 2.
    Advanced-sleep 5 "Closing application please wait"

  #>
  [double]$IterationTime  = ($($([double]$seconds-2)*10),0 | Measure -Max).Maximum

  For ($i=0; $i -le 100; $i++) {
      #Write-Progress -Activity "$Context: $IterationTime" -SecondsRemaining $i
      Write-Progress -Activity "$Context" -PercentComplete (($i / 100) * 100)
      Start-Sleep -Milliseconds $IterationTime
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
		Write-Warning "Could not Resize Window"
		#Display_Error_Message -message "Could not Resize Window"
	}
}

$global:ColorOptions = @{
  "Information" = @{
    "backgroundcolor" = "Blue"
    "foregroundcolor" = "White"
  };
  "Pass" = @{
    "backgroundcolor" = "Green"
    "foregroundcolor" = "Black"
  };
  "Attention" = @{
    "backgroundcolor" = "Yellow"
    "foregroundcolor" = "Black"
  };
  "Failure" = @{
    "backgroundcolor" = "DarkRed"
    "foregroundcolor" = "White"
  };
  "Retry" = @{
    "backgroundcolor" = "Cyan"
    "foregroundcolor" = "Black"
  };
  "Default" = @{
    "backgroundcolor" = "Cyan"
    "foregroundcolor" = "Black"
  };
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
  try
  {
    $host.ui.rawui.backgroundcolor = $global:ColorOptions[$Mode]["backgroundcolor"]
    $host.ui.rawui.foregroundcolor = $global:ColorOptions[$Mode]["foregroundcolor"]
  }
  catch
  {
    Write-Warning "Failed to Set ScreenMode"
  }
}
#Set_ScreenMode -Mood "Information"


# ==========================================================
# Terminal Messages
# ==========================================================
Function global:Display_Message{
	<#
	.SYNOPSIS

	.DESCRIPTION

	.EXAMPLE
		Display_Message -Mode "Retry" -Message "Looking Good"
	#>
	Param(
		[String]$Mode        = "Information",
		[String]$Message     = "Add Message",
		[String]$Message2    = "   ",
		[String]$Message3    = "   ",
		$ErrorMessages       = $False,
		[switch]$Pause,
		$SleepFor            = 3,
		[bool]$ClearScreen   = $True,
		[bool]$SetScreenMode = $True
	)
	if($SetScreenMode)
	{
		write-host "$Mode"
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



function Validate_Param{
	<#
	.SYNOPSIS
		Validate_Param is used to validate a Variable conatins data with given characteristics.
	.DESCRIPTION
    returns $True when value is accepted, and $False when not
	.EXAMPLE
		Example 1.

	#>
  [CmdletBinding()] Param(
		[Parameter(ValueFromPipeline)]$Value,
		[int]$ValidateLength    = -1,
		[string]$ValidateType      = "",
		[boolean]$Write_Host 	   = $True,
		[switch]$StringToInteger
	)

  #Write-Host "Invalid ValidateType: `"$ValidateType`""
  #write-host $($($Value.getType().fullname) -eq $ValidateType -or $($Value.getType().name) -eq $ValidateType)


  if($ValidateType -ne "")
  {
    if(-not $($($Value.getType().fullname) -eq $ValidateType -or $($Value.getType().name) -eq $ValidateType))
    {
      if($Write_Host)
      {
        Write-Host "Invalid ValidateType: `"$ValidateType`""
        Write-Host "Provided Fullname: `"$($Value.getType().fullname)`""
        Write-Host "Provided name: `"$($Value.getType().name)`""
      }
      return $False
    }
  }

  if($StringToInteger)
  {
    $alphabet=@()
    65..90|foreach-object{$alphabet += [char]$_}
    #write-host $Value
    #write-host $alphabet
    #write-host $(ContainsCaracters -String $Value -Characters $alphabet)
    if($(ContainsCaracters -String $Value -Characters $alphabet))
    {
      #write-host "Validate_Param:$False"
      return $False
    }
     #'[^a-zA-Z]'
  }


	if (($ValidateLength -ne -1) -and ($Value.Length -ne $ValidateLength))
	{
		if($Write_Host)
		{
			Write-Host "Invalid String Length!, Expected Length ($ValidateLength) but received ($($Value.Length))"
			Write-Host "Entered Value: '$Value'"
		}

		return $False
	}

  #ContainsCaracters($Value,"")



	return $True
}






#TODO FIX -ValidateType Integer
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
	  [CmdletBinding()] Param(
		[Parameter(ValueFromPipeline)]$PassThroughValue       = $NULL,
		[String]$Mode            = "Attention",
		[String]$Message         = "Missing Prompt",
		[int]$InputLength        = -1,
		[string]$CastType        = "string"

	)
	#$Type.ToLower()

	if(($PassThroughValue -ne $NULL) -and (Validate_Param -Value $PassThroughValue -InputLength $InputLength -CastType $CastType -Write_Host $False))
	{
		Write-Host "$Message : $PassThroughValue"
		return $PassThroughValue
	}

	Set_ScreenMode -Mode "$Mode"
	$GatherInput = $True
	while($GatherInput)
	{
		#Write-Host " "
		$GatheredInput = Read-Host -Prompt $Message

		if ((Validate_Param -Value $GatheredInput -InputLength $InputLength -CastType $CastType -Write_Host $True))
		{
			Write-Host "$Message : $GatheredInput" -InformationAction Ignore
			return $GatheredInput
		}

	}

}
