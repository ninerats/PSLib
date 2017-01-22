Describe "Run-Elevated" {
	Context "Exists" {
		It "Runs a command or script as Administrator" {
			Import-Module -Name (Join-Path ((Get-Item $PSScriptRoot).Parent).FullName Process\Process.psm1) -Verbose
			if ((Get-Service SNMPTRAP).Status -ne"Stopped" ) 
			{ 
				throw "you need to stop the  SNMPTRAP service before running this test"
			}
			Run-Elevated -Command "Start-Service SNMPTRAP"
			((Get-Service SNMPTRAP).Status) | Should Be "Running"
		}
	}
}