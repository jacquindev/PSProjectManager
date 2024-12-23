function Initialize-ProjectPHP-Laravel {
	param ([string]$Name, [switch]$Sail)

	@('composer', 'laravel') | ForEach-Object {
		if (!(Get-Command "$_" -ErrorAction SilentlyContinue)) {
			Write-Warning "Command not found: $_. Please install to use this feature."; return
		}
	}

	$pkgManager = (gum choose --header="Choose a Package Manager:" "bun" "npm" "pnpm" "yarn").Trim()
	if (!(Get-Command $pkgManager -ErrorAction SilentlyContinue)) {
		Write-Warning "Command not found : $pkgManager. Please install to use this feature."; return
	}

	$cmd = "laravel new $Name --git"
	Invoke-Expression "$cmd"
	Set-Location "./$Name"

	$prettyName = (gum style --foreground="#74c7ec" --italic --bold "$Name")
	switch ($pkgManager) {
		"bun" { gum spin --title="Setting up Laravel Project: $prettyName ..." -- bun install }
		"npm" { gum spin --title="Setting up Laravel Project: $prettyName ..." -- npm install -y }
		"pnpm" { gum spin --title="Setting up Laravel Project: $prettyName ..." -- pnpm install }
		"yarn" { gum spin --title="Setting up Laravel Project: $prettyName ..." -- yarn install }
	}
	Remove-Variable cmd, prettyName, pkgManager

	if ($Sail) {
		gum spin --title="Installing Laravel Sail to your current application..." -- composer require laravel/sail --dev
		gum spin --title="Adding .devcontainer folder to your current application..." -- php artisan sail:install --devcontainer

		$extra = $(Write-Host "Add Extra Services to your application? (y/n) " -NoNewline -ForegroundColor Cyan; Read-Host)
		if ($extra.ToUpper() -eq 'Y') {
			$services = @()
			$extraServices = (gum choose --no-limit --header="Choose Extra Services to Install:" "mysql" "pgsql" "mariadb" "mongodb" "redis" "memcached" "meilisearch" "typesense" "minio" "mailpit" "selenium" "soketi").Trim()
			switch ($extraServices) {
				{ $_ -match "mysql" } { $services += @('mysql') }
				{ $_ -match "pgsql" } { $services += @('pgsql') }
				{ $_ -match "mariadb" } { $services += @('mariadb') }
				{ $_ -match "mongodb" } { $services += @('mongodb') }
				{ $_ -match "redis" } { $services += @('redis') }
				{ $_ -match "memcached" } { $services += @('memcached') }
				{ $_ -match "meilisearch" } { $services += @('meilisearch') }
				{ $_ -match "typesense" } { $services += @('typesense') }
				{ $_ -match "minio" } { $services += @('minio') }
				{ $_ -match "mailpit" } { $services += @('mailpit') }
				{ $_ -match "selenium" } { $services += @('selenium') }
				{ $_ -match "soketi" } { $services += @('soketi') }
				Default { $services += @() }
			}
			if ($services.Count -eq 0) { Write-Host "No services added. Exiting..." -ForegroundColor DarkGray; return }
			else {
				foreach ($service in $services) {
					$prettyService = (gum style --foreground="#74c7ec" --italic --bold "$service")
					gum spin --title="Adding Extra Service $prettyService for your application..." -- php artisan sail:add $service --no-interaction
				}
			}
		}
	}
}
