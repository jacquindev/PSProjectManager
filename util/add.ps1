function Add-NodeGlobalPackage {
	param (
		[ValidateSet('bun', 'npm', 'pnpm', 'yarn')][string]$PackageManager,
		[string]$Package
	)

	$prettyPkgManager = gum style --bold --foreground="#fab387" "$PackageManager"
	$prettyPkgName = gum style --italic --foreground="#74c7ec" "$Package"
	$title = "Installing $prettyPkgName using $prettyPkgManager..."

	switch ($PackageManager) {
		"bun" { gum spin --title="$title" -- bun add $Package --global }
		"npm" { gum spin --title="$title" -- npm install $Package --global }
		"pnpm" { gum spin --title="$title" -- pnpm add $Package --global }
		"yarn" { gum spin --title="$title" -- yarn global add $Package }
	}
}


function Add-Gitignore {
	param (
		[Parameter(Mandatory = $True)]
		[Alias('t')][array]$Targets,

		[Parameter(Mandatory = $False)]
		[Alias('o')][string]$OutputDir = "$($(Get-Location).Path)"
	)

	$Targets = $Targets.ToLower() -join ','

	$url = "https://www.toptal.com/developers/gitignore/api/$Targets"
	$response = Invoke-WebRequest -Uri "$url"

	if ($response.StatusCode -ne 200) {
		Write-Error "$Targets could not found on gitignore.io / no internet connection."
		break
	}

	$outputFile = "$OutputDir/.gitignore"
	$gitignoreContent = $response.Content

	if (Test-Path $outputFile -PathType Leaf) {
		$peek = Write-YesNo "Found .gitignore file at $OutputDir. Take a peek?" -n
		if ($peek.ToUpper() -eq 'Y') {
			if (Get-Command bat -ErrorAction SilentlyContinue) { bat "$outputFile"; '' }
			else { Get-Content "$outputFile"; '' }
		}

		$confirm = Write-YesNo "Overwrite existing .gitignore?" -n
		if ($confirm.ToUpper() -eq 'Y') {
			Set-Content -Path "$outputFile" -Value "$gitignoreContent"
			if ($?) { ''; Write-Host ".gitignore overwritten at $OutputDir" -ForegroundColor Green }
			else { ''; Write-Error ".gitignore failed to add to $OutputDir" }
		}
	} else {
		Set-Content -Path "$outputFile" -Value "$gitignoreContent"
		if ($?) { ''; Write-Host ".gitignore added at $OutputDir" -ForegroundColor Green }
		else { ''; Write-Error ".gitignore failed to add to $OutputDir" }
	}
}

function Add-License {
	param (
		[Alias('n', 'p')][string]$ProjectName,
		[Alias('a')][string]$Author = "$(git config user.name)",
		[Alias('o')][string]$OutputDir = "$($(Get-Location).Path)"
	)

	if (!(Test-Path "$OutputDir/LICENSE*" -PathType Leaf)) {
		if (!(gh extension list | Select-String "Shresht7/gh-license")) {
			gum spin --title="Installing GitHub CLI extension: gh-license..." -- gh extension install Shresht7/gh-license
		}

		$License = gum choose --header="Choose a License to Add to your project:" $(gh license list)
		$License = $License.Split(' ')[0]

		gh license create "$License" --author "$Author" --project "$ProjectName"

		if ($?) { ''; Write-Host "$License License added at $OutputDir" -ForegroundColor Green }
		else { ''; Write-Error "$License License failed to add to $OutputDir" }
	}

	else {
		$createLicense = Write-YesNo "A LICENSE exists at $OutputDir. Create new one?" -n
		if ($createLicense.ToUpper() -eq 'Y') {
			$License = gum choose --header="Choose a License to Add to your project:" $(gh license list)
			$License = $License.Split(' ')[0]

			gh license create "$License" --author "$Author" --project "$ProjectName"

			if ($?) { ''; Write-Host "$License License added at $OutputDir" -ForegroundColor Green }
			else { ''; Write-Error "$License License failed to add to $OutputDir" }
		}
	}
}

function Add-Readme {
	param (
		[Parameter(Mandatory = $True)]
		[Alias('n', 'p')][string]$ProjectName,

		[Parameter(Mandatory = $False)]
		[Alias('o')][string]$OutputDir = "$($(Get-Location).Path)",

		[Parameter(Mandatory = $False)]
		[Alias('i')][array]$TechStackIcons,

		[Parameter(Mandatory = $False)]
		[Alias('b')][switch]$Badges,

		[Parameter(Mandatory = $False)]
		[ValidateSet('minimal', 'frontend', 'backend', 'general')]
		[Alias('t')][string]$Template
	)

	if (Test-Path "$OutputDir/README.md" -PathType Leaf) {
		$peek = Write-YesNo "Found README file at $OutputDir. Take a peek?" -n
		if ($peek.ToUpper() -eq 'Y') {
			if (Get-Command bat -ErrorAction SilentlyContinue) { bat "$OutputDir/README.md" }
			else { Get-Content "$OutputDir/README.md" }
		}

		$confirm = Write-YesNo "Overwrite existing README.md?" -y
		if ($confirm.ToUpper() -eq 'N') { Write-Host "Skipped process..." -ForegroundColor DarkGray; return }
	}

	$dataReadme = "$PSScriptRoot/../data/readme-templates"
	$prettyFile = gum style --foreground="#eba0ac" --italic "README.md"

	if (!$TechStackIcons) {
		$html = "skill_icons.html"
		$showIcons = Write-YesNo "Show list of icons available?" -n
		if ($showIcons.ToUpper() -eq 'Y') {
			Start-Process "$dataReadme/skill-icons/$html"
			if ($LASTEXITCODE -eq 0) { ''; Write-Host "$html opened in your browser"; '' }
			else { ''; Write-Error "$html failed to open in your browser"; '' }
		}

		$iconList = Get-Content "$PSScriptRoot/../data/readme-templates/skill-icons/skill_icons.txt"
		$manualIcons = Write-PromptInput "Input icon names" "js,docker,py,vue" "separated by COMMA"
		$manualIcons = $manualIcons.Split(',')
		foreach ($icon in $manualIcons) {
			if ($iconList -contains "$icon") { $TechStackIcons += @("$icon") }
		}
	}

	if (!$Template) {
		$Template = gum choose --header="Choose a README.md template:" "minimal" "frontend" "backend" "general"
	}

	switch ($Template) {
		"minimal" { $originalFile = "$dataReadme/minimal/minimal.md"	}
		"frontend" { $originalFile = "$dataReadme/simple/frontend.md" }
		"backend" { $originalFile = "$dataReadme/simple/backend.md" }
		"general" { $originalFile = "$dataReadme/general/general.md" }
	}

	$TechStackIcons = $TechStackIcons -join ','
	$TechStackTheme = gum choose --header="Choose dark or light icon theme:" "dark" "light"
	$readmeFile = "$OutputDir/README.md"
	$readmeData = @{
		'PROJECT_NAME'                  = "$ProjectName"
		'USER_GITNAME'                  = "$((gh auth status | Select-Object -Index 1).Trim().Split(' ')[6])"
		'USER_FULLNAME'                 = "$(git config user.name)"
		'USER_EMAIL'                    = "$(git config user.email)"
		'astro,aws,azure,vscode,docker' = "$TechStackIcons&theme=$TechStackTheme"
	}

	Get-Content -Path "$originalFile" | ForEach-Object {
		$line = $_
		$readmeData.GetEnumerator() | ForEach-Object {
			if ($line -match $_.Key) { $line = $line -replace $_.Key, $_.Value }
		}
		$line
	} | Set-Content -Path "$readmeFile"

	if ($?) { ''; Write-Host "README.md added at $OutputDir" -ForegroundColor Green }
	else { ''; Write-Error "README.md failed to add to $OutputDir" }

	if ($Badges) {
		''
		$badgesOpen = "gh repo view alexandresanlim/Badges4-README.md-Profile --web"
		$showBadges = Write-YesNo "Show available badges' links for README.md?" -n
		if ($showBadges.ToUpper() -eq 'Y') {	Invoke-Expression $badgesOpen }

		$badgeIndex = @()

		$badgesJson = Get-Content "$dataReadme/badges/badges.json" | ConvertFrom-Json
		$badgesType = $badgesJson.badges.type

		$chooseType = gum choose --no-limit --header="Choose badge types to scaffolding into:" $badgesType
		foreach ($t in $chooseType) {
			$badgesList = $badgesJson.badges | Where-Object { $_.type -eq "$t" }
			$chooselist = gum choose --no-limit --header="Choose badge names:" $($badgesList.list.name)
			foreach ($l in $chooselist) {
				$badgeUrl = $badgesList.list | Where-Object { $_.name -eq "$l" }
				$url = $badgeUrl.url
				$index = $badgeUrl.name
				$badgeIndex += @("![$index]($url)")
			}
		}

		if ($null -ne $badgeIndex) {
			$badgeIndex = $badgeIndex.Trim()

			''
			Write-Host "-------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
			Write-Host "To add badges, please copy the following line(s) to your preferred location in file $prettyFile :" -ForegroundColor Blue
			''; Write-Output $badgeIndex; ''
			Write-Host "-------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
		}
	}

	''
	$dot = gum style --foreground="#a6e3a1" "●"
	Write-Host "$dot  There are many more ways to create a $prettyFile file quickly. For example,"
	Write-Host "$dot  Visit the following link: " -NoNewline
	Write-Host "https://www.readme-templates.com" -ForegroundColor Blue
	Write-Host "$dot  Click 'Copy markdown' and paste it to your current README.md file."
	''; gum style --foreground="#a6e3a1" --bold "🎉 VOILA!"
	Remove-Variable prettyFile, dot

}
