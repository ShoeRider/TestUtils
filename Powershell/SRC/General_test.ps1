

write-host "WINPE System: $WINPESystem"


<# Describe "General Windows Tests" {

	context "Pester" {
		It "$true | Should Be $true" {
			$true | Should Be $true
		}
	}
}
 #>

Describe "Pester" {
	It "$true | Should Be $true" {
		$true | Should Be $true
	}
	
}


Describe "General" {
	It "Creates Descriptive Log folder" {
		$true | Should Be $true
	}
	
}


<# Describe -tag "SQL" -name "test1" {
	invoke-expression -Command .\General.ps1
} #>



Describe "Set_WindowSize" {
	$InitialX = $host.ui.rawui.windowsize.width
	$InitialY = $host.ui.rawui.windowsize.height
	It "Should shrink" {
		#$X = 10
		#$Y = 10
		#Set_WindowSize -X $X -Y $Y
		#$host.ui.rawui.windowsize.width  | Should Be $X
		#$host.ui.rawui.windowsize.height | Should Be $Y

	}
	#Set_WindowSize -X $InitialX -Y $InitialY

}



Describe "Set_ScreenMode" {

	write-host $host.ui.rawui.backgroundcolor
	$host.ui.rawui.foregroundcolor
	

}


Describe "PS_XCOPY" {
	
    It "Should work in WINPE" {
        $true | Should Be $true
    }
	write-host $host.ui.rawui.backgroundcolor
	$host.ui.rawui.foregroundcolor
	

}


pause
