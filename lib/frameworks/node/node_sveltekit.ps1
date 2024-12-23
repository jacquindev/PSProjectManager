function Initialize-ProjectNode-SvelteKit {
	param ([string]$Name, [string]$ProjectManager, [switch]$tw, [switch]$ts, [switch]$integration)

	$cmd = "npx sv create $Name"

	$svelteTemplate = (gum choose --limit=1 --header="Choose a Template to Scaffold:" "minimal" "demo" "library").Trim()
	switch ($svelteTemplate) {
		"minimal" { $cmd += " --template minimal" }
		"demo" { $cmd += " --template demo" }
		"library" { $cmd += " --template library" }
	}

	if ($ts) { $cmd += " --types ts" }
	$cmd += " --no-add-ons --no-install"

	Invoke-Expression $cmd
	Remove-Variable cmd

	Set-Location "./$Name"
	if ($tw) {
		$cmd1 = "npx sv add --tailwindcss"
		$tailwindPlugins = (gum choose --no-limit --header="Choose TailwindCSS Plugins:" "typography" "forms" "container-queries").Trim()
		switch ($tailwindPlugins) {
			"typography" { $cmd1 += " typography" }
			"forms" { $cmd1 += " forms" }
			"container-queries" { $cmd1 += " container-queries" }
		}
		$cmd1 += " --no-install"
		Invoke-Expression $cmd1
		Write-Success -Entry1 "OK" -Entry2 "$projectName" -Text "added TailwindCSS."
	}

	switch ($ProjectManager) {
		"bun" { gum spin --title="Setting up Svelte Project $Name..." -- bun install }
		"npm" { gum spin --title="Setting up Svelte Project $Name..." -- npm install -y }
		"pnpm" { gum spin --title="Setting up Svelte Project $Name..." -- pnpm install }
		"yarn" { gum spin --title="Setting up Svelte Project $Name..." -- yarn install }
	}

	if ($integration) {
		$index = (gum choose --no-limit --header="Choose Additional Integrations Topics:" "1. Builtin SvelteKit Adders" "2. Svelte Packages" "3. svelte-preprocess").Trim()
		switch ($index) {
			{ $_ -match "1. Builtin SvelteKit Adders" } {
				''
				Write-Host "Builtin SvelteKit Adders" -ForegroundColor Green
				Write-Host "------------------------" -ForegroundColor Green
				$addersCmd = "npx sv add"
				$adders = (gum choose --no-limit --header="Choose SvelteKit Integrations:" "prettier" "eslint" "vitest" "playwright" "mdsvex" "storybook" "lucia" "drizzle" "paraglide").Trim()
				switch ($adders) {
					{ $_ -match "prettier" } { $addersCmd += " prettier" }
					{ $_ -match "eslint" } { $addersCmd += " eslint" }
					{ $_ -match "vitest" } { $addersCmd += " vitest" }
					{ $_ -match "playwright" } { $addersCmd += " playwright" }
					{ $_ -match "mdsvex" } { $addersCmd += " mdsvex" }
					{ $_ -match "storybook" } { $addersCmd += " storybook" }
					{ $_ -match "lucia" } {
						$demoIncluded = (gum choose --limit=1 --header="Lucia: Include a demo?" "Yes" "No").Trim()
						if ($demoIncluded -eq 'Yes') { $addersCmd += " --lucia demo" }
						else { $addersCmd += " --lucia no-demo" }
					}
					{ $_ -match "drizzle" } {
						$dbCmd = "--drizzle"
						$databaseType = (gum choose --limit=1 --header="Choose a Database Type:" "PostgreSQL" "MySQL" "SQLite").Trim()
						switch ($databaseType) {
							"PostgreSQL" {
								$dbCmd += " postgresql"
								$databaseClient = (gum choose --limit=1 --header="Choose a PostgreSQL Client:" "Postgres.JS" "Neon").Trim()
								switch ($databaseClient) {
									"Postgres.JS" { $dbCmd += " postgres.js" }
									"Neon" { $dbCmd += " neon" }
								}
								$addersCmd += " $dbCmd"
							}
							"MySQL" {
								$dbCmd += " mysql"
								$databaseClient = (gum choose --limit=1 --header="Choose a MySQL Client:" "mysql2" "PlanetScale").Trim()
								switch ($databaseClient) {
									"mysql2" { $dbCmd += " mysql2" }
									"PlanetScale" { $dbCmd += " planetscale" }
								}
								$addersCmd += " $dbCmd"
							}
							"SQLite" {
								$dbCmd += " sqlite"
								$databaseClient = (gum choose --limit=1 --header="Choose a SQLite Client:" "better-sqlite3" "libSQL" "Turso").Trim()
								switch ($databaseClient) {
									"better-sqlite3" { $dbCmd += " better-sqlite3" }
									"libSQL" { $dbCmd += " libsql" }
									"Turso" { $dbCmd += " turso" }
								}
								$addersCmd += " $dbCmd"
							}
						}
						$dockerExists = Get-Command docker -ErrorAction SilentlyContinue
						if ($dockerExists) {
							$useDocker = (gum choose --limit=1 --header="Integrate Database with Docker?" "Yes" "No").Trim()
							if ($useDocker -eq 'Yes') { $addersCmd += " docker" } else { $addersCmd += " no-docker" }
						}
					}
					{ $_ -match "paraglide" } {
						$demoIncluded = (gum choose --limit=1 --header="Paraglide: Include a demo?" "Yes" "No").Trim()
						if ($demoIncluded -eq 'Yes') { $addersCmd += " --paraglide demo" }
						else { $addersCmd += " --paraglide no-demo" }
					}
				}
				$addersCmd += " --no-install"
				Invoke-Expression $addersCmd
			}

			{ $_ -match "2. Svelte Packages" } {
				''
				Write-Host "Svelte Packages" -ForegroundColor Green
				Write-Host "---------------" -ForegroundColor Green
				$sveltePackages = @()
				$pkgs = (gum choose --no-limit --header="Some available Svelte Packages:" "auto-animate" "embla-carousel-svelte" "enhanced-img" "lucide-icons" "svelte-datatable" "svelte-flicking"  "Svelte Flow" "Tanstack Table" "Tanstack Query" "Tanstack Virtual").Trim()
				switch ($pkgs) {
					{ $_ -match "AutoAnimate" } { $sveltePackages += '@formkit/auto-animate' } # https://auto-animate.formkit.com/#usage-svelte
					{ $_ -match "embla-carousel-svelte" } { $sveltePackages += 'embla-carousel-svelte' } # https://www.embla-carousel.com/get-started/
					{ $_ -match "enhanced-img" } { $sveltePackages += '@sveltejs/enhanced-img' } # https://svelte.dev/docs/kit/images#sveltejs-enhanced-img
					{ $_ -match "lucide-icons" } { $sveltePackages += 'lucide-svelte' } # https://lucide.dev/guide/packages/lucide-svelte
					{ $_ -match "svelte-datatable" } { $sveltePackages += '@radar-azdelta/svelte-datatable' } # https://github.com/RADar-AZDelta/azd-radar-data-datatable
					{ $_ -match "svelte-flicking" } { $sveltePackages += '@egjs/svelte-flicking' } # https://github.com/naver/egjs-flicking/blob/master/packages/svelte-flicking/README.md
					{ $_ -match "Svelte Flow" } { $sveltePackages += '@xyflow/svelte' } # https://svelteflow.dev/learn
					{ $_ -match "Tanstack Table" } { $sveltePackages += '@tanstack/svelte-table' } # https://tanstack.com/table/v8/docs/framework/svelte/svelte-table
					{ $_ -match "Tanstack Virtual" } { $sveltePackages += '@tanstack/svelte-virtual' } # https://tanstack.com/virtual/latest/docs/framework/svelte/svelte-virtual
					{ $_ -match "Tanstack Query" } { $sveltePackages += '@tanstack/svelte-query' } # https://tanstack.com/query/latest/docs/framework/svelte/overview
				}

				foreach ($pkg in $sveltePackages) {
					switch ($pkgManager) {
						"bun" { gum spin --title="Adding Svelte Package $pkg..." -- bun add $pkg }
						"npm" { gum spin --title="Adding Svelte Package $pkg..." -- npm install $pkg }
						"pnpm" { gum spin --title="Adding Svelte Package $pkg..." -- pnpm add $pkg }
						"yarn" { gum spin --title="Adding Svelte Package $pkg..." -- yarn add $pkg }
					}
					Write-Success -Entry1 "OK" -Entry2 "$pkg" -Text "installed."
				}

				Remove-Variable sveltePackages
			}

			{ $_ -match "3. svelte-preprocess" } {
				''
				Write-Host "svelte-preprocess" -ForegroundColor Green
				Write-Host "-----------------" -ForegroundColor Green
				$sveltePackages = @()
				$deps = (gum choose --no-limit --header="svelte-preprocess - Choose language-specific dependencies:" "Babel" "CoffeeScript" "PostCSS" "SugarSS" "Less" "Sass" "Pug" "Stylus")
				switch ($deps) {
					{ $_ -match "Babel" } { $sveltePackages += @('@babel/core', '@babel/preset-...') }
					{ $_ -match "CoffeeScript" } { $sveltePackages += @('coffeescript') }
					{ $_ -match "PostCSS" } { $sveltePackages += @('postcss', 'postcss-load-config') }
					{ $_ -match "SugarSS" } { $sveltePackages += @('postcss', 'sugarss') }
					{ $_ -match "Less" } { $sveltePackages += @('less') }
					{ $_ -match "Sass" } { $sveltePackages += @('sass') }
					{ $_ -match "Pug" } { $sveltePackages += @('pug') }
					{ $_ -match "Stylus" } { $sveltePackages += @('stylus') }
				}
				$sveltePackages += @('autoprefixer')
				if ($typescript) { $sveltePackages += @('typescript', '@rollup/plugin-typescript') }

				foreach ($pkg in $sveltePackages) {
					switch ($pkgManager) {
						"bun" { gum spin --title="Adding Dependencies $pkg..." -- bun add -d $pkg }
						"npm" { gum spin --title="Adding Dependencies $pkg..." -- npm i -D $pkg }
						"pnpm" { gum spin --title="Adding Dependencies $pkg..." --  pnpm add -D $pkg }
						"yarn" { gum spin --title="Adding Dependencies $pkg..." -- yarn add -D $pkg }
					}
					Write-Success -Entry1 "OK" -Entry2 "$pkg" -Text "added."
				}
				Remove-Variable sveltePackages
				''
				Write-Host "Extra steps are required to setup, please see " -ForegroundColor Red -NoNewline
				Write-Host "https://github.com/sveltejs/svelte-preprocess/blob/main/docs/getting-started.md" -ForegroundColor Blue
			}

			Default { break }
		}
	}
}
