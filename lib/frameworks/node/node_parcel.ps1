function Initialize-ProjectNode-Parcel {
	param ([string]$Name, [string]$ProjectManager, [switch]$tw, [switch]$ts)

	New-Item "$Name" -ItemType Directory -Force -ErrorAction SilentlyContinue
	Set-Location "./$Name"

	switch ($ProjectManager) {
		"bun" {
			bun init; bun add -d parcel
			if ($ts) { bun add -d @types/bun typescript }
			if ($tw -and $ts) { bun add -d tailwindcss postcss; bunx tailwindcss init --ts -p }
			if ($tw -and (!$ts)) { bun add -d tailwindcss postcss; bunx tailwindcss init -p }
		}
		"npm" {
			npm init -y; npm install --save-dev parcel
			if ($ts) { npm install --save-dev typescript }
			if ($tw -and $ts) { npm install --save-dev tailwindcss postcss; npx tailwindcss init --ts -p }
			if ($tw -and (!$ts)) { npm install --save-dev tailwindcss postcss; npx tailwindcss init -p }
		}
		"pnpm" {
			pnpm init; pnpm add -D parcel
			if ($ts) { pnpm add -D typescript }
			if ($tw -and $ts) { pnpm add -D tailwindcss postcss; npx tailwindcss init --ts -p }
			if ($tw -and (!$ts)) { pnpm add -D tailwindcss postcss; npx tailwindcss init -p }
		}
		"yarn" {
			yarn init -2; yarn add -D parcel
			if ($typescript) { yarn add -D typescript }
			if ($tw -and $ts) { yarn add -D tailwindcss postcss; yarn tailwindcss init --ts -p }
			if ($tw -and (!$ts)) { yarn add -D tailwindcss postcss; yarn tailwindcss init -p }
		}
	}

	if ($tw) {
		if (!(Test-Path "./.postcssrc" -PathType Leaf)) {
			New-Item -Path "./.postcssrc" -ItemType File -ErrorAction SilentlyContinue | Out-Null
		}
		$postcss = @"
{
"plugins": {
"tailwindcss": {}
}
}
"@
		Set-Content "./.postcssrc" -Value $postcss
	}
}
