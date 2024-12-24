function Add-ProjectGitignore {
	param ([string]$ProjectPath, [string]$ProjectFramework)

	$gitignoreExists = Test-Path "$ProjectPath/.gitignore" -PathType Leaf
	if ($gitignoreExists) {
		$promptPeek = Write-YesNoQuestion "Found .gitignore file in your project. Take a peek?"
		if ($promptPeek.ToUpper() -eq 'Y') {
			$peekFile = "$ProjectPath/.gitignore"
			if (Get-Command 'bat' -ErrorAction SilentlyContinue) { bat "$peekFile" }
			elseif (Get-Command 'glow' -ErrorAction SilentlyContinue) { glow "$peekFile" }
			else { Get-Content "$peekFile" }
			''
		}
		$overwriteGitignore = Write-YesNoQuestion "Overwrite existing .gitignore?"
		if ($overwriteGitignore.ToUpper -eq 'Y') {
			Remove-Item "$ProjectPath/.gitignore" -Force -ErrorAction SilentlyContinue
			New-Item -Path "$ProjectPath/.gitignore" -Force -ErrorAction SilentlyContinue | Out-Null
			$gitignoreContent = (Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/$ProjectFramework").Content
			Set-Content "$ProjectPath/.gitignore" -Value "$gitignoreContent"

			if ($?) { ''; Write-Success -Entry1 "OK" -Entry2 ".gitignore" -Text "overwritten at $ProjectPath"; '' }
			else { ''; Write-Error -Entry1 "ERROR" -Entry2 ".gitignore" -Text "failed to add to $ProjectPath"; '' }
		}
	} else {
		$createGitignore = Write-YesNoQuestion "Create .gitignore?"
		if ($createGitignore.ToUpper -eq 'Y') {
			New-Item -Path "$ProjectPath/.gitignore" -Force -ErrorAction SilentlyContinue | Out-Null
			$gitignoreContent = (Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/$ProjectFramework").Content
			Set-Content "$ProjectPath/.gitignore" -Value "$gitignoreContent"

			if ($?) { ''; Write-Success -Entry1 "OK" -Entry2 ".gitignore" -Text "added at $ProjectPath"; '' }
			else { ''; Write-Error -Entry1 "ERROR" -Entry2 ".gitignore" -Text "failed to add to $ProjectPath"; '' }
		}
	}
}
