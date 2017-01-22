#
# needsElevation.ps1
#
"This should be running elevated."

if ((Get-Service SNMPTRAP).Status -eq "Stopped" ) { Start-Service SNMPTRAP} else { Stop-Service SNMPTRAP}

Return $LASTEXITCODE