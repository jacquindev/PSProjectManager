function CheckGitHubRepoExists {
	param ([string]$Repo)

	git ls-remote "https://github.com/$Repo" >$null 2>&1

	if ($LASTEXITCODE -eq 0) { return $True }
	else { return $False }
}

function CheckGitHubRepoContent {
	param ([string]$Repo, [string]$File)

	if (gh api --jq '.[].name' /repos/$Repo/contents | Where-Object { $_ -match "$File" }) { return $True }
	else { return $False }
}

function CheckNuGetPackageExists {
	param ([string]$Package)

	if (((dotnet package search $Package --take 1 --format json | ConvertFrom-Json).searchResult.packages.id) -match "$Package") { return $True }
	else { return $False }
}
