function Initialize-ProjectNode-Remix {
	param ([string]$Name, [string]$ProjectManager, [switch]$tw, [switch]$ts)

	switch ($ProjectManager) {
		"bun" { $cmd = "bunx create remix $Name" }
		"npm" { $cmd = "npx create-remix@latest $Name" }
		"pnpm" { $cmd = "pnpm create remix $Name" }
		"yarn" { $cmd = "yarn create remix $Name" }
	}

	if (!$ts) { $cmd += " --template remix-run/remix/templates/remix-javascript" }
	Invoke-Expression $cmd
	Remove-Variable cmd

	Set-Location "./$Name"

	if ($tw) {
		switch ($ProjectManager) {
			"bun" {
				bun add -d tailwindcss postcss autoprefixer
				if ($ts) { bunx tailwindcss init --ts -p } else { bunx tailwindcss init -p }
			}
			"npm" {
				npm install --save-dev tailwindcss postcss autoprefixer
				if ($ts) { npx tailwindcss init --ts -p } else { npx tailwindcss init -p }
			}
			"pnpm" {
				pnpm add -D tailwindcss postcss autoprefixer
				if ($ts) { npx tailwindcss init --ts -p } else { npx tailwindcss init -p }
			}
			"yarn" {
				yarn add -D tailwindcss postcss autoprefixer
				if ($ts) { yarn tailwindcss init --ts -p } else { yarn tailwindcss init -p }
			}
		}
	}
}
