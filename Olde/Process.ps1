#
# Process.ps1
#
function Invoke-Process
{
	param (
		[string]$FilePath,
		[string]$ArgumentList,
		[string]$Verb
	)
	
	$pinfo = New-Object System.Diagnostics.ProcessStartInfo
	$pinfo.FileName = $FilePath
#	$pinfo.RedirectStandardError = $true
#	$pinfo.RedirectStandardOutput = $true
	$pinfo.UseShellExecute = $true
	$pinfo.Arguments = $ArgumentList
	$pinfo.Verb = $Verb
	$p = New-Object System.Diagnostics.Process
	$p.StartInfo = $pinfo
	$p.Start() | Out-Null
	$p.WaitForExit()
#	$stdout = $p.StandardOutput.ReadToEnd()
#	$stderr = $p.StandardError.ReadToEnd()
#	Write-Output  $stdout
#	Write-Error $stderr
	$p.ExitCode
}