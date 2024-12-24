foreach ($file in $(Get-ChildItem -Path "$PSScriptRoot/frameworks/python/*" -Include *.ps1 -Recurse)) {
	. "$file"
}
Remove-Variable file

function Initialize-ProjectPython {
	param (
		[string]$ProjectRoot,
		[string]$ProjectName,
		[switch]$WebFramework,
		[switch]$DevDependencies
	)

	# Set working directory
	Set-Location $PSScriptRoot
	[Environment]::CurrentDirectory = $PSScriptRoot

	$langgitignore = "python"
	$prjManager = (gum choose --limit=1 --header="Choose a Project Manager:" "pdm" "pipenv" "poetry" "rye" "uv").Trim()
	@('pdm', 'pipenv', 'poetry', 'rye', 'uv') | ForEach-Object {
		if ($prjManager -eq "$_") {
			if (!(Get-Command $_ -ErrorAction SilentlyContinue)) {
				Write-Warning "Command not found: $_. Please install to use this feature."; return
			}
		}
	}

	Set-Location "$ProjectRoot"

	$pyPkgs = @()
	if ($WebFramework) {
		$pythonFrameworks = (gum choose --no-limit --header="Choose Python Web Frameworks:" "Aiohttp" "Bottle" "Django" "FastAPI" "Falcon" "Flask" "Litestar" "Pyramid" "Quart" "Sanic").Trim()
		switch ($pythonFrameworks) {
			{ $_ -match "Aiohttp" } { $pyPkgs += @('aiohttp[speedups]') }
			{ $_ -match "Bottle" } {
				$pyPkgs += @('bottle')
				$bottleAddons = $(Write-Host "Install Bottle Plugins? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($bottleAddons.ToUpper() -eq 'Y') { $bottleAdd = $True } else { $bottleAdd = $False }
			}
			{ $_ -match "Django" } {
				$pyPkgs += @('django')
				$langgitignore += ",django"
				$djangoAddons = $(Write-Host "Install Addons for Django? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($djangoAddons.ToUpper() -eq 'Y') { $djangoAdd = $True } else { $djangoAdd = $False }
			}
			{ $_ -match "FastAPI" } {
				$pyPkgs += @('fastapi[standard]')
				$fastapiAddons = $(Write-Host "Install Addons for FastAPI? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($fastapiAddons.ToUpper() -eq 'Y') { $fastapiAdd = $True } else { $fastapiAdd = $False }
			}
			{ $_ -match "Falcon" } { $pyPkgs += @('falcon') }
			{ $_ -match "Flask" } {
				$pyPkgs += @('flask')
				$langgitignore += ",flask"
				$flaskAddons = $(Write-Host "Install Addons for Flask? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($flaskAddons.ToUpper() -eq 'Y') { $flaskAdd = $True } else { $flaskAdd = $False }
			}
			{ $_ -match "Litestar" } {
				$litestarExtras = $(Write-Host "Install Litestar Extras? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($litestarExtras.ToUpper() -eq 'Y') {
					$lsExtras = (gum choose "Choose Litestar Builtin Extras: " "pydantic" "attrs" "brotli" "cryptography" "jwt" "redis" "picologging" "structlog" "prometheus" "opentelemetry" "sqlalchemy" "jinja" "make" "standard").Trim()
					if ($lsExtras.Count -eq 1) { $pyPkgs += @("litestar[$lsExtras]") }
					else {
						$lsList += "$lsExtras"; $lsList = $lsList -replace ' ', ','
						$pyPkgs += @("litestar[$lsList]")
					}
				} else {
					$pyPkgs += @('litestar[standard]')
				}
				$litestarAddons = $(Write-Host "Install Addons for Litestar? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($litestarAddons.ToUpper() -eq 'Y') { $litestarAdd = $True } else { $litestarAdd = $False }
			}
			{ $_ -match "Pyramid" } { $pyPkgs += @('pyramid') }
			{ $_ -match "Quart" } { $pyPkgs += @('quart') }
			{ $_ -match "Sanic" } { $pyPkgs += @('sanic') }
		}
	} else {
		$inputPkgs = (gum input --prompt="Input packages to install ( separated with [SPACE] ): " --placeholder="E.g: httpie wheel")
		if ($null -ne $inputPkgs) {
			$inputPkgs = $inputPkgs.Split(' ')
			foreach ($pg in $inputPkgs) { $pyPkgs += @("$pg") }
		} else {
			Write-Host "No packages specified. Skipping..." -ForegroundColor DarkGray
			$pyPkgs = $null
		}
	}

	$pyDevs = @()
	if ($DevDependencies) {
		$pythonDevDependencies = (gum choose --no-limit --header="Choose Project Dev Dependencies:" "autopep8" "bumpversion" "flake8" "isort" "httpx" "numpy" "pylint" "python-coveralls" "python-dotenv" "pytest" "ruff" "tox" "wheel").Trim()

		switch ($pythonDevDependencies) {
			{ $_ -match "autopep8" } { $pyDevs += @('autopep8') }
			{ $_ -match "black" } { $pyDevs += @('black') }
			{ $_ -match "bumpversion" } { $pyDevs += @('bumpversion') }
			{ $_ -match "coveragepy" } { $pyDevs += @('coveragepy') }
			{ $_ -match "flake8" } { $pyDevs += @('flake8') }
			{ $_ -match "isort" } { $pyDevs += @('isort') }
			{ $_ -match "ipython" } { $pyDevs += @('ipython') }
			{ $_ -match "httpx" } { $pyDevs += @('httpx') }
			{ $_ -match "numpy" } { $pyDevs += @('numpy') }
			{ $_ -match "pylint" } { $pyDevs += @('pylint') }
			{ $_ -match "python-coveralls" } { $pyDevs += @('python-coveralls') }
			{ $_ -match "python-dotenv" } { $pyDevs += @('python-dotenv') }
			{ $_ -match "pytest" } { $pyDevs += @('pytest') }
			{ $_ -match "ruff" } { $pyDevs += @('ruff') }
			{ $_ -match "tox" } { $pyDevs += @('tox') }
		}
	} else {
		$inputDevs = (gum input --prompt="Input dev dependencies to install - separated with [SPACE] : " --placeholder="E.g: pytest pytest-django")
		if ($null -ne $inputDevs) {
			$inputDevs = $inputDevs.Split(' ')
			foreach ($dv in $inputDevs) { $pyDevs += @("$dv") }
		} else {
			Write-Host "No dev dependencies specified. Skipping..." -ForegroundColor DarkGray
			$pyDevs = $null
		}
	}

	switch ($prjManager) {
		"pdm" {
			# uv integration for pdm
			if ((Get-Command uv -ErrorAction SilentlyContinue) -and (!(pdm config | Select-String 'use_uv = True'))) {
				pdm config use_uv true
			}

			# init new project
			New-Item -Path "$ProjectRoot/$ProjectName" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
			Set-Location "./$ProjectName"
			gum spin --title="Intializing project with pdm..." -- pdm init -n

			if ($null -ne $pyPkgs) { foreach ($pythonPkg in $pyPkgs) { pdm add --quiet --no-sync "$pythonPkg" } }
			if ($null -ne $pyDevs) { foreach ($pythonDev in $pyDevs) { pdm add --dev --quiet --no-sync "$pythonDev" } }

			pdm sync --quiet

			# requirements.txt
			pdm export --quiet -o requirements.txt --without dev
			if ($?) { Write-Success -Entry1 "OK" -Entry2 "requirements.txt" -Text "added in project $ProjectName." }

			# virtual environment
			$activateScript = Get-ChildItem -Recurse -Filter "activate.ps1" -ErrorAction SilentlyContinue
			if ($null -ne $activateScript) { $activateScript = $activateScript.FullName }
			else { $activateScript = ((pdm venv list | Select-Object -last 1).Split(' ')[3].Trim()) }
			& ($activateScript)
			if ($?) { Write-Success -Entry1 "OK" -Entry2 "$ProjectName - .venv" -Text "activated." }
		}

		"pipenv" {
			# init new project
			New-Item "$ProjectName" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
			Set-Location "./$ProjectName"
			gum spin --title="Intializing project with pipenv..." -- pipenv install

			if ($null -ne $pyPkgs) { foreach ($pythonPkg in $pyPkgs) { gum spin --title="Pipenv: Installing $pythonPkg..." -- pipenv install "$pythonPkg" } }
			if ($null -ne $pyDevs) { foreach ($pythonDev in $pyDevs) { gum spin --title="Pipenv: Installing $pythonDev (dev)..." -- pipenv install "$pythonDev" --dev } }

			# requirements.txt
			pipenv requirements > requirements.txt
			if ($?) { Write-Success -Entry1 "OK" -Entry2 "requirements.txt" -Text "added in project $ProjectName." }

			# virtual environment
			$activateScript = Get-ChildItem -Recurse -Filter "activate.ps1" -ErrorAction SilentlyContinue
			if ($null -ne $activateScript) { $activateScript = $activateScript.FullName }
			else { $activateScript = ((poetry env info --path) + "\Scripts\activate.ps1") }
			& ($activateScript)
			if ($?) { Write-Success -Entry1 "OK" -Entry2 "$ProjectName - .venv" -Text "activated." }
		}

		"poetry" {
			# init new project
			poetry new "$ProjectName"
			Set-Location "./$ProjectName"
			gum spin --title="Intializing project with poetry..." -- poetry install

			if ($null -ne $pyPkgs) { foreach ($pythonPkg in $pyPkgs) { poetry add --quiet -- "$pythonPkg" } }
			if ($null -ne $pyDevs) { foreach ($pythonDev in $pyDevs) { poetry add --quiet --group=dev -- "$pythonDev" } }

			# requirements.txt
			if (poetry self show plugins | Select-String 'poetry-plugin-export') {
				poetry export -f requirements.txt -o requirements.txt
				if ($?) { Write-Success -Entry1 "OK" -Entry2 "requirements.txt" -Text "added in project $ProjectName." }
			}

			# virtual environment
			$activateScript = Get-ChildItem -Recurse -Filter "activate.ps1" -ErrorAction SilentlyContinue
			if ($null -ne $activateScript) { $activateScript = $activateScript.FullName }
			else { $activateScript = ((poetry env info --path) + "\Scripts\activate.ps1") }
			& ($activateScript)
			if ($?) { Write-Success -Entry1 "OK" -Entry2 "$ProjectName - .venv" -Text "activated." }
		}

		"rye" {
			# init new project
			$ryeRust = $(Write-Host "Develop Rust Python extension modules? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
			if ($ryeRust.ToUpper() -eq 'Y') { rye init $ProjectName --build-system maturin }
			else { rye ini $ProjectName }
			Set-Location "./$ProjectName"

			if ($null -ne $pyPkgs) { foreach ($pythonPkg in $pyPkgs) { rye add --quiet "$pythonPkg" } }
			if ($null -ne $pyDevs) { foreach ($pythonDev in $pyDevs) { rye add --dev --quiet "$pythonDev" } }

			rye sync --quiet

			$activateScript = Get-ChildItem -Recurse -Filter "activate.ps1" -ErrorAction SilentlyContinue
			if ($null -ne $activateScript) { $activateScript = $activateScript.FullName }
			else { python -m venv .venv; $activateScript = $activateScript.FullName }
			& ($activateScript)
			if ($?) { Write-Success -Entry1 "OK" -Entry2 "$ProjectName - .venv" -Text "activated." }
		}

		"uv" {
			# init new project
			uv init $ProjectName
			Set-Location "./$ProjectName"

			if ($null -ne $pyPkgs) { foreach ($pythonPkg in $pyPkgs) { uv add --no-sync --no-progress -q "$pythonPkg" } }
			if ($null -ne $pyDevs) { foreach ($pythonDev in $pyDevs) { uv add --dev --no-sync --no-progress -q "$pythonDev" } }

			uv sync --quiet

			# requirements.txt
			uv pip compile pyproject.toml -o requirements.txt >$null 2>&1
			if ($?) { Write-Success -Entry1 "OK" -Entry2 "requirements.txt" -Text "added in project $ProjectName." }

			# virtual environment
			$activateScript = Get-ChildItem -Recurse -Filter "activate.ps1" -ErrorAction SilentlyContinue
			if ($null -ne $activateScript) { $activateScript = $activateScript.FullName }
			else { python -m venv .venv; $activateScript = $activateScript.FullName }
			& ($activateScript)
			if ($?) { Write-Success -Entry1 "OK" -Entry2 "$ProjectName - .venv" -Text "activated." }
		}
	}

	if ($pyPkgs -match "bottle") { Initialize-ProjectPython-Bottle -ProjectManager $prjManager -Addons:$bottleAdd }
	if ($pyPkgs -match "django") {
		Initialize-ProjectPython-Django -Name $ProjectName -ProjectManager $prjManager -Addons:$djangoAdd
		$djangoAppName = (gum input --prompt="Input your App Name: " --placeholder="E.g: todos")
		python manage.py startapp $djangoAppName
	}
	if ($pyPkgs -match "fastapi[standard]") { Initialize-ProjectPython-Fastapi -ProjectManager $prjManager -Addons:$fastapiAdd }
	if ($pyPkgs -match "flask") { Initialize-ProjectPython-Flask -ProjectManager $prjManager -Addons:$flaskAdd }
	if ($pyPkgs -match "litestar[standard]") { Initialize-ProjectPython-Litestar -ProjectManager $prjManager -Addons:$litestarAdd }

	Add-ProjectGitignore -ProjectPath "$ProjectRoot/$ProjectName" -ProjectFramework "$langgitignore"
	Remove-Variable langgitignore

	Add-License -ProjectRoot $ProjectRoot -ProjectName $ProjectName
	Add-Readme -ProjectRoot $ProjectRoot -ProjectName $ProjectName
}
