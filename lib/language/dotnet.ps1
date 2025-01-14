function Initialize-ProjectDotnet {
	param ([string]$ProjectName, [switch]$AddTool, [switch]$DB, [switch]$Template)

	if ($Template) {
		$myTmpl = Write-PromptInput "Input .NET template name" "wpf"

		dotnet new list "$myTmpl" >$null 2>&1

		if ($LASTEXITCODE -eq 0) {
			$showList = Write-YesNo "Show list $myTmpl's evailable templates?" -y
			if ($showList.ToUpper() -ne 'N') {
				dotnet new list $myTmpl --columns-all | Select-Object -Skip 1
			}
		} else {
			Write-Warning "Template $myTmpl is not available locally."
			Write-Host "Searching for online NuGet packages..." -ForegroundColor DarkGray

			$cmd = dotnet new search $myTmpl --columns-all | Select-Object -Skip 3
			$cmd[0..($cmd.count - 6)]

			if ($LASTEXITCODE -eq 0) {
				do {
					$pkgName = Write-PromptInput "Input template's package name to install" "Microsoft.Identity.Web.ProjectTemplates"
					if (!(CheckNuGetPackageExists -Package "$pkgName")) {
						Write-Warning "NuGet package $pkgName not found. Please try again."
					}
				} until (CheckNuGetPackageExists -Package "$pkgName")

				gum spin --title="Installing $pkgName..." -- dotnet new install "$pkgName"
			} else { Write-Error "An error occurred. Exiting..."; break }
		}

		$newTmpl = Write-PromptInput "Input the exact short name of the template" "webapp2"
		dotnet new "$newTmpl" --output $ProjectName

		if (Test-Path "./$ProjectName/global.json" -PathType Leaf) {
			$globalJson = Get-Content "./$ProjectName/global.json" | ConvertFrom-Json
			$sdkVersion = $globalJson.sdk.version
			if (!(dotnet --list-sdks | Select-String "$sdkVersion")) {
				Write-Host "Updating global.json to match an installed SDK..."
				$installedSDKs = gum choose --header="Choose a version of .NET SDK:" $(dotnet --list-sdks)
				$newSdkVersion = $installedSDKs.Split(' ')[0]
				$globalJson.sdk.version = "$newSdkVersion"
				$globalJson | ConvertTo-Json -Depth 100 | Set-Content -Path "./$ProjectName/global.json"

				if ($?) { Write-Host "Updated global.json SDK version to $newSdkVersion." }
				else { Write-Error "Failed to update global.json file." }
				''
			}
		}
	}

	New-DirectoryIfNotExist $ProjectName
	Set-Location "./$ProjectName"

	if ($AddTool) {
		$autoOrManual = Write-YesNo "Choose .NET tools from existing list (Y) or manually (n)?" -y
		''
		if ($autoOrManual.ToUpper() -eq 'N') {
			$pkgNames = Write-PromptInput "Input .NET package name" "dotnet-ef dotnet-dump" "separated with SPACE"
			$pkgNames = $pkgNames.Split(' ')
		} else {
			$toolList = (Get-Content "$PSScriptRoot/../../data/dotnet/dotnet_tools.json" | ConvertFrom-Json).packages
			$toolNames = $toolList.id

			$pkgNames = gum choose --no-limit --header="Choose .NET tools:" $toolNames
		}

		$localOrGlobal = Write-YesNo "Install chosen .NET tools globally (Y) or locally (n)?" -y
		if ($localOrGlobal.ToUpper() -eq 'N') {
			if (!(Test-Path "./.config/dotnet-tools.json" -PathType Leaf)) { dotnet new tool-manifest }
			foreach ($t in $pkgNames) {
				$prettyTool = (gum style --italic --foreground="#eba0ac" "$t")
				if (!(dotnet tool list --local | Select-String "$t")) { gum spin --show-output --title="Install DotNet Tool: $prettyTool locally..." -- dotnet tool install --local $t }
			}
		} else {
			foreach ($t in $pkgNames) {
				$prettyTool = (gum style --italic --foreground="#eba0ac" "$t")
				if (!(dotnet tool list --global | Select-String "$t")) { gum spin --show-output --title="Install DotNet Tool: $prettyTool globally..." -- dotnet tool install --global $t }
			}
		}
	}

	if ($DB) {
		if (!(dotnet new uninstall | Select-String "MSBuild.Sdk.SqlProj.Templates")) {	gum spin --title="Installing SQL Templates..." -- dotnet new install MSBuild.Sdk.SqlProj.Templates }
		if (!(Test-Path "./config/dotnet-tools.json" -PathType Leaf)) { gum spin --title="Adding manifest file for local tools..." -- dotnet new tool-manifest }
		if (!(dotnet tool list --local Microsoft.SqlPackage)) { gum spin --show-output --title="Installing .NET Tool: Microsoft.SqlPackage to your local project..." -- dotnet tool install --local Micrsoft.SqlPackage }

		$sqlProject = Write-YesNo "Create a SQL Server Database project?" -n
		if ($sqlProject.ToUpper() -eq 'Y') {
			if (Test-Path "./*.csproj" -PathType Leaf) {
				$nameofdbproj = Write-PromptInput "Specify the name of SQL project" "database"
				dotnet new sqlproj -n "$nameofdbproj"
			} else { dotnet new sqlproj }
		}
		''
		$addObject = Write-YesNo "Add SQL Database object?" -y
		if ($addObject.ToUpper() -ne 'N') {
			$dbObjList = Get-Content "$PSScriptRoot/../../data/dotnet/dotnet_database_object.txt"
			$dbObj = gum choose --no-limit --header="Choose a database object:" $dbObjList
			$objCmds = @()
			switch ($dbObj) {
				{ $_ -match "$($dbObjList[0])" } {
					$dbName0 = Write-PromptInput "Input name for Database Table" "MyDatabaseTable"
					if (!(Test-Path "./$nameofdbproj" -PathType Container)) { $objCmds += ("dotnet new table --name $dbName0 --output ./$dbName0") }
					else { $objCmds += ("dotnet new table --name $dbName0 --output ./$nameofdbproj") }
				}
				{ $_ -match "$($dbObjList[1])" } {
					$dbName1 = Write-PromptInput "Input name for Database View" "MyDatabaseView"
					if (!(Test-Path "./$nameofdbproj" -PathType Container)) { $objCmds += ("dotnet new view --name $dbName1 --output ./$dbName1") }
					else { $objCmds += ("dotnet new view --name $dbName1 --output ./$nameofdbproj") }
				}
				{ $_ -match "$($dbObjList[2])" } {
					$dbName2 = Write-PromptInput "Input name for Inline Function" "Inline function"
					if (!(Test-Path "./$nameofdbproj" -PathType Container)) { $objCmds += ("dotnet new inlinefunc --name $dbName2 --output ./$dbName2") }
					else { $objCmds += ("dotnet new inlinefunc --name $dbName2 --output ./$nameofdbproj") }
				}
				{ $_ -match "$($dbObjList[3])" } {
					$dbName3 = Write-PromptInput "Input name for Scalar Function" "MyScalarFunction"
					if (!(Test-Path "./$nameofdbproj" -PathType Container)) { $objCmds += ("dotnet new scalarfunc --name $dbName3 --output ./$dbName3") }
					else { $objCmds += ("dotnet new scalarfunc --name $dbName3 --output ./$nameofdbproj") }
				}
				{ $_ -match "$($dbObjList[4])" } {
					$dbName4 = Write-PromptInput "Input name for Stored procedure" "MyStoredProcedure"
					if (!(Test-Path "./$nameofdbproj" -PathType Container)) { $objCmds += ("dotnet new sproc --name $dbName4 --output ./$dbName4") }
					else { $objCmds += ("dotnet new sproc --name $dbName4 --output ./$nameofdbproj") }
				}
				{ $_ -match "$($dbObjList[5])" } {
					$dbName5 = Write-PromptInput "Input name for Table-valued Function" "MyTableValuedFunction"
					if (!(Test-Path "./$nameofdbproj" -PathType Container)) { $objCmds += ("dotnet new tablefunc --name $dbName5 --output ./$dbName5") }
					else { $objCmds += ("dotnet new tablefunc --name $dbName5 --output ./$nameofdbproj") }
				}
				{ $_ -match "$($dbObjList[6])" } {
					$dbName6 = Write-PromptInput "Input name for User-defined data type" "MyUserDefinedDataType"
					if (!(Test-Path "./$nameofdbproj" -PathType Container)) { $objCmds += ("dotnet new uddt --name $dbName6 --output ./$dbName6") }
					else { $objCmds += ("dotnet new uddt --name $dbName6 --output ./$nameofdbproj") }
				}
				{ $_ -match "$($dbObjList[7])" } {
					$dbName7 = Write-PromptInput "Input name for User-defined table type" "MyUserDefinedTableType"
					if (!(Test-Path "./$nameofdbproj" -PathType Container)) { $objCmds += ("dotnet new udtt --name $dbName7 --output ./$dbName7") }
					else { $objCmds += ("dotnet new udtt --name $dbName7 --output ./$nameofdbproj") }
				}
			}

			foreach ($c in $objCmds) { Invoke-Expression $c }
		}
	}

	if (!(Test-Path "./.gitignore" -PathType Leaf)) { gum spin --title="Adding .gitignore" --show-error -- dotnet new gitignore }
	if (!(Test-Path "./.editorconfig" -PathType Leaf)) { gum spin --title="Adding .editorconfig" --show-error -- dotnet new editorconfig }
	if (!(Test-Path "./global.json" -PathType Leaf)) { gum spin --title="Adding global.json" --show-error -- dotnet new globaljson }
}
