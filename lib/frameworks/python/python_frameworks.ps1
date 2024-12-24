function Add-PythonPackages {
	param (
		[string]$ProjectManager,
		[array]$List
	)

	$addPythonPackages = Write-YesNoQuestion "Add Python Web Frameworks from existing list (Y) or manually (n)?"

	if ($addPythonPackages.ToUpper() -eq 'Y') {
		$frameworkList = Get-Content "$PSScriptRoot/lists/python_frameworks.txt"
		$chooseFrameworks = gum choose --no-limit --header="Choose Python Web Frameworks:" $frameworkList
		$addonsList = $chooseFrameworks
		$List = $chooseFrameworks

		switch ($addonsList) {
			{ $_ -match "Bottle" } {
				$addBottle = Write-YesNoQuestion "Install Add-Ons for Bottle?"
				if ($addBottle.ToUpper() -eq "Y") {
					$addonsBottleList = Get-Content "$PSScriptRoot/lists/bottle_addons.txt"
					$addonsBottle = gum choose --no-limit --header="Choose Add-Ons for Bottle:" $addonsBottleList
					$List += $addonsBottle
				}
				Write-LinkInformation "https://bottlepy.org/docs/dev/plugins/list.html"
			}

			{ $_ -match "Django" } {
				$addDjango = Write-YesNoQuestion "Install Add-Ons for Django?"
				if ($addDjango.ToUpper() -eq "Y") {
					$addonsDjangoList = Get-Content "$PSScriptRoot/lists/django_addons.txt"
					$addonsDjango = gum choose --no-limit --header="Choose Add-Ons for Django:" $addonsDjangoList
					$List += $addonsDjango
				}
				Write-LinkInformation "https://github.com/wsvincent/awesome-django"
			}

			{ $_ -match "djangorestframework" } {
				$addDRF = Write-YesNoQuestion "Install Add-Ons for Django-REST-Framework?"
				if ($addDRF.ToUpper() -eq 'Y') {
					$addonsDRFList = Get-Content "$PSScriptRoot/lists/drf_addons.txt"
					$addonsDRF = gum choose --no-limit --header="Choose Add-Ons for Django-REST-Framework:" $addonsDRFList
					$List += $addonsDRF
				}
				Write-LinkInformation "https://github.com/nioperas06/awesome-django-rest-framework"
			}

			{ $_ -match "Flask" } {
				$addFlask = Write-YesNoQuestion "Install Add-Ons for Flask?"
				if ($addFlask.ToUpper() -eq "Y") {
					$addonsFlaskList = Get-Content "$PSScriptRoot/lists/flask_addons.txt"
					$addonsFlask = gum choose --no-limit --header="Choose Add-Ons for Flask:" $addonsFlaskList
					$List += $addonsFlask
				}
				Write-LinkInformation "https://github.com/humiaozuzu/awesome-flask"
			}

			{ $_ -match "FastAPI" } {
				$addFastAPI = Write-YesNoQuestion "Install Add-Ons for FastAPI?"
				if ($addFastAPI.ToUpper() -eq "Y") {
					$addonsFastApiList = Get-Content "$PSScriptRoot/lists/fastapi_addons.txt"
					$addonsFastApi = gum choose --no-limit --header="Choose Add-Ons for FastAPI:" $addonsFastApiList
					$List += $addonsFastApi
				}
				Write-LinkInformation "https://github.com/mjhea0/awesome-fastapi"
			}

			{ $_ -match "Litestar" } {
				$addLitestar = Write-YesNoQuestion "Install Add-Ons for Litestar?"
				if ($addLitestar.ToUpper() -eq "Y") {
					$addonsLitestarList = Get-Content "$PSScriptRoot/lists/litestar_addons.txt"
					$addonsLitestar = gum choose --no-limit --header="Choose Add-Ons for Litestar:" $addonsLitestarList
					$List += $addonsLitestar
				}
				Write-LinkInformation "https://github.com/litestar-org/awesome-litestar"
			}
		}
	} else {
		$packagesList = Write-PromptInput -Prompt "Input Python Packages to install" -Example "Django reactpy-django"
		$List = $packagesList.Split(' ')
	}

	switch ($ProjectManager) {
		"pdm" {
			foreach ($pkg in $List) {
				$prettyPkg = gum style --italic --bold --foreground="#eba0ac" "$pkg"
				gum spin --title="Adding Package: $prettyPkg ..." -- pdm add $pkg
			}
			gum spin --title="Syncing pdm..." -- pdm sync
			# requirements.txt
			pdm export --quiet -o requirements.txt --without dev
		}

		"pipenv" {
			foreach ($pkg in $List) {
				$prettyPkg = gum style --italic --bold --foreground="#eba0ac" "$pkg"
				gum spin --title="Adding Package: $prettyPkg ..." -- pipenv install $pkg
			}
			# requirements.txt
			pipenv requirements > requirements.txt
		}

		"poetry" {
			foreach ($pkg in $List) {
				$prettyPkg = gum style --italic --bold --foreground="#eba0ac" "$pkg"
				gum spin --title="Adding Package: $prettyPkg ..." -- poetry add $pkg
			}
			# requirements.txt
			poetry export -f requirements.txt -o requirements.txt
		}

		"rye" {
			foreach ($pkg in $List) {
				$prettyPkg = gum style --italic --bold --foreground="#eba0ac" "$pkg"
				gum spin --title="Adding Package: $prettyPkg ..." -- rye add $pkg
			}
			gum spin --title="Syncing rye..." -- rye sync
		}

		"uv" {
			foreach ($pkg in $List) {
				$prettyPkg = gum style --italic --bold --foreground="#eba0ac" "$pkg"
				gum spin --title="Adding Package: $prettyPkg ..." -- rye add $pkg
			}
			gum spin --title="Syncing uv..." -- uv sync
			# requirements.txt
			uv pip compile pyproject.toml -o requirements.txt >$null 2>&1
		}
	}
}
