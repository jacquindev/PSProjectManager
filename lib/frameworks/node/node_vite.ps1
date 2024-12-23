function Initialize-ProjectNode-Vite {
	param ([string]$Name, [string]$ProjectManager, [switch]$ts)

	if ($ts) {
		$viteTemplates = gum choose "Choose a Vite Template:" "vanilla-ts" "vue-ts" "react-ts" "preact-ts" "lit-ts" "svelte-ts" "solid-ts" "qwik-ts"
	} else {
		$viteTemplates = gum choose "Choose a Vite Template:" "vanilla" "vue" "react" "preact" "lit" "svelte" "solid" "qwik"
	}

	switch ($ProjectManager) {
		"bun" { bun create vite $Name --template $viteTemplates }
		"npm" { npm create vite@latest $Name -- --template $viteTemplates }
		"pnpm" { pnpm create vite $Name --template $viteTemplates }
		"yarn" { yarn create vite $Name --template $viteTemplates }
	}

	Set-Location "./$Name"
	switch ($ProjectManager) {
		"bun" { bun install }
		"npm" { npm install -y }
		"pnpm" { pnpm install }
		"yarn" { yarn install }
	}
}
