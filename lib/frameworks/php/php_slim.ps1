function Initialize-ProjectPHP-Slim {
	param ([string]$Name)
	if (!(Get-Command composer -ErrorAction SilentlyContinue)) {
		Write-Warning "Command not found: composer. Please install to use this feature."; return
	}

	$cmd = "composer create-project slim/slim-skeleton $Name"
	Invoke-Expression $cmd
	Set-Location "./$Name"

	Remove-Variable cmd
}
