function Initialize-ProjectDotnet {
  param ([string]$ProjectRoot, [string]$ProjectName, [switch]$Template)

  # Set working directory
  Set-Location $PSScriptRoot
  [Environment]::CurrentDirectory = $PSScriptRoot

  Set-Location "$ProjectRoot"

  New-Item "$ProjectName" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
  Set-Location "./$ProjectName"

  $langgitignore = "dotnetcore"

  if ($Template) {
    $dotnetLanguage = (gum choose --limit=1 --header="Choose a DotNet Project Language:" "C#" "F#" "VB")
    $whichTemplateType = $(Write-Host "Use built-in templates (y) or NuGet.org templates (n)? " -ForegroundColor Cyan -NoNewline; Read-Host)
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

    ''
    Write-Host "Find more templates at " -NoNewline
    Write-Host "https://www.nuget.org/packages" -ForegroundColor Blue

    Add-ProjectGitignore -ProjectPath "$ProjectRoot/$ProjectName" -ProjectFramework "$langgitignore"
    Remove-Variable langgitignore

    Add-License -ProjectRoot $ProjectRoot -ProjectName $ProjectName
    Add-Readme -ProjectRoot $ProjectRoot -ProjectName $ProjectName
  }
}
