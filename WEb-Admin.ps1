# https://mcpmag.com/articles/2014/10/21/enabling-iis-remote-management.aspx
$Sessions = New-PSSession –ComputerName appsvr -Credential appsvr\tony
Invoke-Command –Session $Sessions –ScriptBlock {Add-WindowsFeature  Web-Mgmt-Service}
Invoke-command –Session $Sessions -ScriptBlock{Set-ItemProperty -Path  HKLM:\SOFTWARE\Microsoft\WebManagement\Server -Name EnableRemoteManagement  -Value 1}
Invoke-command –Session $Sessions -ScriptBlock {Set-Service -name WMSVC  -StartupType Automatic}
Invoke-command –Session $Sessions -ScriptBlock {Start-service WMSVC}