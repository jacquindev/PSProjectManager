function New-Project {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Define the name of your project')]
		[Alias('n', 'p')][string]$ProjectName,

		[Parameter(Mandatory = $false, HelpMessage = 'Define main language of your project. Available options: [dotnet, node, php, python, rust]')]
		[ValidateSet('dotnet', 'node', 'php', 'python', 'rust', 'unknown')]
		[Alias('l')][string]$Language,

		[Parameter(HelpMessage = 'Whether or not to add project to a GitHub Repository')]
		[Alias('g')][switch]$Github,

		[Parameter(HelpMessage = 'Whether or not to create new project with cookiecutter')]
		[Alias('c')][switch]$CookieCutter
	)

	. "$PSScriptRoot/lib/Get-DevDrive.ps1"

	# Determine where to store all the projects (on DevDrive / in $HOME directory)
	if ($(Get-DevDrive) -eq 'No Dev Drive found on the system.') { $ProjectLocation = "$HOME/projects" }
	else { $ProjectLocation = "$(Get-DevDrive)/projects" }
	if (!(Test-Path $ProjectLocation -PathType Container)) {
		New-Item "$ProjectLocation" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
	}

	# If project folder already exists
	if (Test-Path "$ProjectLocation/$ProjectName" -PathType Container) {
		$prettyName = $(gum style --foreground="#fab387" --italic "$ProjectName")
		$prettyLocation = $(gum style --foreground="#94e2d5" --bold "$ProjectLocation")
		Write-Host "Project $prettyName already exists in $prettyLocation. Moving to the project folder..."
		Set-Location "$ProjectLocation/$ProjectName"
		Remove-Variable prettyName, prettyLocation

		# Create new project folder inside the existed project
		$subProjectFolder = $(Write-Host "Create sub project folder for your project? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
		if ($subProjectFolder.ToUpper() -eq 'Y') {
			$ProjectLocation = "$ProjectLocation/$ProjectName"
			# Input new project name (if it still match the old one, loop until different)
			do {
				$newProjectName = (gum input --prompt="Please input your new project name: ")
				Write-Warning "Please enter a different project name your project! Try again..."
			} until ($ProjectName -ne "$newProjectName")

			$ProjectName = $newProjectName

		} else {
			Write-Host "Opening $ProjectName with your editor..."
			break
		}
	}

	# Use cookiecutter to create new project then exit this script
	if ($CookieCutter) {
		if (!(Get-Command cookiecutter -ErrorAction SilentlyContinue)) {
			Write-Warning "Command not found: cookiecutter. Please install to use this feature."; return
		}

		if ($null -eq "$Env:COOKIECUTTER_CONFIG") {
			Write-Warning "Please setup environment variable where you store cookiecutter's configuration"
			Write-Host "The configuration file MUST HAVE the following:" -ForegroundColor Green
			''
			$content = @'
default_content:
		full_name: "Your FullName"
		email: "youremail@example.com"
		github_username: "yourusername"
cookiecutters_dir: "full/path/to/cookiecutters/template/dir"
'@
			Write-Host $content
			Remove-Variable content
			return
		}

		Write-Host "Using 'cookiecutter' to create new project..." -ForegroundColor Blue

		$templatesPath = (Get-Content "$Env:COOKIECUTTER_CONFIG" | ConvertFrom-Yaml).cookiecutters_dir
		$templateRepo = (gum input --prompt="Please input template's repo name: " --placeholder="E.g: cookiecutter/cookiecutter-django")
		$templateDir = "$templatesPath/$($templateRepo.Split('/')[1])"

		if (Test-Path "$templateDir") {
			Set-Location $ProjectLocation
			cookiecutter.exe "$($templateRepo.Split('/')[1])"
		} else {
			$githubPrefix = "https://github.com/"
			$templateRepoString = "$githubPrefix" + "$templateRepo"
			$repoResult = curl.exe -s -o /dev/null -I -w "%{http_code}" $templateRepoString
			if ($repoResult -match '404') {
				Write-Warning "Repo: $templateRepo not found. Exiting..."; return
			} else {
				Set-Location $ProjectLocation
				Write-Host "Trying to use 'cookiecutter' to create new project..." -ForegroundColor Blue
				cookiecutter.exe $templateRepoString
			}
			Remove-Variable githubPrefix, templateRepoString, repoResult
		}
		Write-Host "Find more cookiecutter templates at " -NoNewline
		Write-Host "https://github.com/search?q=cookiecutter&type=repositories" -ForegroundColor Blue
		Remove-Variable templatesPath, templateRepo, templateDir
	}



	if (!$CookieCutter) {
		# Source files from this script
		. "$PSScriptRoot/__.ps1"

		# If the use hasn't specified a language in the command
		if (!$Language) {
			$Language = (gum choose --limit=1 --header="Choose your main project language:" "dotnet" "node" "php" "python" "rust" "unknown").Trim()
		}

		switch ($Language) {
			'dotnet' {
				if (!(Get-Command dotnet -ErrorAction SilentlyContinue)) {
					Write-Warning "Command not found: dotnet. Please install to use this feature."; return
				}
				$useTemplate = $(Write-Host "Use A DotNet Template for your project? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($useTemplate.ToUpper() -eq 'Y') { $Template = $True } else { $Template = $False }
				Initialize-ProjectDotnet -ProjectRoot $ProjectLocation -ProjectName $ProjectName -Template:$Template
			}

			'node' {
				if (!(Get-Command node -ErrorAction SilentlyContinue)) {
					Write-Warning "Command not found: node. Please install to use this feature."; return
				}
				Initialize-ProjectNode -ProjectRoot $ProjectLocation -ProjectName $ProjectName
			}

			'php' {
				if (!(Get-Command php -ErrorAction SilentlyContinue)) {
					Write-Warning "Command not found: php. Please install to use this feature."; return
				}
				$installWebFramework = $(Write-Host "Use PHP Web Frameworks now? (y/n) " -NoNewline -ForegroundColor Cyan; Read-Host)
				if ($installWebFramework.ToUpper() -eq 'Y') { $WebFramework = $True } else { $WebFramework = $False }
				Initialize-ProjectPHP -ProjectRoot $ProjectLocation -ProjectName $ProjectName -WebFramework:$WebFramework
			}

			'python' {
				$py = Get-Command py -ErrorAction SilentlyContinue
				$python = Get-Command python -ErrorAction SilentlyContinue
				$python3 = Get-Command python3 -ErrorAction SilentlyContinue
				if (!$py -or !$python -or !$python3) {
					Write-Warning "Command not found: py|python|python3. Please install to use this feature."; return
				}
				if ($py) { Set-Alias -Name 'python' -Value 'py' }
				Remove-Variable py, python, python3

				$useWebFramework = $(Write-Host "Use Python Web Framework? (y/n) " -NoNewline -ForegroundColor Cyan; Read-Host)
				$installPythonDev = $(Write-Host "Install Python Dev Dependencies now? (y/n) " -NoNewline -ForegroundColor Cyan; Read-Host)

				if ($useWebFramework.ToUpper() -eq 'Y') { $WebFramework = $True } else { $WebFramework = $False }
				if ($installPythonDev.ToUpper() -eq 'Y') { $DevDependencies = $True } else { $DevDependencies = $False }
				Initialize-ProjectPython -ProjectRoot $ProjectLocation -ProjectName $ProjectName -WebFramework:$WebFramework -DevDependencies:$DevDependencies
			}

			'rust' {
				$rustup = Get-Command rustup -ErrorAction SilentlyContinue
				$cargo = Get-Command cargo -ErrorAction SilentlyContinue
				if (!$rustup -or !$cargo) {
					Write-Warning "Command not found: rustup|cargo. Please install to use this feature."; return
				}
				Remove-Variable rustup, cargo

				$useWebFramework = $(Write-Host "Use Rust Web Framework? (y/n) " -NoNewline -ForegroundColor Cyan; Read-Host)
				if ($useWebFramework.ToUpper() -eq 'Y') { $WebFramework = $True } else { $WebFramework = $False }
				Initialize-ProjectRust -ProjectRoot $ProjectLocation -ProjectName $ProjectName -WebFramework:$WebFramework
			}

			'unknown' {
				Set-Location "$ProjectLocation"
				New-Item "$ProjectName" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
				$prettyName = $(gum style --foreground="#fab387" --italic "$ProjectName")
				$prettyLocation = $(gum style --foreground="#94e2d5" --bold "$ProjectLocation")
				Write-Host "Project $prettyName created $prettyLocation. Moving to the project folder..."
				Set-Location "$ProjectLocation/$ProjectName"
				Remove-Variable prettyName, prettyLocation
			}
		}
	}

	Add-License -ProjectRoot $ProjectLocation -ProjectName $ProjectName
	Add-Readme -ProjectRoot $ProjectLocation -ProjectName $ProjectName

	if ($Github) {
		if (!(Test-Path "$env:APPDATA/GitHub CLI/hosts.yml")) { gh auth login }

		$UserId = (gh auth status | Select-Object -Index 1).Split(' ')[8].Trim()
		$gitRepoRemote = (gh repo list | Select-String "$UserId/$ProjectName")

		if (!$gitRepoRemote) {
			$Description = (gum input --prompt="Description for your $ProjectName project: ").Trim()
			gh repo create $ProjectName --private --description="$Description"

			$prettyName = $(gum style --foreground="#fab387" --italic "$ProjectName")
			$prettyLocation = $(gum style --foreground="#74c7ec" --bold "https://github.com/$UserId/$ProjectName.git")
			$prettyCommand = $(gum style --foreground="#cba6f7" "gh repo edit --visibility public --accept-visibility-change-consequences")
			Write-Host "Your project $prettyName created at $prettyLocation"
			''
			Write-Host "To change visibility of your project (private -> public), use the command:"
			Write-Host "📌  $prettyCommand"
			Remove-Variable prettyName, prettyLocation, prettyCommand
		}

		Set-Location "$ProjectLocation/$ProjectName"

		if (!(Test-Path "./.git" -PathType Container)) { git init -q }
		if ($(git symbolic-ref --short HEAD) -ne "main") { git branch -M main }
		if ($null -eq $(git remote)) { git remote add origin "https://github.com/$UserId/$ProjectName.git" }
	}

	Set-Location "$ProjectLocation/$ProjectName"

}
