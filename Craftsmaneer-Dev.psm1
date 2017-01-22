#
# Dev.psm1
#

Import-Module -Name $PSScriptRoot\CraftsManeer-Main -Scope Local


# Copies the Module to the modules PSLIb Modules path.
function Publish-PSLib
{
	param(
		[Parameter(Mandatory=$true)][string]$ModuleName
	)
	
	try{
		$modulePath = Get-AbsolutePath "$ModuleName.psm1"
		$modulePath
		if (!(Test-Path $modulePath))
		{
			"Module '$ModuleName.psm1' could not be found at $modulePath."
			return
		}

		$moduleLibDir = Join-Path (Get-PSLibPath) $ModuleName
		if (!(Test-Path $moduleLibDir)) { New-Item $moduleLibDir -ItemType Directory -Force | Out-Null }

		Copy-Item $modulePath $moduleLibDir -Force
		Import-Module $ModuleName -Force

		"Installed module '$ModuleName' at " + (Get-PSLibPath)
	}
	catch {throw}
}

function Get-PSLibModules
{
	gci (Get-PSLibPath) -Include * | %{ $_.Name} 
}

