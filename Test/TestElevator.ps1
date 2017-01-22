#
# TestElevator.ps1
#
$scriptPath = Join-Path (Get-Item $PSScriptRoot).Parent.FullName Process\Elevator.ps1

. $scriptPath

#Run-Elevated $PSScriptRoot\needsElevation.ps1 -NoExit

if ((Get-Service SNMPTRAP).Status -ne"Stopped" ) 
{ 
	throw "you need to stop the  SNMPTRAP service before running this test"
}
Run-Elevated -Command "Start-Service SNMPTRAP" 

#Invoke-Command -Script { Set-ExecutionPolicy Unrestricted ; Run-Elevated $PSScriptRoot\needsElevation.ps1}