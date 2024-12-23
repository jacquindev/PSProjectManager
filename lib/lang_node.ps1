foreach ($file in $(Get-ChildItem -Path "$PSScriptRoot/frameworks/node/*" -Include *.ps1 -Recurse)) {
	. "$file"
}
Remove-Variable file

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
			$useTS = $(Write-Host "Use TypeScript with ASTRO? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
			$useTW = $(Write-Host "Use TailwindCSS with ASTRO? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
			$addIntegrations = $(Write-Host "Add Astro Integrations? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)

			if ($useTS.ToUpper() -eq 'Y') { $ts = $True } else { $ts = $False }
			if ($useTW.ToUpper() -eq 'Y') { $tw = $True } else { $tw = $False }
			if ($addIntegrations.ToUpper -eq 'Y') { $integration = $True } else { $integration = $False }

			Initialize-ProjectNode-Astro -Name $ProjectName -ProjectManager $pkgManager -ts:$ts -tw:$tw -integration:$integration
			Write-LinkInformation "https://docs.astro.build/en/guides/integrations-guide/"
		}
		"Angular" {
			$langgitignore += ",angular"
			$useTW = $(Write-Host "Use TailwindCSS with Angular? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
			if ($useTW.ToUpper() -eq 'Y') { $tw = $True } else { $tw = $False }

			Initialize-ProjectNode-Angular -Name $ProjectName -ProjectManager $pkgManager -tw:$tw
			Write-LinkInformation "https://angular.dev/overview"
		}
		"NextJS" {
			$langgitignore += ",nextjs"
			$useTS = $(Write-Host "Use TypeScript with NextJS? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
			$useTW = $(Write-Host "Use TailwindCSS with NextJS? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)

			if ($useTS.ToUpper() -eq 'Y') { $ts = $True } else { $ts = $False }
			if ($useTW.ToUpper() -eq 'Y') { $tw = $True } else { $tw = $False }
			Initialize-ProjectNode-NextJS -Name $ProjectName -ProjectManager $pkgManager -tw:$tw -ts:$ts
			Write-LinkInformation "https://nextjs.org/docs"
		}
		"Remix" {
			$langgitignore += ",remix"
			$useTS = $(Write-Host "Use TypeScript with Remix? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
			$useTW = $(Write-Host "Use TailwindCSS with Remix? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)

			if ($useTS.ToUpper() -eq 'Y') { $ts = $True } else { $ts = $False }
			if ($useTW.ToUpper() -eq 'Y') { $tw = $True } else { $tw = $False }
			Initialize-ProjectNode-Remix -Name $ProjectName -ProjectManager $pkgManager -tw:$tw -ts:$ts
			Write-LinkInformation "https://remix.run/docs/en/main"
		}
		"Parcel" {
			$useTS = $(Write-Host "Use TypeScript with Parcel? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
			$useTW = $(Write-Host "Use TailwindCSS with Parcel? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)

			if ($useTS.ToUpper() -eq 'Y') { $ts = $True } else { $ts = $False }
			if ($useTW.ToUpper() -eq 'Y') { $tw = $True } else { $tw = $False }
			Initialize-ProjectNode-Parcel -Name $ProjectName -ProjectManager $pkgManager -tw:$tw -ts:$ts
			Write-LinkInformation "https://parceljs.org/docs/"
		}
		"SvelteKit" {
			$langgitignore += ",svelte"
			$useTS = $(Write-Host "Use TypeScript with SvelteKit? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
			$useTW = $(Write-Host "Use TailwindCSS with SvelteKit? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
			$addIntegrations = $(Write-Host "Add SvelteKit Integrations? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)

			if ($useTS.ToUpper() -eq 'Y') { $ts = $True } else { $ts = $False }
			if ($useTW.ToUpper() -eq 'Y') { $tw = $True } else { $tw = $False }
			if ($addIntegrations.ToUpper -eq 'Y') { $integration = $True } else { $integration = $False }
			Initialize-ProjectNode-SvelteKit -Name $ProjectName -ProjectManager $pkgManager -ts:$ts -tw:$tw -integration:$integration
			Write-LinkInformation "https://svelte.dev/docs/kit/introduction"
		}
		"Vite" {
			$useTS = $(Write-Host "Use TypeScript with Vite? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
			if ($useTS.ToUpper() -eq 'Y') { $ts = $True } else { $ts = $False }
			Initialize-ProjectNode-Vite -Name $ProjectName -ProjectManager $pkgManager -ts:$ts
			Write-LinkInformation "https://vite.dev/guide/"
		}
		Default { break }
	}

	Add-ProjectGitignore -ProjectPath "$ProjectRoot/$ProjectName" -ProjectFramework "$langgitignore"
	Remove-Variable langgitignore
}
