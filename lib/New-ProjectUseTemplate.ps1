function New-ProjectUseTemplate {
	param ([string]$ProjectName, [string]$Template)

	$t = gh repo view $Template --json="defaultBranchRef,description,diskUsage,isTemplate,languages,name,nameWithOwner,owner,repositoryTopics,url" | ConvertFrom-Json
	$tInfo = [PSCustomObject]@{
		Name          = $t.name
		Author        = $t.owner
		FullName      = $t.nameWithOwner
		URL           = $t.url
		DefaultBranch = $t.defaultBranchRef.name
		DiskUsage     = "$($t.diskUsage) MB"
		Languages     = $t.languages.node.name -join ', '
		Topics        = $t.repositoryTopics.name -join ', '
	}

	$showInfo = Write-YesNo "Show chosen template information?"
	if ($showInfo.ToUpper() -eq 'Y') { $tInfo | Format-List * }
	$showReadme = Write-YesNo "Show template's repository README?"
	if ($showReadme.ToUpper() -eq 'Y') { gh repo view $Template }
	$openBrowser = Write-YesNo "Open $Template in browser?"
	if ($openBrowser.ToUpper() -eq 'Y') { gh repo view $Template --web }


	$createproject = Write-YesNo "Use template $($tInfo.Name) to create new project?" -y
	if ($createproject.ToUpper() -ne 'N') {
		''
		$l = ($t.languages.size | Sort-Object)[-1]
		$lang = ($t.languages | Where-Object { $_.size -eq "$l" }).node.name
		$prettyTmpl = gum style --italic --foreground="#cba6f7" "$($tInfo.Name)"
		$prettyTitle = "Creating project from template $prettyTmpl using"

		if ((CheckGitHubRepoContent -Repo "$Template" -File "cookiecutter.json") -eq $True) {
			Write-Host "$prettyTitle cookiecutter..." -ForegroundColor DarkGray
			if (!(Get-Command cookiecutter -ErrorAction SilentlyContinue)) { gum spin --title="Installing cookiecutter..." -- pipx install cookiecutter }
			cookiecutter gh:$Template
		}

		elseif ((CheckGitHubRepoContent -Repo "$Template" -File "copier.yml") -eq $True) {
			Write-Host "$prettyTitle copier..." -ForegroundColor DarkGray
			if (!(Get-Command copier -ErrorAction SilentlyContinue)) { gum spin --title="Installing copier..." -- pipx install copier }
			copier copy --trust gh:$Template $ProjectName
		}

		elseif ((CheckGitHubRepoContent -Repo "$Template" -File "bun.lockb") -eq $True) {
			if (!(Get-Command bun -ErrorAction SilentlyContinue)) { gum spin --title="Installing bun..." -- npm install -g bun }
			gum spin --title="$prettyTitle bun..." -- bun create $Template $ProjectName
		}

		elseif ((CheckGitHubRepoContent -Repo "$Template" -File "remix.init") -eq $True) {
			Write-Host "$prettyTitle remix..."
			$pkgManager = gum choose --header="Choose a package manager" "bun" "npm" "pnpm" "yarn"
			$cmd = "npx create-remix@latest $ProjectName --package-manager $pkgManager --template $Template --no-git-init --no-install --no-init-script"
			Invoke-Expression $cmd
		}

		elseif (($lang -eq "TypeScript") -or ($lang -eq "JavaScript") -or ($lang -eq "Svelte")) {
			Write-Host "$prettyTitle degit..."
			$branch = $tInfo.DefaultBranch
			$cmd = "npx degit $Template#$branch $ProjectName"
			Invoke-Expression $cmd
		}

		elseif (($lang -eq "Go")) {
			if (!(Get-Command gonew -ErrorAction SilentlyContinue)) { gum spin --title="Installing gonew..." -- go install golang.org/x/tools/cmd/gonew@latest }
			$domain = (gh auth status | Select-Object -Index 1).Trim().Split(' ')[6]
			gum spin --title="$prettyTitle gonew..." -- gonew github.com/$Template github.com/$domain/$ProjectName
		}

		elseif (($lang -eq "Rust")) {
			if (!(Get-Command cargo-generate -ErrorAction SilentlyContinue)) { gum spin --title="Installing cargo-generate..." -- cargo-binstall --no-confirm cargo-generate }
			gum spin --title="$prettyTitle cargo-generate..." -- cargo generate gh:$Template --name $ProjectName
		}

		elseif (($lang -eq "PHP")) {
			gum spin --title="$prettyTitle composer..." -- composer create-project --prefer-dist $Template $ProjectName
		}

		elseif ($t.isTemplate -eq $True) {
			gum spin --title="$prettyTitle github repository template..." -- gh repo create $ProjectName --private --template $Template --clone
		}

		else {
			gum spin --title="Cloning into $Template repository to create new project..." -- git clone "https://github.com/$Template" $ProjectName
			Remove-Item "./$ProjectName/.git" -Force -Recurse -ErrorAction SilentlyContinue
		}
	} else { Write-Host "Skipped process..." -ForegroundColor DarkGray; break }
}
