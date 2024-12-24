function Initialize-ProjectDotnet {
  param ([string]$ProjectRoot, [string]$ProjectName, [switch]$Template, [switch]$Tool, [switch]$DB)

  # Set working directory
  Set-Location $PSScriptRoot
  [Environment]::CurrentDirectory = $PSScriptRoot

  Set-Location "$ProjectRoot"

  New-Item "$ProjectName" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
  Set-Location "./$ProjectName"

  $langgitignore = "dotnetcore"

  if ($Template) {
    $dotnetLanguage = (gum choose --limit=1 --header="Choose a DotNet Project Language:" "C#" "F#" "VB")
    $whichTemplateType = Write-YesNoQuestion "Use built-in templates (Y) or NuGet.org templates (n)?"
    if ($whichTemplateType.ToUpper() -eq 'Y') {
      switch ($dotnetLanguage) {
        "C#" {
          $langgitignore += ",csharp"
          $templates = Get-Content "$PSScriptRoot/frameworks/dotnet/dotnet_csharp_builtin_templates.json" | ConvertFrom-Json
          $templates = $templates.templates

          $selectTemplate = (gum choose --limit=1 --header="Choose DotNet Project Template:" $($templates.name))
          $templateShortName = $templates | Where-Object name -eq "$selectTemplate"
          $templateShortName = $templateShortName.short_name
          gum spin --title="Adding template $selectTemplate to the project..." -- dotnet new $templateShortName --force
        }

        "F#" {
          $langgitignore += ",fsharp"
          $templates = Get-Content "$PSScriptRoot/frameworks/dotnet/dotnet_fsharp_builtin_templates.json" | ConvertFrom-Json
          $templates = $templates.templates

          $selectTemplate = (gum choose --limit=1 --header="Choose DotNet Project Template:" $($templates.name))
          $templateShortName = $templates | Where-Object name -eq "$selectTemplate"
          $templateShortName = $templateShortName.short_name
          gum spin --title="Adding template $selectTemplate to the project..." -- dotnet new $templateShortName --force
        }

        "VB" {
          $langgitignore += ",visualbasic"
          $templates = Get-Content "$PSScriptRoot/frameworks/dotnet/dotnet_vb_builtin_templates.json" | ConvertFrom-Json
          $templates = $templates.templates

          $selectTemplate = (gum choose --limit=1 --header="Choose DotNet Project Template:" $($templates.name))
          $templateShortName = $templates | Where-Object name -eq "$selectTemplate"
          $templateShortName = $templateShortName.short_name
          gum spin --title="Adding template $selectTemplate to the project..." -- dotnet new $templateShortName --force
        }
      }
    } else {
      switch ($dotnetLanguage) {
        "C#" {
          $langgitignore += ",csharp"
          $templates = Get-Content "$PSScriptRoot/frameworks/dotnet/dotnet_csharp_nuget_templates.json" | ConvertFrom-Json

          $installPackage = (gum choose --limit=1 --header="Choose A Template Package:" $($templates.packages.nuget_name)).Trim()

          if (!(dotnet new uninstall | Select-String "$installPackage")) {
            gum spin --title="Installing $installPackage" -- dotnet new install $installPackage
          }

          $newtemplate = $templates.packages | Where-Object nuget_name -eq "$installPackage"
          $url = $newtemplate.url
          $newtemplate = $newtemplate.templates.short_name
          $selectTemplate = (gum choose --limit=1 --header="Choose A Project Template:" $newtemplate).Trim()
          gum spin --title="Add template $selectTemplate to the project..." -- dotnet new $selectTemplate --force
          Write-LinkInformation "$url"
        }

        "F#" {
          $langgitignore += ",fsharp"
          $templates = Get-Content "$PSScriptRoot/frameworks/dotnet/dotnet_fsharp_nuget_templates.json" | ConvertFrom-Json

          $installPackage = (gum choose --limit=1 --header="Choose A Template Package:" $($templates.packages.nuget_name)).Trim()

          if (!(dotnet new uninstall | Select-String "$installPackage")) {
            gum spin --title="Installing $installPackage" -- dotnet new install $installPackage
          }

          $newtemplate = $templates.packages | Where-Object nuget_name -eq "$installPackage"
          $url = $newtemplate.url
          $newtemplate = $newtemplate.templates.short_name
          $selectTemplate = (gum choose --limit=1 --header="Choose A Project Template:" $newtemplate).Trim()
          gum spin --title="Add template $selectTemplate to the project..." -- dotnet new $selectTemplate --force
          Write-LinkInformation "$url"
        }

        "VB" {
          $langgitignore += ",visualbasic"
          $templates = Get-Content "$PSScriptRoot/frameworks/dotnet/dotnet_vb_nuget_templates.json" | ConvertFrom-Json

          $installPackage = (gum choose --limit=1 --header="Choose A Template Package:" $($templates.packages.nuget_name)).Trim()

          if (!(dotnet new uninstall | Select-String "$installPackage")) {
            gum spin --title="Installing $installPackage" -- dotnet new install $installPackage
          }

          $newtemplate = $templates.packages | Where-Object nuget_name -eq "$installPackage"
          $url = $newtemplate.url
          $newtemplate = $newtemplate.templates.short_name
          $selectTemplate = (gum choose --limit=1 --header="Choose A Project Template:" $newtemplate).Trim()
          gum spin --title="Add template $selectTemplate to the project..." -- dotnet new $selectTemplate --force
          Write-LinkInformation "$url"
        }
      }
    }

    Write-LinkInformation "https://www.nuget.org/packages"
  }

  if ($Tool) {
    $tools = @()
    $dotnetTools = (gum choose --no-limit --header="Choose DotNet Tools for your project:" "Cake" "CSharpier" "GitVersion" "coverlet.console" "dotnet-counters" "dotnet-coverage" "dotnet-dump" "dotnet-ef" "dotnet-gcdump" "dotnet-interactive" "dotnet-outdated-tool" "dotnet-reportgenerator-globaltool" "dotnet-script" "dotnet-serve" "dotnet-trace" "trx2junit" "wix").Trim()
    switch ($dotnetTools) {
      { $_ -match "Cake" } { $tools += @('Cake.Tool') }
      { $_ -match "CSharpier" } { $tools += @('CSharpier') }
      { $_ -match "GitVersion" } { $tools += @('GitVersion.Tool') }
      { $_ -match "coverlet.console" } { $tools += @('coverlet.console') }
      { $_ -match "dotnet-counters" } { $tools += @('dotnet-counters') }
      { $_ -match "dotnet-coverage" } { $tools += @('dotnet-coverage') }
      { $_ -match "dotnet-dump" } { $tools += @('dotnet-dump') }
      { $_ -match "dotnet-ef" } { $tools += @('dotnet-ef') }
      { $_ -match "dotnet-gcdump" } { $tools += @('dotnet-gcdump') }
      { $_ -match "dotnet-interactive" } { $tools += @('dotnet-interactive') }
      { $_ -match "dotnet-outdated-tool" } { $tools += @('dotnet-outdated-tool') }
      { $_ -match "dotnet-reportgenerator-globaltool" } { $tools += @('dotnet-reportgenerator-globaltool') }
      { $_ -match "dotnet-script" } { $tools += @('dotnet-script') }
      { $_ -match "dotnet-serve" } { $tools += @('dotnet-serve') }
      { $_ -match "dotnet-trace" } { $tools += @('dotnet-trace') }
      { $_ -match "trx2junit" } { $tools += @('trx2junit') }
      { $_ -match "wix" } { $tools += @('wix') }
    }

    $globalOrLocal = Write-YesNoQuestion "Install Tools Globally (Y) or Locally (n)?"
    if ($globalOrLocal.ToUpper() -eq 'Y') {
      foreach ($t in $tools) {
        $prettyTool = (gum style --italic --foreground="#eba0ac" "$t")
        if (!(dotnet tool list --global | Select-String "$t" )) { gum spin --title="Install DotNet Tool: $prettyTool globally..." -- dotnet tool install --global $t }
      }
    } else {
      if (!(Test-Path "./.config/dotnet-tools.json" -PathType Leaf)) { dotnet new tool-manifest }
      foreach ($t in $tools) {
        $prettyTool = (gum style --italic --foreground="#eba0ac" "$t")
        if (!(dotnet tool list --local | Select-String "$t")) { gum spin --title="Installing DotNet Tool: $prettyTool locally..." -- dotnet tool install --local $t }
      }
    }
  }

  if ($DB) {
    $langgitignore += ",database"
    if (!(Test-Path "./.config/dotnet-tools.json" -PathType Leaf)) { dotnet new tool-manifest }

    $prettyName = (gum style --bold --foreground="#fab387" "SqlPackage")
    if (!(dotnet tool list microsoft.sqlpackage)) {
      gum spin --title="Installing DotNet Tool: $prettyName to your local project..." -- dotnet tool install --local microsoft.sqlpackage
    }

    $prettyCmd1 = (gum style --italic --bold --foreground="#a6e3a1" "dotnet tool run sqlpackage")
    $prettyCmd2 = (gum style --italic --bold --foreground="#a6e3a1" "dotnet sqlpackage")
    Write-Host "Invoke the tool $prettyName using the commands: $prettyCmd1 or $prettyCmd2"
    Remove-Variable prettyName, prettyCmd1, prettyCmd2

    if (!(dotnet new uninstall | Select-String "MSBuild.Sdk.SqlProj.Templates")) {
      gum spin --title="Installing SQL Templates..." -- dotnet new install MSBuild.Sdk.SqlProj.Templates
      Write-LinkInformation "https://github.com/rr-wfm/MSBuild.Sdk.SqlProj"
    }

    $promptDBitem = Write-YesNoQuestion "Create Database Object?"
    if ($promptDBitem.ToUpper() -eq 'Y') {
      $dbName = Write-PromptInput -Prompt "Input Database's Name" -Example "MyDatabase"
      $dbObject = (gum choose --limit=1 --header="Choose A Database Object:" "table" "sproc" "inlinefunc" "tablefunc" "scalarfunc" "uddt" "udtt").Trim()

      dotnet new $dbObject -n $dbName

      Write-Host "To view templates available, use the command:"
      Write-Host "dotnet new list --language='SQL' --author='MSBuild.Sdk.SqlProj'" -ForegroundColor Blue
      Write-Host "You can create more database objects using the command:"
      Write-Host "dotnet new <template name> -n <database name> [-s <schema name>]" -ForegroundColor Blue
      ''
    }
  }

  Add-ProjectGitignore -ProjectPath "$ProjectRoot/$ProjectName" -ProjectFramework "$langgitignore"
  Remove-Variable langgitignore

  Add-License -ProjectRoot $ProjectRoot -ProjectName $ProjectName
  Add-Readme -ProjectRoot $ProjectRoot -ProjectName $ProjectName
}
