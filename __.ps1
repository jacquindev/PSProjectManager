# This repo requires the following commands/dependencies::
@('gum', 'git', 'gh') | ForEach-Object {
	if (!(Get-Command $_ -ErrorAction SilentlyContinue)) {
		Write-Warning "Command not found: $_. Please install to use this script."
		return
	}
}
$pstomlExists = Get-Module -ListAvailable -Name "PSToml" -ErrorAction SilentlyContinue
if (!$pstomlExists) {
	Write-Warning "Powershell Module not found: PSToml. Please install to use this script."
	return
}
Remove-Variable pstomlExists

$psyamlExists = Get-Module -ListAvailable -Name "powershell-yaml" -ErrorAction SilentlyContinue
if (!$psyamlExists) {
	Write-Warning "Powershell Module not found: powershell-yaml. Please install and import the module to use this script."
	return
}

. "$PSScriptRoot/lib/utils.ps1"
. "$PSScriptRoot/lib/lang_dotnet.ps1"
. "$PSScriptRoot/lib/lang_node.ps1"
. "$PSScriptRoot/lib/lang_php.ps1"
. "$PSScriptRoot/lib/lang_python.ps1"
. "$PSScriptRoot/lib/lang_rust.ps1"
. "$PSScriptRoot/lib/Add-License.ps1"
. "$PSScriptRoot/lib/Add-Readme.ps1"
