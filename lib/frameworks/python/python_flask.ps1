function Initialize-ProjectPython-Flask {
	param ([string]$ProjectManager, [switch]$Addons)

	if ($Addons) {
		Write-Host "FLASK ADDONS:" -ForegroundColor Blue
		Write-Host "-------------" -ForegroundColor Blue

		$packages = @()
		$flaskAddons = (gum choose --no-limit --header="Choose Flask Addons:" "APIFlask" "Apitally" "Celery" "Connexion" "Dishka" "Eve" "Flasgger" "Flask-Admin" "Flask-Caching" "Flask-Classful" "Flask-Dance" "Flask-Excel" "Flask-GraphQL" "Flask-HTTPAuth" "Flask-Limiter" "Flask-Login" "Flask-Marshmallow" "Flask-Meld" "Flask-Migrate" "Flask-Paginate" "Flask-Pydantic" "Flask-RESTful" "Flask-RESTX" "Flask-Security" "Flask-Smorest" "Flask-SocketIO" "Flask-WTF" "ReactPy" "Sentry-SDK").Trim()

		switch ($flaskAddons) {
			{ $_ -match "APIFlask" } { $packages += @('apiflask') }
			{ $_ -match "Apitally" } { $packages += @('apitally[flask]') }
			{ $_ -match "Celery" } { $packages += @('celery') }
			{ $_ -match "Connexion" } {
				$depsAdd = $(Write-Host "Add more builtin dependencies for Connexion? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') {
					$deps = (gum choose --no-limit --header="Choose Connexion Dependencies:" "flask" "swagger-ui" "uvicorn").Trim()
					if ($deps.Count -eq 1) { $packages += @("connexion[$deps]") }
					else {
						$depsList += "$deps"; $depsList = $depsList -replace ' ', ','
						$packages += @("connexion[$depsList]")
					}
				} else { $packages += @('connexion') }
			}
			{ $_ -match "Dishka" } { $packages += @('dishka') }
			{ $_ -match "Eve" } { $packages += @('Eve') }
			{ $_ -match "Flasgger" } { $packages += @('flasgger==0.9.7b2') }
			{ $_ -match "Flask-Admin" } { $packages += @('flask-admin') }
			{ $_ -match "Flask-Caching" } { $packages += @('Flask-Caching') }
			{ $_ -match "Flask-Classful" } { $packages += @('flask-classful') }
			{ $_ -match "Flask-Dance" } {
				$depsAdd = $(Write-Host "Integrate Flask-Dance with SQLAlchemy storage? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') { $packages += @('Flask-Dance[sqla]') }
				else { $packages += @('Flask-Dance') }
			}
			{ $_ -match "Flask-Excel" } { $packages += @('Flask-Excel') }
			{ $_ -match "Flask-GraphQL" } { $packages += @('Flask-GraphQL') }
			{ $_ -match "Flask-HTTPAuth" } { $packages += @('Flask-HTTPAuth') }
			{ $_ -match "Flask-Limiter" } {
				$depsAdd = $(Write-Host "Add more builtin dependencies for Flask Limiter? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') {
					$deps = (gum choose --no-limit --header="Choose Flask Limiter Dependencies:" "redis" "memcached" "mongodb").Trim()
					if ($deps.Count -eq 1) { $packages += @("Flask-Limiter[$deps]") }
					else {
						$depsList += "$deps"; $depsList = $depsList -replace ' ', ','
						$packages += @("Flask-Limiter[$depsList]")
					}
				} else { $packages += @('Flask-Limiter') }
			}
			{ $_ -match "Flask-Login" } { $packages += @('flask-login') }
			{ $_ -match "Flask-Marshmallow" } {
				$depsAdd = $(Write-Host "Integrate Flask-Marshmallow with Flask-SQLAlchemy? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') { $packages += @('flask-marshmallow', 'flask-sqlalchemy', 'marshmallow-sqlalchemy') }
				else { $packages += @('flask-marshmallow') }
			}
			{ $_ -match "Flask-Meld" } { $packages += @('flask-meld') }
			{ $_ -match "Flask-Migrate" } { $packages += @('Flask-Migrate') }
			{ $_ -match "Flask-Paginate" } { $packages += @('flask-paginate') }
			{ $_ -match "Flask-Pydantic" } { $packages += @('Flask-Pydantic') }
			{ $_ -match "Flask-RESTful" } { $packages += @('flask-restful') }
			{ $_ -match "Flask-RESTX" } { $packages += @('flask-restx') }
			{ $_ -match "Flask-Security" } {
				$depsAdd = $(Write-Host "Add more builtin dependencies for Flask Security? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') {
					$deps = (gum choose --no-limit --header="Choose Flask Security Dependencies:" "babel" "common" "fsqla" "mfa").Trim()
					if ($deps.Count -eq 1) { $packages += @("flask-security[$deps]") }
					else {
						$depsList += "$deps"; $depsList = $depsList -replace ' ', ','
						$packages += @("flask-security[$depsList]")
					}
				} else { $packages += @('flask-security') }
			}
			{ $_ -match "Flask-Smorest" } { $packages += @('flask-smorest') }
			{ $_ -match "Flask-SocketIO" } { $packages += @('flask-socketio') }
			{ $_ -match "Flask-WTF" } { $packages += @('Flask-WTF') }
			{ $_ -match "ReactPy" } { $packages += @('reactpy[flask]') }
			{ $_ -match "Sentry-SDK" } { $packages += @('sentry-sdk[flask]') }
		}

		switch ($ProjectManager) {
			"pdm" { foreach ($p in $packages) { pdm add --quiet --no-sync "$p" } }
			"pipenv" { foreach ($p in $packages) { gum spin --title="pipenv: installing $p ..." -- pipenv install "$p" } }
			"poetry" { foreach ($p in $packages) { poetry add --quiet -- "$p" } }
			"rye" { foreach ($p in $packages) { rye add --quiet "$p" } }
			"uv" { foreach ($p in $packages) { uv add --no-sync --no-progress -q "$p" } }
		}

		Write-LinkInformation "https://github.com/humiaozuzu/awesome-flask"
	}
}
