function Initialize-ProjectPython-Bottle {
	param ([string]$ProjectManager, [switch]$Addons)

	if ($Addons) {
		Write-Host "BOTTLE PLUGINS:" -ForegroundColor Blue
		Write-Host "---------------" -ForegroundColor Blue

		$packages = @()
		$bottlePlugins = (gum choose --no-limit --header="Choose Bottle Plugins:" "bottle-beaker" "bottle-cerberus" "bottle-cork" "bottle-cors-plugin" "bottle-errorsrest" "bottle-extras" "bottle-flash" "bottle-hotqueue" "bottle-memcache" "bottle-mongo" "bottle-oauthlib" "bottle-redis" "bottle-renderer" "bottle-servefiles" "bottle-sqlalchemy" "bottle-sqlite" "bottle-web2pydal" "bottle-werkzeug" "bottlejwt" "canister").Trim()

		switch ($bottlePlugins) {
			{ $_ -match "bottle-beaker" } { $packages += @('bottle-beaker') }
			{ $_ -match "bottle-cerberus" } { $packages += @('bottle-cerberus') }
			{ $_ -match "bottle-cork" } { $packages += @('bottle-cork') }
			{ $_ -match "bottle-cors-plugin" } { $packages += @('bottle-cors-plugin') }
			{ $_ -match "bottle-errorsrest" } { $packages += @('bottle_errorsrest') }
			{ $_ -match "bottle-extras" } { $packages += @('bottle-extras') }
			{ $_ -match "bottle-flash" } { $packages += @('bottle-flash') }
			{ $_ -match "bottle-hotqueue" } { $packages += @('bottle-hotqueue') }
			{ $_ -match "bottle-memcache" } { $packages += @('bottle-memcache') }
			{ $_ -match "bottle-mongo" } { $packages += @('bottle-mongo') }
			{ $_ -match "bottle-oauthlib" } { $packages += @('bottle-oauthlib') }
			{ $_ -match "bottle-redis" } { $packages += @('bottle-redis') }
			{ $_ -match "bottle-renderer" } { $packages += @('bottle-renderer') }
			{ $_ -match "bottle-servefiles" } { $packages += @('bottle-servefiles') }
			{ $_ -match "bottle-sqlalchemy" } { $packages += @('bottle-sqlalchemy') }
			{ $_ -match "bottle-sqlite" } { $packages += @('bottle-sqlite') }
			{ $_ -match "bottle-web2pydal" } { $packages += @('bottle-web2pydal') }
			{ $_ -match "bottle-werkzeug" } { $packages += @('bottle-werkzeug') }
			{ $_ -match "bottlejwt" } { $packages += @('bottlejwt') }
			{ $_ -match "canister" } { $packages += @('canister') }
		}

		switch ($ProjectManager) {
			"pdm" { foreach ($p in $packages) { pdm add --quiet --no-sync "$p" } }
			"pipenv" { foreach ($p in $packages) { gum spin --title="pipenv: installing $p ..." -- pipenv install "$p" } }
			"poetry" { foreach ($p in $packages) { poetry add --quiet -- "$p" } }
			"rye" { foreach ($p in $packages) { rye add --quiet "$p" } }
			"uv" { foreach ($p in $packages) { uv add --no-sync --no-progress -q "$p" } }
		}

		Write-LinkInformation "https://bottlepy.org/docs/dev/plugins/list.html"
	}
}
