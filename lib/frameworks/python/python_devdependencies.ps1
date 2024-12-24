

function Add-PythonDevDependencies {
	param ([string]$ProjectManager, [array]$List)

	. "G:\projects\PSProjectManager\lib\utils.ps1"
	$addDevDependencies = Write-YesNoQuestion "Add Python DevDependencies from existing list (Y) or manually (n)?"

	if ($addDevDependencies.ToUpper() -eq 'Y') {
		$devList = Get-Content "$PSScriptRoot/lists/python_devdependencies.txt"
		$chooseDev = gum choose --no-limit --header="Choose dev dependencies to install:" $devList
		$List = $chooseDev
	} else {
		$chooseDev = Write-PromptInput -Prompt "Input your list of dev dependencies" -Example "httpie wheel tox pytest"
		$List = $chooseDev.Split(' ')
	}

	foreach ($pkg in $List) {
		$prettyPkg = gum style --italic --bold --foreground="#eba0ac" "$pkg"
		switch ($ProjectManager) {
			"pdm" { gum spin --title="Adding Dev Dependency: $prettyPkg ..." -- pdm add --dev $pkg }
			"poetry" { gum spin --title="Adding Dev Dependency: $prettyPkg ..." -- poetry add $pkg --group=dev }
			"pipenv" { gum spin --title="Adding Dev Dependency: $prettyPkg ..." -- pipenv install --dev $pkg }
			"rye" { gum spin --title="Adding Dev Dependency: $prettyPkg ..." -- rye add $pkg --dev }
			"uv" { gum spin --title="Adding Dev Dependency: $prettyPkg ..." -- uv add $pkg --dev }
		}
	}
}
