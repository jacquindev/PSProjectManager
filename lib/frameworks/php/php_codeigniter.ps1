function Initialize-ProjectPHP-CodeIgniter {
	param ([string]$Name)

	if (!(Get-Command composer -ErrorAction SilentlyContinue)) {
		Write-Warning "Command not found: composer. Please install to use this feature."; return
	}

	$cmd = "composer create-project codeigniter4/appstarter $Name"
	Invoke-Expression $cmd
	Set-Location "./$Name"

	Remove-Variable cmd

}
