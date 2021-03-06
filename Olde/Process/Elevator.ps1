# https://blogs.msdn.microsoft.com/virtual_pc_guy/2010/09/23/a-self-elevating-powershell-script/

. $PSScriptRoot\Process.ps1

function Run-CmdElevated
{
param ([string]$Command)

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
	Invoke-Command $Command
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator

   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

   # Specify the current script path and name as a parameter
   $newProcess.Arguments = -Command $Command;

   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";

   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);

   # Exit from the current, unelevated, process
   exit
   }
}

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
function Run-Elevated
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
		$waitSwitch = if ($NoWait) {""} else {"-Wait"}
		if ($hasCommand){
			$arglist = '-noprofile {1} -command "{0}"' -f $Command, $noExitSwitch
		}
		else 
		{
			$arglist = '-ExecutionPolicy {0}  -noprofile {2} -file "{1}" -elevated' -f $ExecutionPolicy, $ScriptFile, $noExitSwitch
		}
		"argList=$argList"
		Start-Process powershell.exe -Verb RunAs -ArgumentList ($arglist) $waitSwitch

		   
		#Invoke-Process -FilePath powershell.exe -ArgumentList $arglist -Verb RunAs 
		# Exit from the current, unelevated, process
	  # exit
	}
}