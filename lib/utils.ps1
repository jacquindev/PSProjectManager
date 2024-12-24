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

function Write-LinkInformation {
	param ([string]$Link)

	$webpage = (gum style --foreground="#74c7ec" --italic "$Link")
	Write-Host "🔗  Visit $webpage for more information"
	''
}

function Write-YesNoQuestion {
	param ([string]$Question)

	$ask = (gum style --foreground="#94e2d5" --italic "$Question")
	$yN = (gum style --foreground="#9399b2" --bold "[Y/n]:")
	Write-Host "❔  $ask $yN " -NoNewline; Read-Host
}

function Write-PromptInput {
	param ([string]$Prompt, [string]$Example)

	gum input --prompt.foreground="#cba6f7" --prompt="⭐  $Prompt ❯ " --placeholder="  $Example"
}

function Remove-LockFiles {
	param ([string]$ProjectPath)
	@('package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb') | ForEach-Object {
		if (Test-Path "$ProjectPath/$_" -PathType Leaf) {
			Remove-Item -Path "$ProjectPath/$_" -Force -ErrorAction SilentlyContinue
		}
	}
}
