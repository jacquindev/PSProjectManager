function Convert-NamingConventionCase {
	<#
	.EXAMPLE
		Convert-NamingConventionCase -inputString "camelCaseToSnakeCase" -snake
		Convert-NamingConventionCase -inputString "kebab-case-to-Pascal-case" -pascal
		Convert-NamingConventionCase -inputString "snake_case_to_camel_Case" -camel
	#>
	[CmdletBinding()]
	param (
		[string]$inputString,
		[switch]$camel,
		[switch]$pascal,
		[switch]$snake,
		[switch]$kebab
	)

	switch -regex ($inputString) {
		"^[a-z]+(?:[A-Z][a-z]+)*$" {
			# camelCase
			if ($snake) { return [regex]::replace($inputString, '(?<=.)(?=[A-Z])', '_').ToLower() }	# 'camelCase' => 'snake_case'
			elseif ($kebab) { return [regex]::replace($inputString, '(?<=.)(?=[A-Z])', '-').ToLower() } # 'camelCase' => 'kebab-case'
			elseif ($pascal) { return $inputString.Substring(0, 1).ToUpper() + $inputString.Substring(1) } # 'camelCase' => 'PascalCase'
			else { return $inputString }
		}
		"^[A-Z][a-z]+(?:[A-Z][a-z]+)*$" {
			# PascalCase
			if ($snake) { return [regex]::replace($inputString, '(?<=.)(?=[A-Z])', '_').ToLower() } # 'PascalCase' => 'snake_case'
			elseif ($kebab) { return [regex]::replace($inputString, '(?<=.)(?=[A-Z])', '-').ToLower() }  # 'PascalCase' => 'kebab-case'
			elseif ($camel) { return $inputString.SubString(0, 1).ToLower() + $inputString.Substring(1) }  # 'PascalCase' => 'camelCase'
			else { return $inputString }
		}
		"^[a-z]+(?:_[a-z]+)*$" {
			# snake_case
			if ($kebab) { return ($inputString -replace '_', '-').ToLower() } # 'snake_case' => 'kebab-case'
			elseif ($camel) { $inputString = [regex]::replace($inputString.ToLower(), '(^|_)(.)', { $args[0].Groups[2].Value.ToUpper() }); return $inputString.SubString(0, 1).ToLower() + $inputString.Substring(1) } # 'snake_case' => 'camelCase'
			elseif ($pascal) { return [regex]::replace($inputString.ToLower(), '(^|_)(.)', { $args[0].Groups[2].Value.ToUpper() }) } # 'snake_case' => 'PascalCase'
			else { return $inputString }
		}
		"^[a-z]+(?:-[a-z]+)*$" {
			# kebab-case
			if ($snake) { return ($inputString -replace '-', '_').ToLower() } # 'kebab-case' => 'snake_case'
			elseif ($camel) { $inputString = [regex]::replace($inputString.ToLower(), '(^|-)(.)', { $args[0].Groups[2].Value.ToUpper() }); return $inputString.SubString(0, 1).ToLower() + $inputString.Substring(1) } # 'kebab-case' => 'camelCase'
			elseif ($pascal) { return [regex]::replace($inputString.ToLower(), '(^|-)(.)', { $args[0].Groups[2].Value.ToUpper() }) } # 'kebab-case' => 'PascalCase'
			else { return $inputString }
		}
	}
}

function Add-ProjectReadme {
	param ([string]$ProjectPath, [string]$ProjectName, [string]$AuthorName, [string]$UserName)

	$readmeTemplate = "$PSScriptRoot/../templates/readme-template.md"

	if (Test-Path "$ProjectPath/README*" -PathType Leaf) {
		Write-Host "README already exists at $ProjectPath."
		$overwriteReadme = $(Write-Host "Overwrite existing README? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
		if ($overwriteReadme.ToUpper() -eq 'Y') {
			Remove-Item "$ProjectPath/README*" -Force -ErrorAction SilentlyContinue
			Copy-Item "$readmeTemplate" -Destination "$ProjectPath/README.md" -ErrorAction SilentlyContinue
			$readmeFile = "$ProjectPath/README.md"
			$md = Get-Content -Path "$readmeFile"
			$md -replace 'USERNAME', "$UserName" | Set-Content "$readmeFile"
			$md -replace 'AUTHORNAME', "$AuthorName" | Set-Content "$readmeFile"
			$md -replace 'PROJECTNAME', "$ProjectName" | Set-Content "$readmeFile"
			Write-Success -Entry1 "OK" -Entry2 "README.md" -Text "overwritten at $ProjectPath"
		}
	} else {
		$createReadme = $(Write-Host "Create README.md file? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
		if ($createReadme.ToUpper -eq 'Y') {
			Copy-Item "$readmeTemplate" -Destination "$ProjectPath/README.md" -ErrorAction SilentlyContinue
			$readmeFile = "$ProjectPath/README.md"
			$md = Get-Content -Path "$readmeFile"
			$md -replace 'USERNAME', "$UserName" | Set-Content "$readmeFile"
			$md -replace 'AUTHORNAME', "$AuthorName" | Set-Content "$readmeFile"
			$md -replace 'PROJECTNAME', "$ProjectName" | Set-Content "$readmeFile"
			Write-Success -Entry1 "OK" -Entry2 "README.md" -Text "created at $ProjectPath"
		}
	}
}

function Add-ProjectGitignore {
	param ([string]$ProjectPath, [string]$ProjectFramework)

	$gitignoreExists = Test-Path "$ProjectPath/.gitignore" -PathType Leaf
	if ($gitignoreExists) {
		Write-Host ".gitignore already exists at $ProjectPath."
		$overwriteGitignore = $(Write-Host "Overwrite existing .gitignore? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
		if ($overwriteGitignore.ToUpper -eq 'Y') {
			Remove-Item "$ProjectPath/.gitignore" -Force -ErrorAction SilentlyContinue
			New-Item -Path "$ProjectPath/.gitignore" -Force -ErrorAction SilentlyContinue | Out-Null
			$gitignoreContent = (Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/$ProjectFramework").Content
			Set-Content "$ProjectPath/.gitignore" -Value "$gitignoreContent"
			Write-Success -Entry1 "OK" -Entry2 ".gitignore" -Text "overwritten at $ProjectPath"
		}
	} else {
		$createGitignore = $(Write-Host "Create .gitignore? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
		if ($createGitignore.ToUpper -eq 'Y') {
			New-Item -Path "$ProjectPath/.gitignore" -Force -ErrorAction SilentlyContinue | Out-Null
			$gitignoreContent = (Invoke-WebRequest -Uri "https://www.toptal.com/developers/gitignore/api/$ProjectFramework").Content
			Set-Content "$ProjectPath/.gitignore" -Value "$gitignoreContent"
			Write-Success -Entry1 "OK" -Entry2 ".gitignore" -Text "created at $ProjectPath"
		}
	}
}

function Remove-LockFiles {
	param ([string]$ProjectPath)
	@('package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb') | ForEach-Object {
		if (Test-Path "$ProjectPath/$_" -PathType Leaf) {
			Remove-Item -Path "$ProjectPath/$_" -Force -ErrorAction SilentlyContinue
		}
	}
}

function Write-LinkInformation {
	param ([string]$Link)

	$webpage = (gum style --foreground="#74c7ec" --italic "$Link")
	Write-Host "$emoji" -NoNewline
	Write-Host "👉  Visit $webpage for more information"
}
