function Initialize-ProjectPHP-Laminas {
	param ([string]$Name)

	if (!(Get-Command composer -ErrorAction SilentlyContinue)) {
		Write-Warning "Command not found: composer. Please install to use this feature."; return
	}

	$cmd = "composer create-project -s dev laminas/laminas-mvc-skeleton $Name"
	Invoke-Expression $cmd
	Set-Location "./$Name"

	Remove-Variable cmd
}
