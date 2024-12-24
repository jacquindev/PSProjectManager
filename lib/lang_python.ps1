function Initialize-ProjectPython {
	param ([string]$ProjectRoot, [string]$ProjectName)

	$prjManager = (gum choose --limit=1 --header="Choose A Project Manager:" "pdm" "pipenv" "poetry" "rye" "uv")
	if (!(Get-Command "$prjManager" -ErrorAction SilentlyContinue)) {
		Write-Warning "Command not found: $prjManager. Please try another project manager or install to use this feature."
		return
	}

	foreach ($file in $(Get-ChildItem -Path "$PSScriptRoot/frameworks/python/*" -Include *.ps1 -Recurse)) {
		. "$file"
	}
	Remove-Variable file

	New-Item "$ProjectRoot/$ProjectName" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
	Set-Location "$ProjectRoot/$ProjectName"

	switch ($prjManager) {
		"pdm" { gum spin --title="Initialize project with pdm..." -- pdm init -n }
		"pipenv" { gum spin --title="Initialize project with pipenv..." -- pipenv install }
		"poetry" { gum spin --title="Initialize project with poetry..." -- poetry init -n }
		"rye" { gum spin --title="Initialize project with rye..." -- rye init }
		"uv" { gum spin --title="Initialize project with uv..." -- uv init }
	}

	$addFrameworks = Write-YesNoQuestion "Add Python Web Frameworks now (Y) or later (n)?"
	$addDevDependencies = Write-YesNoQuestion "Add Python DevDependencies now (Y) or later (n)?"

	if ($addFrameworks.ToUpper() -eq 'Y') { Add-PythonPackages -ProjectManager $prjManager }
	if ($addDevDependencies.ToUpper() -eq 'Y') { Add-PythonDevDependencies -ProjectManager $prjManager }

	if (!(Get-ChildItem -Recurse -Filter "activate.ps1" -ErrorAction SilentlyContinue)) { python -m venv .venv }

	& "./.venv/Scripts/activate.ps1"
	if ($?) { Write-Success -Entry1 "OK" -Entry2 "$ProjectName - .venv" -Text "activated." }
	else { Write-Error -Entry1 "ERR" -Entry2 "$ProjectName - .venv" -Text "failed to activate." }

	$langgitignore = "python"

	if ((Test-Path "./requirements.txt") -or (Test-Path "./requirements.lock")) {
		if (Select-String "./requirements.*" -Pattern 'django' -SimpleMatch -Quiet) {
			$langgitignore += ",django"

			switch -regex ($ProjectName) {
				"^[a-z]+(-[a-z]+)*$" { $subProjectName = (Convert-NamingConventionCase -inputString "$ProjectName" -snake).Trim() }
				"^[a-z]+(?:_[a-z]+)*$" { $subProjectName = (Convert-NamingConventionCase -inputString "$ProjectName" -kebab).Trim() }
				"^[A-Z][a-z]+(?:[A-Z][a-z]+)*$" {	$subProjectName = $ProjectName.ToLower() }
			}

			switch ($prjManager) {
				"pdm" { pdm run django-admin startproject $subProjectName . }
				"pipenv" { pipenv run django-admin startproject $subProjectName . }
				"poetry" { poetry run django-admin startproject $subProjectName . }
				"rye" {
					if (Test-Path "./src/$subProjectName" -PathType Container) { Remove-Item "./src/$subProjectName" -Recurse -Force -ErrorAction SilentlyContinue }
					rye run django-admin startproject $subProjectName src
				}
				"uv" { uv run django-admin startproject $subProjectName . }
			}

			$djangoAppName = Write-PromptInput -Prompt "Input your Django App Name" -Example "todos"
			python manage.py startapp $djangoAppName
		}
		if (Select-String "./requirements.*" -Pattern 'flask' -SimpleMatch -Quiet) { $langgitignore += ",flask" }
	}

	Add-ProjectGitignore -ProjectPath "$ProjectRoot/$ProjectName" -ProjectFramework "$langgitignore"
	Add-License -ProjectRoot $ProjectRoot -ProjectName $ProjectName
	Add-Readme -ProjectRoot $ProjectRoot -ProjectName $ProjectName
}
