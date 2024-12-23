function Initialize-ProjectPython-Flask {
	param ([string]$ProjectManager, [switch]$Addons)

	if ($Addons) {
		Write-Host "LITESTAR (Starlite) ADDONS:" -ForegroundColor Blue
		Write-Host "---------------------------" -ForegroundColor Blue

		$packages = @()
		$liteStarAddons = (gum choose --no-limit --header="Choose Litestar Addons:" "apitally" "dishka" "litestar-aiosql" "litestar-asyncpg" "litestar-granian" "litestar-mqtt" "litestar-piccolo" "litestar-saq" "litestar-users" "piccolo_admin" "piccolo" "pyinstrument" "sentry-sdk" "sqladmin-litestar-plugin" "strawberry-graphql" "taskiq-litestar").Trim()
		switch ($liteStarAddons) {
			{ $_ -match "apitally" } { $packages += @('apitally[litestar]') }
			{ $_ -match "dishka" } { $packages += @('dishka') }
			{ $_ -match "litestar-aiosql" } { $packages += @('litestar-aiosql') }
			{ $_ -match "litestar-asyncpg" } { $packages += @('litestar-asyncpg') }
			{ $_ -match "litestar-granian" } { $packages += @('litestar-granian') }
			{ $_ -match "litestar-mqtt" } { $packages += @('litestar-mqtt') }
			{ $_ -match "litestar-piccolo" } { $packages += @('litestar-piccolo') }
			{ $_ -match "litestar-saq" } { $packages += @('litestar-saq') }
			{ $_ -match "litestar-users" } { $packages += @('litestar-users') }
			{ $_ -match "piccolo_admin" } { $packages += @('piccolo_admin') }
			{ $_ -match "piccolo" } { $packages += @('piccolo[all]') }
			{ $_ -match "pyinstrument" } { $packages += @('pyinstrument') }
			{ $_ -match "sentry-sdk" } { $packages += @('sentry-sdk[litestar]') }
			{ $_ -match "sqladmin-litestar-plugin" } { $packages += @('sqladmin-litestar-plugin') }
			{ $_ -match "strawberry-graphql" } { $packages += @('strawberry-graphql[debug-server]') }
			{ $_ -match "taskiq-litestar" } { $packages += @('taskiq-litestar') }
		}

		switch ($ProjectManager) {
			"pdm" { foreach ($p in $packages) { pdm add --quiet --no-sync "$p" } }
			"pipenv" { foreach ($p in $packages) { gum spin --title="pipenv: installing $p ..." -- pipenv install "$p" } }
			"poetry" { foreach ($p in $packages) { poetry add --quiet -- "$p" } }
			"rye" { foreach ($p in $packages) { rye add --quiet "$p" } }
			"uv" { foreach ($p in $packages) { uv add --no-sync --no-progress -q "$p" } }
		}

		Write-LinkInformation "https://github.com/litestar-org/awesome-litestar"
	}
}
