function Initialize-ProjectPython-Fastapi {
	param ([string]$ProjectManager, [switch]$Addons)

	if ($Addons) {
		Write-Host "FASTAPI ADDONS:" -ForegroundColor Blue
		Write-Host "---------------" -ForegroundColor Blue

		$packages = @()
		$fastApiAddons = (gum choose --no-limit --header="Choose FastAPI Addons:" "apitally" "authx" "beanie" "databases" "dishka" "edgy" "fastapi-admin" "fastapi-amis-admin" "fastapi-azure-auth" "fastapi-cache" "fastapi-camelcase" "fastapi-cloudauth" "fastapi-code-generator" "fastapi-cruddy-framework" "fastapi-crudrouter" "fastapi-events" "fastapi-mail" "fastapi-mvc" "fastapi-jwt-auth" "fastapi-lazy" "fastapi-limiter" "fastapi-login" "fastapi-pagination" "fastapi-simple-security" "fastapi-sqla" "fastapi-sqlalchemy" "fastapi-users" "fastapi-utils" "fastapi-versioning" "FastAPIwee" "gino" "orm" "ormar" "mongoengine" "motor" "piccolo" "prisma" "prometheus-fastapi-instrumentator" "pyinstrument" "pynamodb" "reactpy" "saffier" "sentry-sdk" "slowapi" "strawberry-graphql" "sqladmin" "sqlmodel" "tortoise-orm").Trim()

		switch ($fastApiAddons) {
			{ $_ -match "apitally" } { $packages += @('apitally[fastapi]') }
			{ $_ -match "authx" } { $packages += @('authx', 'authx-extra') }
			{ $_ -match "beanie" } {
				$depsAdd = $(Write-Host "Add optional dependencies for 'beanie'? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') {
					$deps = (gum choose --no-limit --header="Choose Beanie Optional Dependencies:" "gssapi" "aws" "srv" "ocsp" "snappy" "zstd" "encryption").Trim()
					if ($deps.Count -eq 1) { $packages += @("beanie[$deps]") }
					else {
						$depsList += "$deps"; $depsList = $depsList -replace ' ', ','
						$packages += @("beanie[$depsList]")
					}
				} else { $packages += @('beanie') }
			}
			{ $_ -match "databases" } {
				$depsAdd = $(Write-Host "Choose specific supported database driver for 'databases'? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') {
					$deps = (gum choose --limit=1 --header="Choose A Database Supported Driver:" "asyncpg" "aiopg" "aiomysql" "asyncmy" "aiosqlite").Trim()
					$packages += @("databases[$deps]")
				} else { $packages += @('databases') }
			}
			{ $_ -match "dishka" } { $packages += @('dishka') }
			{ $_ -match "edgy" } {
				$depsAdd = $(Write-Host "Choose A Specific Database Driver for 'edgy'? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') {
					$deps = (gum choose --limit=1 --header="Choose A Database Supported Driver:" "postgres" "mysql" "sqlite").Trim()
					$packages += @("edgy[$deps]")
				} else { $packages += @('edgy') }
			}
			{ $_ -match "fastapi-admin" } { $packages += @('fastapi-admin') }
			{ $_ -match "fastapi-amis-admin" } { $packages += @('fastapi_admis_admin') }
			{ $_ -match "fastapi-azure-auth" } { $packages += @('fastapi-azure-auth') }
			{ $_ -match "fastapi-cache" } {
				$depsAdd = $(Write-Host "Choose specific supported fastapi-cache backend? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') {
					$deps = (gum choose --limit=1 --header="Choose A Supported Backend:" "dynamodb" "memcache" "redis").Trim()
					switch ($deps) {
						"dynamodb" { $packages += @('fastapi-cache2[dynamodb]') }
						"memcache" { $packages += @('fastapi-cache2[memcache]') }
						"redis" { $packages += @('fastapi-cache2[redis]') }
					}
				} else { $packages += @('fastapi-cache2') }
			}
			{ $_ -match "fastapi-camelcase" } { $packages += @('fastapi-camelcase') }
			{ $_ -match "fastapi-cloudauth" } { $packages += @('fastapi-cloudauth') }
			{ $_ -match "fastapi-code-generator" } { $packages += @('fastapi-code-generator') }
			{ $_ -match "fastapi-cruddy-framework" } { $packages += @('fastapi-cruddy-framework') }
			{ $_ -match "fastapi-crudrouter" } { $packages += @('fastapi-crudrouter') }
			{ $_ -match "fastapi-events" } {
				$depsAdd = $(Write-Host "Choose a specific handler for 'fastapi-events'? (y/n)" -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') {
					$deps = (gum choose --limit=1 --header="Choose A Handler for 'fastapi-events':" "aws" "google" "otel").Trim()
					switch ($deps) {
						"aws" { $packages += @('fastapi-events[aws]') }
						"google" { $packages += @('fastapi-events[google]') }
						"otel" { $packages += @('fastapi-events[otel]') }
					}
				}
			}
			{ $_ -match "fastapi-mail" } { $packages += @('fastapi-mail') }
			{ $_ -match "fastapi-mvc" } { $packages += @('fastapi-mvc') }
			{ $_ -match "fastapi-jwt-auth" } { $packages += @('fastapi-jwt-auth') }
			{ $_ -match "fastapi-lazy" } { $packages += @('fastapi-lazy') }
			{ $_ -match "fastapi-limiter" } { $packages += @('fastapi-limiter') }
			{ $_ -match "fastapi-login" } { $packages += @('fastapi-login') }
			{ $_ -match "fastapi-pagination" } { $packages += @('fastapi-pagination') }
			{ $_ -match "fastapi-simple-security" } { $packages += @('fastapi_simple_security') }
			{ $_ -match "fastapi-sqla" } { $packages += @('fastapi-sqla') }
			{ $_ -match "fastapi-sqlalchemy" } { $packages += @('fastapi-sqlalchemy') }
			{ $_ -match "fastapi-users" } {
				$depsAdd = $(Write-Host "Add FastAPI Users dependencies? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') {
					$deps = (gum choose --no-limit --header="Choose FastAPI Users Dependencies:" "sqlalchemy" "beanie" "redis" "oath").Trim()
					if ($deps.Count -eq 1) { $packages += @("fastapi-users[$deps]") }
					else {
						$depsList += "$deps"; $depsList = $depsList -replace ' ', ','
						$packages += @("fastapi-users[$depsList]")
					}
				} else { $packages += @('fastapi-users') }
			}
			{ $_ -match "fastapi-utils" } {
				$deps = (gum choose --limit=1 --header="Choose A FastAPI Utils Installation Option:" "basic slim package" "add sqlalchemy session maker" "all the packages").Trim()
				switch ($deps) {
					"basic slim package" { $packages += @('fastapi-utils') }
					"add sqlalchemy session maker" { $packages += @('fastapi-utils[session]') }
					"all the packages" { $packages += @('fastapi-utils[all]') }
				}
			}
			{ $_ -match "fastapi-versioning" } { $packages += @('fastapi-versioning') }
			{ $_ -match "FastAPIwee" } { $packages += @('FastAPIwee') }
			{ $_ -match "gino" } { $packages += @('gino') }
			{ $_ -match "odmantic" } { $packages += @('odmantic') }
			{ $_ -match "orm" } {
				$depsAdd = $(Write-Host "Choose specific supported database driver for ORM? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') {
					$deps = (gum choose --limit=1 --header="Choose A Database Supported Driver:" "postgresql" "mysql" "sqlite").Trim()
					$packages += @("orm[$deps]")
				} else { $packages += @('orm') }
			}
			{ $_ -match "ormar" } {
				$depsAdd = $(Write-Host "Choose A Specific Database Driver for 'ormar'? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') {
					$deps = (gum choose --limit=1 --header="Choose A Database Supported Driver:" "postgresql" "mysql" "sqlite").Trim()
					$packages += @("ormar[$deps]")
				} else { $packages += @('ormar') }
			}
			{ $_ -match "mongoengine" } { $packages += @('mongoengine') }
			{ $_ -match "motor" } { $packages += @('motor') }
			{ $_ -match "piccolo" } { $packages += @('piccolo[all]') }
			{ $_ -match "prisma" } { $packages += @('prisma') }
			{ $_ -match "prometheus-fastapi-instrumentator" } { $packages += @('prometheus-fastapi-instrumentator') }
			{ $_ -match "pyinstrument" } { $packages += @('pyinstrument') }
			{ $_ -match "pynamodb" } { $packages += @('pynamodb') }
			{ $_ -match "reactpy" } { $packages += @('reactpy[fastapi]') }
			{ $_ -match "saffier" } {
				$depsAdd = $(Write-Host "Choose specific supported database driver for 'saffier'? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') {
					$deps = (gum choose --limit=1 --header="Choose A Database Supported Driver:" "postgres" "mysql" "sqlite").Trim()
					$packages += @("saffier[$deps]")
				} else { $packages += @('saffier') }
			}
			{ $_ -match "sentry-sdk" } { $packages += @('sentry-sdk[fastapi]') }
			{ $_ -match "slowapi" } { $packages += @('slowapi') }
			{ $_ -match "strawberry-graphql" } { $packages += @('strawberry-graphql[debug-server]') }
			{ $_ -match "sqladmin" } { $packages += @('sqladmin[full]') }
			{ $_ -match "sqlmodel" } { $packages += @('sqlmodel') }
			{ $_ -match "tortoise-orm" } {
				$depsAdd = $(Write-Host "Choose A Specific Database Driver for 'tortoise-orm'? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') {
					$deps = (gum choose --limit=1 --header="Choose A Database Supported Driver:" "asyncpg" "asyncmy" "asyncodbc").Trim()
					$packages += @("tortoise-orm[$deps]")
				} else { $packages += @('tortoise-orm') }
			}
		}


		switch ($ProjectManager) {
			"pdm" { foreach ($p in $packages) { pdm add --quiet --no-sync "$p" } }
			"pipenv" { foreach ($p in $packages) { gum spin --title="pipenv: installing $p ..." -- pipenv install "$p" } }
			"poetry" { foreach ($p in $packages) { poetry add --quiet -- "$p" } }
			"rye" { foreach ($p in $packages) { rye add --quiet "$p" } }
			"uv" { foreach ($p in $packages) { uv add --no-sync --no-progress -q "$p" } }
		}

		Write-LinkInformation "https://github.com/mjhea0/awesome-fastapi"
	}
}
