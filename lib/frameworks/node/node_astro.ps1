function Initialize-ProjectNode-Astro {
	param ([string]$Name, [string]$ProjectManager, [switch]$ts, [switch]$tw, [switch]$integration)

	switch ($ProjectManager) {
		"bun" { bunx create astro $Name --git --fancy --install }
		"npm" { npx create-astro@latest $Name --git --fancy --install }
		"pnpm" { pnpm create astro@latest $Name --git --fancy --install }
		"yarn" { yarn create astro $Name --git --fancy --install }
	}

	Set-Location "./$Name"

	if ($ts) {
		$tsname = (gum style --foreground="#74c7ec" --italic --bold "TypeScript")
		switch ($ProjectManager) {
			"bun" {
				gum spin --title="Integrating Astro with $tsname ..." -- bun add -d @types/bun
				gum spin --title="Integrating Astro with $tsname ..." -- bun add @astrojs/ts-plugin
			}
			"npm" { gum spin --title="Integrating Astro with $tsname ..." -- npm install @astrojs/ts-plugin }
			"pnpm" { gum spin --title="Integrating Astro with $tsname ..." -- pnpm add @astrojs/ts-plugin }
			"yarn" { gum spin --title="Integrating Astro with $tsname ..." -- yarn add @astrojs/ts-plugin }
		}

		$tsconfig = "./tsconfig.json"
		$json = Get-Content $tsconfig | ConvertFrom-Json
		if (!$json.compilerOptions) {
			$json | Add-Member -Name "compilerOptions" -Value @{ plugins = @("@astrojs/ts-plugin") } -MemberType NoteProperty
			Set-Content $tsconfig -Value ($json | ConvertTo-Json -Depth 100)
		}
		Remove-Variable tsname, tsconfig, json
	}

	if ($tw) {
		$tailwindname = (gum style --foreground="#74c7ec" --italic --bold "TailwindCSS")
		switch ($ProjectManager) {
			"bun" { gum spin --title="Integrating Astro with $tailwindname ..." -- bunx astro add tailwind --yes }
			"npm" { gum spin --title="Integrating Astro with $tailwindname ..." -- npx astro add tailwind --yes }
			"pnpm" { gum spin --title="Integrating Astro with $tailwindname ..." -- pnpm astro add tailwind --yes }
			"yarn" { gum spin --title="Integrating Astro with $tailwindname ..." -- yarn astro add tailwind --yes }
		}
		Remove-Variable tailwindname
	}

	if ($integration) {
		$astroPkgs = @()
		$uiFrameworks = (gum choose --limit=1 --header="Astro UI Framework:" "Alpine.js" "Preact" "React" "SolidJS" "Svelte" "Vue").Trim()
		$adapters = (gum choose --limit=1 --header="Astro SSR Adapter" "Cloudflare" "Netlify" "Node" "Vercel").Trim()
		$extras = (gum choose --no-limit --header="Extra Official Integrations:" "DB" "Markdoc" "MDX" "PartyTown" "SiteMap").Trim()
		$unofficials = (gum choose --no-limit --header="Some Unofficial Integrations:" "astro-auto-import" "astro-icon" "astro-seo" "auth-astro" "@playform/compress" "@sentry/astro").Trim()

		switch ($uiFrameworks) {
			"Alpine.js" { $astroPkgs += @('alpinejs') }
			"Preact" { $astroPkgs += @('preact') }
			"React" { $astroPkgs += @('react') }
			"SolidJS" { $astroPkgs += @('solid') }
			"Svelte" { $astroPkgs += @('svelte') }
			"Vue" { $astroPkgs += @('vue') }
			Default { $astroPkgs += @() }
		}
		switch ($adapters) {
			"Cloudflare" { $astroPkgs += @('cloudflare') }
			"Netlify" { $astroPkgs += @('netlify') }
			"Node" { $astroPkgs += @('node') }
			"Vercel" { $astroPkgs += @('vercel') }
			Default { $astroPkgs += @() }
		}
		switch ($extras) {
			{ $_ -match "DB" } { $astroPkgs += @('db') }
			{ $_ -match "Markdoc" } { $astroPkgs += @('markdoc') }
			{ $_ -match "MDX" } { $astroPkgs += @('mdx') }
			{ $_ -match "PartyTown" } { $astroPkgs += @('partytown') }
			{ $_ -match "SiteMap" } { $astroPkgs += @('sitemap') }
			Default { $astroPkgs += @() }
		}
		switch ($unofficials) {
			{ $_ -match "astro-auto-import" } { $astroPkgs += @('astro-auto-import') }
			{ $_ -match "astro-icon" } { $astroPkgs += @('astro-icon') }
			{ $_ -match "astro-seo" } { $astroPkgs += @('astro-seo') }
			{ $_ -match "auth-astro" } { $astroPkgs += @('auth-astro') }
			{ $_ -match "@sentry/astro" } { $astroPkgs += @('@sentry/astro') }
			{ $_ -match "@playform/compress" } { $astroPkgs += @('@playform/compress') }
			Default { $astroPkgs += @() }
		}

		foreach ($pkg in $astroPkgs) {
			$pkgName = (gum style --foreground="#74c7ec" --italic --bold "$pkg")
			switch ($ProjectManager) {
				"bun" { gum spin --title="Adding Astro Integration: $pkgName ..." -- bunx astro add $pkg --yes }
				"npm" { gum spin --title="Adding Astro Integration: $pkgName ..." -- npx astro add $pkg --yes }
				"pnpm" { gum spin --title="Adding Astro Integration: $pkgName ..." -- pnpm astro add $pkg --yes }
				"yarn" { gum spin --title="Adding Astro Integration: $pkgName ..." -- yarn astro add $pkg --yes }
			}
			Remove-Variable pkgName
		}
	}

}
