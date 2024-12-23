function Add-License {
	param ([string]$ProjectRoot, [string]$ProjectName)

	if (!(gh extension list | Select-String "Shresht7/gh-license")) {
		gum spin --title="Installing GitHub CLI extension: Shresht7/gh-license ..." -- gh extension install Shresht7/gh-license
	}

	if (!(Test-Path "$ProjectRoot/$ProjectName/LICENSE*" -PathType Leaf)) {
		$promptLicense = $(Write-Host "Add LICENSE for your project? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
		if ($promptLicense.ToUpper() -eq 'Y') {
			$License = (gum choose --header="Choose a License:" "AGPL-3.0" "Apache-2.0" "BSD-2-Clause" "BSD-3-Clause" "BSL-1.0" "CC0-1.0" "EPL-2.0" "GPL-2.0" "GPL-3.0" "LGPL-2.1" "MIT" "MPL-2.0" "Unlicense").Trim()
			Set-Location "$ProjectRoot/$ProjectName"
			gh license create $License --author "$(git config user.name)"
			$prettyLicense = (gum style --bold --foreground="#a6e3a1" "$License")
			Write-Host "Add LICENSE $prettyLicense for your project."
		}
	}
}
