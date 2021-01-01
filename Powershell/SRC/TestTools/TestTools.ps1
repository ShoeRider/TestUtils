# ==========================================================
# DESCRIPTION:
#     Powershell Test Tools to help the development of Programs/Scripts
# ==========================================================
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted

$Working_Archive = ""
# ==========================================================
# Command Line Parameters
# Import:
#     Import-Module TestTools.ps1
# ==========================================================

<#
<TestDir>     / <Class_tests>  / @(<Context>, NULL)  / <TestName>        /  @("Source",              "Result")
$This.TestDir / $This.ClassDir / $This.ContextDir    / $This.InstanceDIR /  @($This.Instance_Source, $This.Instance_Result)

#>


class TestTools {
    <#
  	.SYNOPSIS

  	.DESCRIPTION

  	.EXAMPLE

  	#>

    [string]$ContextDir

    [string]$InstanceDIR
    [string]$Instance_SourceDir
    [string]$Instance_ResultDir

    [string]$TestDir
    [string]$ClassDir
    [string]$ClassName

		TestTools(
		        [string]$TestDir,
		        [string]$ClassName
    ){
      $this.TestDir       = $TestDir
      $this.ClassName     = $ClassName
      #write-host $this.TestDir
      #write-host $this.ClassName
      #write-host $(Join-Path $this.TestDir $ClassName)
      $this.ClassDir      = $this.MakePath($(Join-Path $this.TestDir $ClassName))
      $this.ContextDir     = $this.ClassDir
    }


    [string] DeclareContext([string]$Name){
      <#
      .SYNOPSIS

      .DESCRIPTION

      .EXAMPLE

      #>
      $this.ContextDir          = $this.MakePath($(Join-Path $this.ClassDir $Name))
      $this.InstanceDIR         = ""
      $this.Instance_SourceDir  = ""
      $this.Instance_ResultDir  = ""
      #$this.InstanceDIR        = $this.MakePath($(Join-Path $this.ConextDir $Name))
      #Defaults with previous Test Name instance.
      #$this.Instance_SourceDir = $this.MakePath($(Join-Path $this.InstanceDIR "Source"))
      #$this.Instance_ResultDir = $this.MakePath($(Join-Path $this.InstanceDIR "Result"))
      return $this.ContextDir
    }


		[string] DeclareTest([string]$Name){
      <#
      .SYNOPSIS

      .DESCRIPTION

      .EXAMPLE

      #>
      $this.InstanceDIR        = $this.MakePath($(Join-Path $this.ContextDir $Name))
      $this.Instance_SourceDir = $this.MakePath($(Join-Path $this.InstanceDIR "Source"))
      $this.Instance_ResultDir = $this.MakePath($(Join-Path $this.InstanceDIR "Result"))
      return $this.InstanceDIR
    }





		[string] MakePath([string]$Path){
      <#
      .SYNOPSIS

      .DESCRIPTION

      .EXAMPLE

      #>
      if(!(Test-Path -Path $Path ))
      {
        New-Item -ItemType Directory -Force -Path $Path
      }
      return $Path
    }
    [boolean] IsFolder([string]$Path){
      <#
      .SYNOPSIS

      .DESCRIPTION

      .EXAMPLE

      #>
      return (Get-Item $Path) -is [System.IO.DirectoryInfo]
    }
    [boolean] IsFile([string]$Path){
      <#
      .SYNOPSIS

      .DESCRIPTION

      .EXAMPLE

      #>

      return Test-Path -Path $Path -PathType Leaf
    }

    [string] RemovePath([string]$Path){
      <#
      .SYNOPSIS

      .DESCRIPTION

      .EXAMPLE

      #>
      if(Test-Path -Path $Path )
      {
        Remove-Item $Path -Recurse -ErrorAction Ignore
      }
      return $Path
    }
    #
    [void] CleanResultFolder([string]$Path){
      <#
      .SYNOPSIS

      .DESCRIPTION

      .EXAMPLE

      #>
      #Remove-Item C:\Test\*.*
      try
      {
        if($Path.Substring($Path.get_Length()-1) -ne "\" )
        {
          $Path+="\"
        }


        if(Test-Path -Path $Path )
        {
          Remove-Item $Path*.*
        }
      }
      catch
      {
        write-host "Failed to Clean Results folder: `n" + $Error[0]
      }


    }


    [boolean] IsType($Variable,[type] $GivenType){
      <#
      .SYNOPSIS

      .DESCRIPTION

      .EXAMPLE

      .PARAMETER Variable

      .PARAMETER GivenType
      [type] $GivenType
      .OUTPUTS
          0 - Array matches type
          1 - Does not contain array
          2 - Array does not contain type
      #>
      if($Variable.GetType() -eq $GivenType)
      {
        return $True
      }
  		write-host "Given Type: $($Variable.getType())"
      return $False
    }

    [void] IncrementManifest($Variable,[type] $GivenType){
      <#
      .SYNOPSIS

      .DESCRIPTION

      .EXAMPLE

      .PARAMETER Variable

      #>

      [String]$File     = $args[0]
      #$Delimiter = $args[1..($args.Length-1)]
      [String]$Section  = $args[1]
      [String]$Key      = $args[2]

      write-host $args
      $ini = Get-IniContent $File
      write-host $ini[$Section][$Key]
      pause
      $ini[$Section][$Key] = "C:\Temp\FileC.bmp"
      $ini | Out-IniFile -FilePath c:\temp\ini2.ini
    }


}


# ==========================================================
# Command Line Parameters
# ==========================================================
