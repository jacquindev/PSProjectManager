function Initialize-ProjectPHP-Symfony {
	param ([string]$Name, [switch]$WebApp)

	if (!(Get-Command composer -ErrorAction SilentlyContinue)) {
		Write-Warning "Command not found: composer. Please install to use this feature."; return
	}

	$symfonyExists = Get-Command symfony -ErrorAction SilentlyContinue
	if ($symfonyExists) {
		if ($WebApp) { gum spin --title="Creating new project with symfony (including web app)..." -- symfony new $Name --version="7.2.x-dev" --webapp }
		else { gum spin --title="Creating new project with symfony..." -- symfony new $Name --version="7.2.x-dev" }
	} else {
		if ($WebApp) {
			gum spin --title="Creating new project with composer..." -- composer create-project symfony/skeleton:"7.2.x-dev" $Name
			Set-Location "./$Name"
			gum spin --title="Adding webapp packages for the project..." -- composer require webapp
		} else {
			gum spin --title="Creating new project with composer..." -- composer create-project symfony/skeleton:"7.2.x-dev" $Name
			Set-Location "./$Name"
		}
	}
}
