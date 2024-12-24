function Initialize-ProjectNode-Adonisjs {
	param ([string]$Name)

	$adonisCmds = @()

	$adonisjsStarterKits = (gum choose --limit=1 --header="Choose AdonisJS's Starter Kits:" "API (JSON API servers)" "Inertia (build server-driven single-page applications)" "Slim (minimal)" "Web (traditional)").Trim()
	$adonisjsDatabases = (gum choose --limit=1 --header="Choose AdonisJS's Database:" "None" "SQLite" "PostgreSQL" "MySQL" "MSSQL").Trim()
	$adonisjsAuth = (gum choose --limit=1 --header="Choose AdonisJS's Authentication Guard:" "None" "session" "access_tokens" "basic_auth").Trim()

	switch ($adonisjsStarterKits) {
		"API (JSON API servers)" { $adonisCmds += @('-K=api') }
		"Slim (minimal)" { $adonisCmds += @('-K=slim') }
		"Web (traditional)" { $adonisCmds += @('-K=web') }
		"Inertia (build server-driven single-page applications)" {
			$adonisCmds += @('-K=inertia')
			$inertiaAdapter = (gum choose --limit=1 --header="Choose Inertia Adapter:" "None" "React" "Vue" "Solid" "Svelte").Trim()
			switch ($inertiaAdapter) {
				"None" { $addonisCmds += @() }
				"React" { $adonisCmds += @('--adapter=react') }
				"Vue" { $adonisCmds += @('--adapter=vue') }
				"Solid" { $adonisCmds += @('--adapter=solid') }
				"Svelte" { $adonisCmds += @('--adapter=svelte') }
			}
			$inertiaSsr = Write-YesNoQuestion "Turn server-side rendering ON (Y) or OFF (n)? "
			if ($inertiaSsr.ToUpper() -eq 'Y') { $adonisCmds += @('--ssr') } else { $adonisCmds += @('--no-ssr') }
		}
	}
	switch ($adonisjsDatabases) {
		"None" { $adonisCmds += @() }
		"SQLite" { $adonisCmds += @('--db=sqlite') }
		"PostgreSQL" { $adonisCmds += @('--db=postgres') }
		"MySQL" { $adonisCmds += @('--db=mysql') }
		"MSSQL" { $adonisCmds += @('--db=mssql') }
	}
	switch ($adonisjsAuth) {
		"None" { $addonisCmds += @() }
		"session" { $adonisCmds += @('--auth-guard=session') }
		"access_tokens" { $adonisCmds += @('--auth-guard=access_tokens') }
		"basic_auth" { $adonisCmds += @('--auth-guard=basic_auth') }
	}

	$adonisCmdsStr = [String]::Join(' ', $adonisCmds)
	$cmd = "npm init -y adonisjs@latest $Name -- $adonisCmdsStr"
	Invoke-Expression $cmd
	Remove-Variable cmd
}
