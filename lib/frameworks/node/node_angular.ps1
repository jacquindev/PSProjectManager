function Initialize-ProjectNode-Angular {
	param ([string]$Namel, [string]$ProjectManager, [switch]$tw)

	if (!(Get-Command ng -ErrorAction SilentlyContinue)) {
		Write-Warning "Command not found: ng. Please install to use this feature."
		return
	}

	$cmd = "ng new $Name"
	switch ($ProjectManager) {
		"bun" { $cmd += " --package-manager bun" }
		"npm" { $cmd += " --package-manager npm" }
		"pnpm" { $cmd += " --package-manager pnpm" }
		"yarn" { $cmd += " --package-manager yarn" }
	}

	$serverRouting = (gum choose --header="Create Server Application using Server Routing & App Engine APIs? " "True" "False").Trim()
	$ssr = (gum choose --header="Create Application with Server-Side Rendering (SSR) and Static Site Generation (SSG/Prerendering)? " "True" "False" ).Trim()
	$style = (gum choose --header="Files Styling (Extension or Preprocessor):" "CSS" "SCSS" "SASS" "LESS").Trim()
	$view = (gum choose --header="View Encapsulation Strategy to use:" "None" "Emulated" "ShadowDom").Trim()

	switch ($serverRouting) {
		"True" { $cmd += " --server-routing true" }
		"False" { $cmd += " --server-routing false" }
	}
	switch ($ssr) {
		"True" { $cmd += " --ssr true" }
		"False" { $cmd += " --ssr false" }
	}
	switch ($style) {
		"CSS" { $cmd += " --style css" }
		"SCSS" { $cmd += " --style scss" }
		"SASS" { $cmd += " --style sass" }
		"LESS" { $cmd += " --style less" }
	}
	switch ($view) {
		"None" { $cmd += " --view-encapsulation None" }
		"Emulated" { $cmd += " --view-encapsulation Emulated" }
		"ShadowDom" { $cmd += " --view-encapsulation ShadowDom" }
	}

	Invoke-Expression $cmd
	Remove-Variable cmd

	Set-Location "./$Name"

	if ($tw) {
		$tailwindname = (gum style --foreground="#74c7ec" --italic --bold "TailwindCSS")
		switch ($pkgManager) {
			"bun" {
				gum spin --title="Integrating Angular with $tailwindname ..." -- bun add -d tailwindcss postcss autoprefixer
				bunx tailwindcss init
			}
			"npm" {
				gum spin --title="Integrating Angular with $tailwindname ..." -- npm install --save-dev tailwindcss postcss autoprefixer
				npx tailwindcss init
			}
			"pnpm" {
				gum spin --title="Integrating Angular with $tailwindname ..." -- pnpm add -D tailwindcss postcss autoprefixer
				npx tailwindcss init
			}
			"yarn" {
				gum spin --title="Integrating Angular with $tailwindname ..." -- yarn add -D tailwindcss postcss autoprefixer
				yarn tailwindcss init
			}
			Default { return }
		}
		Remove-Variable tailwindname
	}
}
