function Add-Readme {
	param ([string]$ProjectRoot, [string]$ProjectName)

	# Set working directory
	Set-Location $PSScriptRoot
	[Environment]::CurrentDirectory = $PSScriptRoot

	if (!(Test-Path "$ProjectRoot/$ProjectName/README.md" -PathType Leaf)) {
		$promptReadme = Write-YesNoQuestion "Add README for your project?"
		if ($promptReadme.ToUpper() -eq 'Y') {
			Copy-Item -Path "$PSScriptRoot/templates/readme-template.md" -Destination "$ProjectRoot/$ProjectName/README.md" -ErrorAction SilentlyContinue
			if ($?) { ''; Write-Success -Entry1 "OK" -Entry2 "README.md" -Text "added to your project."; '' }
			else { ''; Write-Error -Entry1 "ERROR" -Entry2 "README.md" -Text "failed to add to your project."; '' }

			$readmeFile = Get-Content "$ProjectRoot/$ProjectName/README.md"
			$username = (gh auth status | Select-Object -Index 1).Split(' ')[8].Trim()
			$readmeFile -replace 'USERNAME', "$username" | Set-Content "$ProjectRoot/$ProjectName/README.md"
			$readmeFile -replace 'PROJECTNAME', "$ProjectName" | Set-Content "$ProjectRoot/$ProjectName/README.md"
			$readmeFile -replace 'AUTHORNAME', "$(git config user.name)" | Set-Content "$ProjectRoot/$ProjectName/README.md"

			Remove-Variable readmefile, username
		}
		Remove-Variable promptReadme
	} else {
		$promptPeek = Write-YesNoQuestion "Found README file in your project. Take a peek?"
		if ($promptPeek.ToUpper() -eq 'Y') {
			$peekFile = "$ProjectRoot/$ProjectName/README.md"
			if (Get-Command 'bat' -ErrorAction SilentlyContinue) { bat "$peekFile" }
			elseif (Get-Command 'glow' -ErrorAction SilentlyContinue) { glow "$peekFile" }
			else { Show-Markdown "$peekFile" }
			''
		}

		$promptReadme = Write-YesNoQuestion "Overwrite existing README.md?"
		if ($promptReadme.ToUpper() -eq 'Y') {
			Remove-Item "$ProjectRoot/$ProjectName/README.md" -Force -ErrorAction SilentlyContinue
			Copy-Item -Path "$PSScriptRoot/templates/readme-template.md" -Destination "$ProjectRoot/$ProjectName/README.md" -ErrorAction SilentlyContinue
			if ($?) { ''; Write-Success -Entry1 "OK" -Entry2 "README.md" -Text "overwritten to your project."; '' }
			else { ''; Write-Error -Entry1 "ERROR" -Entry2 "README.md" -Text "failed to add to your project."; '' }

			$readmeFile = Get-Content "$ProjectRoot/$ProjectName/README.md"
			$username = (gh auth status | Select-Object -Index 1).Split(' ')[8].Trim()
			$readmeFile -replace 'USERNAME', "$username" | Set-Content "$ProjectRoot/$ProjectName/README.md"
			$readmeFile -replace 'PROJECTNAME', "$ProjectName" | Set-Content "$ProjectRoot/$ProjectName/README.md"
			$readmeFile -replace 'AUTHORNAME', "$(git config user.name)" | Set-Content "$ProjectRoot/$ProjectName/README.md"

			Remove-Variable readmefile, username
		}
		Remove-Variable promptReadme, promptPeek
	}
}
