function New-Project {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $True)]
		[Alias('n')][string]$ProjectName,

		[Parameter(Mandatory = $False)]
		[Alias('r', 'ProjectRoot')][string]$ProjectLocation,

		[Parameter(Mandatory = $False)]
		[ValidateSet('dotnet', 'go', 'node', 'php', 'python', 'rust', 'unknown')]
		[Alias('l')][string]$Language,

		[Parameter(Mandatory = $False)]
		[Alias('t')][switch]$Template,

		[Parameter(Mandatory = $False)]
		[Alias('g')][switch]$GitHub
	)

	. "$PSScriptRoot/util/__.ps1"
	. "$PSScriptRoot/lib/__.ps1"

	if (!$ProjectLocation) { $ProjectLocation = "$(Get-Location)" }
	else { New-DirectoryIfNotExist $ProjectLocation; Set-Location $ProjectLocation }

	# Test if the project is already exists
	if (Test-Path "./$ProjectName" -PathType Container) {
		Write-Warning "Project $ProjectName already exists!"
		Write-Host "Moving to the project folder..." -ForegroundColor DarkGray
		Set-Location "./$ProjectName"

		$createSubprojectFolder = Write-YesNo "Create new project in project $ProjectName?" -n
		if ($createSubprojectFolder.ToUpper() -eq 'Y') {
			do {
				$newProjectName = Write-PromptInput "Input subfolder project name" "another-project-name"
				if (Test-Path "./$newProjectName" -PathType Container) {
					Write-Warning "Subfolder project already exists. Please input another name for your project!"
				}
			} until (!(Test-Path "./$newProjectName" -PathType Container))
			$ProjectName = $newProjectName
		} else { break }
	}

	# if use template
	if ($Template) {
		$templateSavePath = "$PSScriptRoot/_psproject_templates"
		if (Test-Path "$templateSavePath/*/*") {
			$useLocalTemplate = Write-YesNo "Found saved templates. Use local saved template for your project?" -n
			if ($useLocalTemplate.ToUpper() -eq 'Y') {
				$templates = (Get-ChildItem -Path "$templateSavePath" -Directory).Name
				$chooseTemplate = gum choose --header="Choose a local template:" $templates
				Copy-Item -Path "$templateSavePath/$chooseTemplate" -Destination "./$ProjectName" -Force -Recurse -ErrorAction SilentlyContinue
				if ($?) { Write-Host "$ProjectName created using template $chooseTemplate."; Set-Location "./$ProjectName" }
				else { Write-Error "$ProjectName failed to create using template $chooseTemplate." }
			} else {
				do {
					$chooseTemplate = Write-PromptInput "Enter a GitHub repository name:" "e.g., username/repo_name"
					if ((CheckGitHubRepoExists "$chooseTemplate") -eq $False) {
						Write-Warning "Repository $chooseTemplate not found. Please try again!"
					}
				} until ((CheckGitHubRepoExists "$chooseTemplate") -eq $True)
				New-ProjectUseTemplate -ProjectName $ProjectName -Template $chooseTemplate
			}
		} else {
			do {
				$chooseTemplate = Write-PromptInput "Enter a GitHub repository name:" "e.g., username/repo_name"
				if ((CheckGitHubRepoExists "$chooseTemplate") -eq $False) {
					Write-Warning "Repository $chooseTemplate not found. Please try again!"
				}
			} until ((CheckGitHubRepoExists "$chooseTemplate") -eq $True)
			New-ProjectUseTemplate -ProjectName $ProjectName -Template $chooseTemplate
		}

		if (Test-Path "./$ProjectName") { Set-Location "./$ProjectName" }
	}

	if (!$Template) {
		if (!$Language) {
			$Language = gum choose --header="Choose a main language for your project" "dotnet" "go" "node" "php" "python" "rust" "unknown"
		}

		switch ($Language) {
			"dotnet" {
				$useTmpl = Write-YesNo "Use .NET template for your project?"
				$addTools = Write-YesNo "Add .NET tool to your project?"
				$addDb = Write-YesNo "Add SQL related object to your project?"

				if ($useTmpl.ToUpper() -eq 'Y') { $Template = $True } else { $Template = $False }
				if ($addTools.ToUpper() -eq 'Y') { $AddTool = $True } else { $AddTool = $False }
				if ($addDb.ToUpper() -eq 'Y') { $DB = $True } else { $DB = $False }
				Initialize-ProjectDotnet -ProjectName $ProjectName -Template:$Template -AddTool:$AddTool -DB:$DB
			}
		}
	}

	$addBadges = Write-YesNo "Create badges for your README.md file?" -y
	if ($addBadges.ToUpper() -ne 'N') { $Badges = $True } else { $Badges = $False }
	Add-Readme -ProjectName $ProjectName -Badges:$Badges
}

Export-ModuleMember -Function New-Project
