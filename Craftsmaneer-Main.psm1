#
# Craftmasmaneer main module
#

################################################################################################################################
#											           Core
################################################################################################################################

function Get-PSLibPath
{
	"D:\PSLib"
}

function Get-UserModulePath {
 
    $Path = $env:PSModulePath -split ";" -match $env:USERNAME
 
    if (-not (Test-Path -Path $Path))
    {
        New-Item -Path $Path -ItemType Container | Out-Null
    }
        $Path
}



################################################################################################################################
#											           File IO
################################################################################################################################


function Expand-ZipFile($file, $destination)
{
	$shell = new-object -com shell.application
	$zip = $shell.NameSpace($file)
	foreach($item in $zip.items())
	{
	$shell.Namespace($destination).copyhere($item)
	}
}

# http://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/
function Get-AbsolutePath
{
	param( [Parameter(Mandatory=$true)][string]$RelativePath)
	if ([System.IO.Path]::IsPathRooted($RelativePath)) 
		{$current = $RelativePath}
	else
		{ $current = (Join-Path (pwd) $RelativePath) }
	[System.IO.Path]::GetFullPath("$current")
}


################################################################################################################################
#											           Process
################################################################################################################################

# https://blogs.msdn.microsoft.com/virtual_pc_guy/2010/09/23/a-self-elevating-powershell-script/

# true the current user is running as administrator
function Test-AsAdmin
{
	# Get the ID and security principal of the current user account
	$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
	$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

	# Get the security principal for the Administrator role
	$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

	# Check to see if we are currently running "as Administrator"
	$myWindowsPrincipal.IsInRole($adminRole)
}

# Runs a script elevated
function Invoke-AsAdmin
{
param (
	[string]$ScriptFile,
	[string]$Command,
	[string]$ExecutionPolicy=(Get-ExecutionPolicy),
	[switch]$NoExit = $false,
	[switch]$NoWait = $false
)
	$hasCommand = ($Command -ne "")
	$hasScript =($ScriptFile -ne "")
	if (!($hasCommand -or $hasScript)) { throw "You must pass either a Command or a ScriptFile to execute."}
	if ($hasCommand -and $hasScript) { throw "You must pass either a Command OR a ScriptFile to execute, but not both."}


	if (Test-AsAdmin)    
	{
		#Already running as Administrator
		if ($hasCommand){
			Invoke-Command $Command
		}
		else{
			& $ScriptFile
		}
		
	}
	else
	{
	   # We are not running "as Administrator" - so relaunch as administrator
		$noExitSwitch = if ($NoExit) {"-NoExit"} Else {""}
		$waitSwitch = !$NoWait
		if ($hasCommand){
			$arglist = '-noprofile {1} -command "{0}"' -f $Command, $noExitSwitch
		}
		else 
		{
			$arglist = '-ExecutionPolicy {0}  -noprofile {2} -file "{1}" -elevated' -f $ExecutionPolicy, $ScriptFile, $noExitSwitch
		}
		Write-Debug "argList=$argList"
		Start-Process powershell.exe -Verb RunAs -Wait:$waitSwitch -ArgumentList ($arglist) -WindowStyle Hidden

		   
		#Invoke-Process -FilePath powershell.exe -ArgumentList $arglist -Verb RunAs 
		# Exit from the current, unelevated, process
	  # exit
	}
}