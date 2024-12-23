function Initialize-ProjectPHP-CakePHP {
	param ([string]$Name)
	if (!(Get-Command composer -ErrorAction SilentlyContinue)) {
		Write-Warning "Command not found: composer. Please install to use this feature."; return
	}

	$cmd = "composer create-project --prefer-dist cakephp/app:~5.0 $Name"
	Invoke-Expression $cmd
	Set-Location "./$Name"

	Remove-Variable cmd
}
