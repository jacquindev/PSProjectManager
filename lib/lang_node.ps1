function Initialize-ProjectNode {
	param (
		[string]$ProjectRoot,
		[string]$ProjectName
	)

	$langgitignore = "node"
	$pkgManager = (gum choose --limit=1 --header="Choose a Package Manager:" "bun" "npm" "pnpm" "yarn").Trim()
	@('bun', 'npm', 'pnpm', 'yarn') | ForEach-Object {
		if ($pkgManager -eq "$_") {
			if (!(Get-Command $_ -ErrorAction SilentlyContinue)) {
				Write-Warning "Command not found: $_. Please install to use this feature."; return
			}
		}
	}

	foreach ($file in $(Get-ChildItem -Path "$PSScriptRoot/frameworks/node/*" -Include *.ps1 -Recurse)) {
		. "$file"
	}
	Remove-Variable file

	Set-Location "$ProjectRoot"

	$nodeFrameworks = (gum choose --limit=1 --header="Choose a Project Framework:" "None" "AdonisJS" "Astro" "Angular" "NextJS" "Remix" "Parcel" "SvelteKit" "Vite").Trim()
	switch ($nodeFrameworks) {
		"None" {}
		"AdonisJS" {
			Initialize-ProjectNode-Adonisjs -Name $ProjectName
			switch ($pkgManager) {
				"bun" { bun install }
				"npm" { npm install -y }
				"pnpm" { pnpm install }
				"yarn" { yarn init -2 && yarn install }
			}
			Write-LinkInformation "https://docs.adonisjs.com/guides/preface/introduction"
		}
		"Astro" {
			$langgitignore += ",astro"
			$useTS = Write-YesNoQuestion  "Use TypeScript with ASTRO?"
			$useTW = Write-YesNoQuestion "Use TailwindCSS with ASTRO?"
			$addIntegrations = Write-YesNoQuestion "Add Astro Integrations?"

			if ($useTS.ToUpper() -eq 'Y') { $ts = $True } else { $ts = $False }
			if ($useTW.ToUpper() -eq 'Y') { $tw = $True } else { $tw = $False }
			if ($addIntegrations.ToUpper -eq 'Y') { $integration = $True } else { $integration = $False }

			Initialize-ProjectNode-Astro -Name $ProjectName -ProjectManager $pkgManager -ts:$ts -tw:$tw -integration:$integration
			Write-LinkInformation "https://docs.astro.build/en/guides/integrations-guide/"
		}
		"Angular" {
			$langgitignore += ",angular"
			$useTW = Write-YesNoQuestion "Use TailwindCSS with Angular?"
			if ($useTW.ToUpper() -eq 'Y') { $tw = $True } else { $tw = $False }

			Initialize-ProjectNode-Angular -Name $ProjectName -ProjectManager $pkgManager -tw:$tw
			Write-LinkInformation "https://angular.dev/overview"
		}
		"NextJS" {
			$langgitignore += ",nextjs"
			$useTS = Write-YesNoQuestion "Use TypeScript with NextJS?"
			$useTW = Write-YesNoQuestion "Use TailwindCSS with NextJS?"

			if ($useTS.ToUpper() -eq 'Y') { $ts = $True } else { $ts = $False }
			if ($useTW.ToUpper() -eq 'Y') { $tw = $True } else { $tw = $False }
			Initialize-ProjectNode-NextJS -Name $ProjectName -ProjectManager $pkgManager -tw:$tw -ts:$ts
			Write-LinkInformation "https://nextjs.org/docs"
		}
		"Remix" {
			$langgitignore += ",remix"
			$useTS = Write-YesNoQuestion "Use TypeScript with Remix?"
			$useTW = Write-YesNoQuestion "Use TailwindCSS with Remix?"

			if ($useTS.ToUpper() -eq 'Y') { $ts = $True } else { $ts = $False }
			if ($useTW.ToUpper() -eq 'Y') { $tw = $True } else { $tw = $False }
			Initialize-ProjectNode-Remix -Name $ProjectName -ProjectManager $pkgManager -tw:$tw -ts:$ts
			Write-LinkInformation "https://remix.run/docs/en/main"
		}
		"Parcel" {
			$useTS = Write-YesNoQuestion "Use TypeScript with Parcel?"
			$useTW = Write-YesNoQuestion "Use TailwindCSS with Parcel?"

			if ($useTS.ToUpper() -eq 'Y') { $ts = $True } else { $ts = $False }
			if ($useTW.ToUpper() -eq 'Y') { $tw = $True } else { $tw = $False }
			Initialize-ProjectNode-Parcel -Name $ProjectName -ProjectManager $pkgManager -tw:$tw -ts:$ts
			Write-LinkInformation "https://parceljs.org/docs/"
		}
		"SvelteKit" {
			$langgitignore += ",svelte"
			$useTS = Write-YesNoQuestion "Use TypeScript with SvelteKit?"
			$useTW = Write-YesNoQuestion "Use TailwindCSS with SvelteKit?"
			$addIntegrations = Write-YesNoQuestion "Add SvelteKit Integrations?"

			if ($useTS.ToUpper() -eq 'Y') { $ts = $True } else { $ts = $False }
			if ($useTW.ToUpper() -eq 'Y') { $tw = $True } else { $tw = $False }
			if ($addIntegrations.ToUpper -eq 'Y') { $integration = $True } else { $integration = $False }
			Initialize-ProjectNode-SvelteKit -Name $ProjectName -ProjectManager $pkgManager -ts:$ts -tw:$tw -integration:$integration
			Write-LinkInformation "https://svelte.dev/docs/kit/introduction"
		}
		"Vite" {
			$useTS = Write-YesNoQuestion "Use TypeScript with Vite?"
			if ($useTS.ToUpper() -eq 'Y') { $ts = $True } else { $ts = $False }
			Initialize-ProjectNode-Vite -Name $ProjectName -ProjectManager $pkgManager -ts:$ts
			Write-LinkInformation "https://vite.dev/guide/"
		}
		Default { break }
	}

	Add-ProjectGitignore -ProjectPath "$ProjectRoot/$ProjectName" -ProjectFramework "$langgitignore"
	Remove-Variable langgitignore

	Add-License -ProjectRoot $ProjectRoot -ProjectName $ProjectName
	Add-Readme -ProjectRoot $ProjectRoot -ProjectName $ProjectName

}
