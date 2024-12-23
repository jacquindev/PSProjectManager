function Initialize-ProjectNode-NextJS {
	param ([string]$Name, [string]$ProjectManager, [switch]$tw, [switch]$ts)

	$cmd = "npx create-next-app@latest $Name"

	if ($ts) { $cmd += " --typescript" } else { $cmd += " --javascript" }
	if ($tw) { $cmd += " --tailwind" }

	switch ($ProjectManager) {
		"bun" { $cmd += " --use-bun" }
		"npm" { $cmd += " --use-npm" }
		"pnpm" { $cmd += " --use-pnpm" }
		"yarn" { $cmd += " --use-yarn" }
	}

	Invoke-Expression $cmd
	Remove-Variable cmd
}
