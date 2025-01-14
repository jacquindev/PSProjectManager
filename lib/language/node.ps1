function Initialize-ProjectNode {
	param ([string]$ProjectName, [string]$PackageManager, [switch]$Framework)

	if (!(Get-Command $PackageManager -ErrorAction SilentlyContinue)) {
		Write-Warning "Command not found: $PackageManager. Please install to continue!"
		return
	}

	if ($Framework) {
		$dataFiles = "$PSScriptRoot/../../data/node"
		$nodejsFrameworks = Get-Content "$dataFiles/nodejs_frameworks.txt"
		$chooseFramework = gum choose --header="Choose a NodeJS framework:" $nodejsFrameworks

		switch ($chooseFramework) {
			# AdonisJS
			"$($nodejsFrameworks[0])" {
				Write-Link "AdonisJS Documentation" "https://docs.adonisjs.com"
				$cmd = "npx create-adonisjs@latest --pkg=$PackageManager -- $ProjectName"
			}
			# Astro
			"$($nodejsFrameworks[1])" {
				Write-Link "Astro Documentation:" "https://docs.astro.build/"
				$cmd = "npx create-astro@latest $ProjectName --no-install"
				$useTemplate = Write-YesNo "Use official (Y) or community (n) Astro template for your project?" -y
				if ($useTemplate.ToUpper() -eq 'N') {
					do {
						$tmpl = Write-PromptInput "Input a GitHub Astro template repository" "username/repo_name"
						if ((CheckGitHubRepoExists -Repo "$tmpl") -eq $False) {
							Write-Warning "GitHub repository: $tmpl not found. Please try again!"
						}
					} until ((CheckGitHubRepoExists -Repo "$tmpl") -eq $True)
				} else {
					$astroTemplates = Get-Content "$dataFiles/astro_templates.txt"
					$tmpl = gum choose --header="Choose an Astro template:" $astroTemplates
				}
				$cmd += "--template $tmpl"
			}
			# Angular
			"$($nodejsFrameworks[2])" {
				Write-Link "Angular Documentation:" "https://angular.dev/overview"
				if (!(Get-Command ng -ErrorAction SilentlyContinue)) {	Add-NodeGlobalPackage -PackageManager "$PackageManager" -Package "@angular/cli" }
				$cmd = "ng new $ProjectName --package-manager $PackageManager --skip-install"

				$angularOptions = Get-Content "$dataFiles/angular_config_options.txt"
				$angularSettings = gum choose --no-limit --header="Configure Angular project with the following settings:" $angularOptions

				switch ($angularSettings) {
					{ $_ -match "$($angularOptions[0])" } { $cmd += " --skip-tests false" }
					{ $_ -match "$($angularOptions[1])" } { $cmd += " --experimental-zoneless true" }
					{ $_ -match "$($angularOptions[2])" } { $cmd += " --server-routing true" }
					{ $_ -match "$($angularOptions[3])" } { $cmd += " --ssr true" }
					{ $_ -match "$($angularOptions[4])" } { $cmd += " --create-application false" }
					{ $_ -match "$($angularOptions[5])" } { $cmd += " --strict false" }
					{ $_ -match "$($angularOptions[6])" } { $cmd += " --standalone false" }
					{ $_ -match "$($angularOptions[7])" } { $cmd += " --skip-tests true" }
					{ $_ -match "$($angularOptions[8])" } { $cmd += " --routing true" }
					{ $_ -match "$($angularOptions[9])" } { $cmd += " --inline-template true" }
					{ $_ -match "$($angularOptions[10])" } { $s = gum choose --header="Which file extension or preprocessor to use for style files?" "css" "scss" "sass" "less"; $cmd += " --style $s" }
					{ $_ -match "$($angularOptions[11])" } { $v = gum choose --header="Which view encapsulation strategy to use in the project?" "Emulated" "None" "ShadowDom"; $cmd += " --view-encapsulation $v" }
				}
			}
			# Fastify
			"$($nodejsFrameworks[3])" {
				Write-Link "Fastify Documentation:" "https://fastify.dev/docs/latest"
				if (!(Get-Command fastify -ErrorAction SilentlyContinue)) { Add-NodeGlobalPackage -PackageManager "$PackageManager" -Package "fastify-cli" }
				$cmd = "fastify generate $ProjectName"

				$fastifyOptions = Get-Content "$dataFiles/fastify_config_options.txt"
				$fastifySettings = gum choose --no-limit --header="Configure your Fastify project with the following settings:" $fastifyOptions

				switch ($fastifySettings) {
					{ $_ -match "$($fastifyOptions[0])" } { $cmd += " --esm" }
					{ $_ -match "$($fastifyOptions[1])" } { $cmd += " --lang=typescript" }
					{ $_ -match "$($fastifyOptions[2])" } { $cmd += " --standardlint" }
				}
			}
			# Hono
			"$($nodejsFrameworks[4])" {
				Write-Link "Hono Documentation:" "https://hono.dev/docs"
				$cmd = "npx create-hono@latest $ProjectName --pm $PackageManager"
			}
			# LoopBack
			"$($nodejsFrameworks[5])" {
				Write-Link "LoopBack Information:" "https://loopback.io/doc"
				if (!(Get-Command lb4 -ErrorAction SilentlyContinue)) { Add-NodeGlobalPackage -PackageManager "$PackageManager" -Package "@loopback/cli" }
				$cmd = "lb4 app $ProjectName --skip-install --yes"

				$loopbackOptions = Get-Content "$dataFiles/loopback_config_options.txt"
				$loopbackSettings = gum choose --no-limit --header="Configure your LoopBack project with the following settings:" $loopbackOptions

				switch ($loopbackSettings) {
					{ $_ -match "$($loopbackOptions[0])" } { $cmd += " --docker" }
					{ $_ -match "$($loopbackOptions[1])" } { $cmd += " --repositories" }
					{ $_ -match "$($loopbackOptions[2])" } { $cmd += " --services" }
					{ $_ -match "$($loopbackOptions[3])" } { $cmd += " --apiconnect" }
					{ $_ -match "$($loopbackOptions[4])" } { $cmd += " --eslint" }
					{ $_ -match "$($loopbackOptions[5])" } { $cmd += " --prettier" }
					{ $_ -match "$($loopbackOptions[6])" } { $cmd += " --mocha" }
					{ $_ -match "$($loopbackOptions[7])" } { $cmd += " --loopbackBuild" }
					{ $_ -match "$($loopbackOptions[8])" } { $cmd += " --editorconfig" }
					{ $_ -match "$($loopbackOptions[9])" } { $cmd += " --vscode" }
					{ $_ -match "$($loopbackOptions[10])" } { $cmd += " --private" }
					{ $_ -match "$($loopbackOptions[11])" } { $cmd += " --format" }
				}
			}
			# Meteor
			"$($nodejsFrameworks[6])" {
				Write-Link "Meteor Documentation:" "https://docs.meteor.com/"
				$meteorOptions = Get-Content "$dataFiles/meteor_config_options.txt"
				$meteorSettings = gum choose --header="Choose a type of Meteor app for your project:" $meteorOptions

				switch ($meteorSettings) {
					"$($meteorOptions[0])" { $cmd = "meteor create --minimal $ProjectName" }
					"$($meteorOptions[1])" { $cmd = "meteor create --blaze $ProjectName" }
					"$($meteorOptions[2])" { $cmd = "meteor create --bare $ProjectName" }
					"$($meteorOptions[3])" { $cmd = "meteor create --full $ProjectName" }
					"$($meteorOptions[4])" { $cmd = "meteor create --react $ProjectName" }
					"$($meteorOptions[5])" { $cmd = "meteor create --apollo $ProjectName" }
					"$($meteorOptions[6])" { $cmd = "meteor create --chakra-ui $ProjectName" }
					"$($meteorOptions[7])" { $cmd = "meteor create --tailwind $ProjectName" }
					"$($meteorOptions[8])" { $cmd = "meteor create --typescript $ProjectName" }
					"$($meteorOptions[9])" { $cmd = "meteor create --solid $ProjectName" }
					"$($meteorOptions[10])" { $cmd = "meteor create --svelte $ProjectName" }
					"$($meteorOptions[11])" { $cmd = "meteor create --vue $ProjectName" }
					"$($meteorOptions[12])" { $cmd = "meteor create --prototype $ProjectName" }
					Default { $cmd = "meteor create --react $ProjectName" }
				}
			}
			# NestJS
			"$($nodejsFrameworks[7])" {
				Write-Link "NestJS Documentation:" "https://docs.nestjs.com/"
				$cmd = "nest new $ProjectName --package-manager $PackageManager --skip-install"

				$nestJsOptions = gum choose --header="Choose a NestJS Programming Language:" "JavaScript" "TypeScript"

				switch ($nestJsOptions) {
					"JavaScript" { $cmd += " --language JavaScript" }
					"TypeScript" { $cmd += " --language TypeScript" }
					Default { $cmd += " --language TypeScript" }
				}

				if ($nestJsOptions -eq "TypeScript") {
					$nestStrict = Write-YesNoQuestion "Enable strict mode in TypeScript?"
					if ($nestStrict.ToUpper() -eq 'Y') { $cmd += " --strict true" } else { $cmd += " --strict false" }
				}
			}
			# Next.js
			"$($nodejsFrameworks[8])" {
				Write-Link "NextJS Documentation:" "https://nextjs.org/docs"
				$cmd = "npx create-next-app@latest $ProjectName --use-$PackageManager --skip-install"
			}
			# Sails.js
			"$($nodejsFrameworks[9])" {
				Write-Link "SailsJS Documentation:" "https://sailsjs.com/get-started"
				if (!(Get-Command sails -ErrorAction SilentlyContinue)) { Add-NodeGlobalPackage -PackageManager "$PackageManager" -Package "sails" }
				$cmd = "sails new $ProjectName --fast"
			}
			# SvelteKit
			"$($nodejsFrameworks[10])" {
				Write-Link "SvelteKit Documentation:" "https://svelte.dev/docs"
				$cmd = "npx sv create $ProjectName --no-install"
			}
			# React Router
			"$($nodejsFrameworks[11])" {
				Write-Link "React Router Documentation:" "https://reactrouter.com/home"
				$cmd = "npx create-react-router@latest $ProjectName"
				$reactRouterTemplates = Get-Content "$dataFiles/react_router_v7_templates.txt"
				$tmpl = gum choose --header="Choose a React Router template to bootstrap your project with:" $reactRouterTemplates
				$cmd += " --template $tmpl"
			}
			# Remix
			"$($nodejsFrameworks[12])" {
				Write-Link "Remix Documentation:" "https://remix.run/docs/en"
				$cmd = "npx create-remix@latest $ProjectName --package-manager $PackageManager --no-install --yes"

				$useTemplate = Write-YesNo "Use official (Y) or community (n) Remix template for your project?" -y
				if ($useTemplate.ToUpper() -eq 'N') { $remixTemplates = Get-Content "$dataFiles/remix_templates_community.txt" }
				else { $remixTemplates = Get-Content "$dataFiles/remix_templates_official.txt" }
				$tmpl = gum choose --header="Choose a Remix Official template:" $remixTemplates

				$cmd += " --template $tmpl"
			}
			# Turborepo
			"$($nodejsFrameworks[13])" {
				Write-Link "Turborepo Documentation:" "https://turbo.build/repo/docs"
				$cmd = "npx create-turbo@latest $ProjectName --package-manager $PackageManager --skip-install"
			}
			#Vite
			"$($nodejsFrameworks[14])" {
				Write-Link "Vite Documentation:" "https://vite.dev/guide"

				$useTemplate = Write-YesNo "Use official (Y) or community (n) Vite template for your project?" -y
				if ($useTemplate.ToUpper() -eq 'N') {
					Write-Link "Available community templates:" "https://github.com/vitejs/awesome-vite#templates"
					do {
						$tmpl = Write-PromptInput "Input a GitHub Vite template repository" "username/repo_name"
						if ((CheckGitHubRepoExists -Repo "$tmpl") -eq $False) {
							Write-Warning "GitHub repository: $tmpl not found. Please try again!"
						}
					} until ((CheckGitHubRepoExists -Repo "$tmpl") -eq $True)

					$cmd = "npx degit $tmpl $ProjectName"

				} else {
					$useLang = Write-YesNo "Use TypeScript (Y) or JavaScript (n) programming language?"
					if ($useLang.ToUpper() -eq 'N') {	$viteTemplates = Get-Content "$dataFiles/vite_javascript_templates.txt"	}
					else { $viteTemplates = Get-Content "$dataFiles/vite_typescript_templates.txt" }
					$tmpl = gum choose --header="Choose a Vite template to bootstrap your project:" $viteTemplates

					$cmd = "npx create-vite@latest $ProjectName --template $tmpl"
				}
			}
			Default { $cmd = $null }
		}

		if ($null -ne $cmd) {
			$confirm = Write-YesNo "Create project $ProjectName with $chooseFramework framework?" -y
			if ($confirm.ToUpper() -eq 'N') { Write-Host "Skipped process..." -ForegroundColor DarkGray }
			else { ''; Invoke-Expression $cmd; '' }

			Set-Location "./$ProjectName"

			switch ($PackageManager) {
				"bun" { gum spin --title="Initializing project using bun..." -- bun install; gum spin -- bun add -d @types/bun }
				"npm" { gum spin --title="Initializing project using npm..." -- npm install -y }
				"pnpm" { gum spin --title="Initializing project using pnpm..." -- pnpm install }
				"yarn" { gum spin --title="Initializing project using yarn..." -- yarn }
			}
		} else { break }
	}

	if (!$Framework) {
		New-DirectoryIfNotExist "./$ProjectName"
		Set-Location "./$ProjectName"

		switch ($pkgManager) {
			"bun" { gum spin --title="Initializing project..." -- bun init }
			"npm" { gum spin --title="Initializing project..." -- npm init -y }
			"pnpm" { gum spin --title="Initializing project..." -- pnpm init }
			"yarn" { gum spin --title="Initializing project..." -- yarn init -2 }
		}
	}
}
