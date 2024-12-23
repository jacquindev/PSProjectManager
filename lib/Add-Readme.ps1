function Add-Readme {
	param ([string]$ProjectRoot, [string]$ProjectName)

	# Set working directory
	Set-Location $PSScriptRoot
	[Environment]::CurrentDirectory = $PSScriptRoot

	if (!(Test-Path "$ProjectRoot/$ProjectName/README*" -PathType Leaf)) {
		$promptReadme = $(Write-Host "Add README for your project? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
		if ($promptReadme.ToUpper() -eq 'Y') {
			Copy-Item -Path "$PSScriptRoot/templates/readme-template.md" -Destination "$ProjectRoot/$ProjectName/README.md" -ErrorAction SilentlyContinue
			$readmeFile = Get-Content "$ProjectRoot/$ProjectName/README.md"
			$username = (gh auth status | Select-Object -Index 1).Split(' ')[8].Trim()
			$readmeFile -replace 'USERNAME', "$username" | Set-Content "$ProjectRoot/$ProjectName/README.md"
			$readmeFile -replace 'PROJECTNAME', "$ProjectName" | Set-Content "$ProjectRoot/$ProjectName/README.md"
			$readmeFile -replace 'AUTHORNAME', "$(git config user.name)" | Set-Content "$ProjectRoot/$ProjectName/README.md"

			$prettyfile = (gum style --bold --foreground="#a6e3a1" "README.md")
			Write-Host "Add $prettyfile for your project."

			Remove-Variable readmefile, username, prettyfile
		}
	}
}
