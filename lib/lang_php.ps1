function Initialize-ProjectPHP {
	param (
		[string]$ProjectRoot,
		[string]$ProjectName,
		[switch]$WebFramework
	)

	foreach ($file in $(Get-ChildItem -Path "$PSScriptRoot/frameworks/php/*" -Include *.ps1 -Recurse)) {
		. "$file"
	}
	Remove-Variable file

	Set-Location "$ProjectRoot"

	$langgitignore = "php-cs-fixer"
	if ($WebFramework) {
		$phpFrameworks = (gum choose --limit=1 --header="Choose a Project Framework:" "None" "Laravel" "Symfony" "CodeIgniter" "Zend Framework/Laminas Project" "Yii Framework" "CakePHP" "Slim").Trim()
		switch ($phpFrameworks) {
			"Laravel" {
				$langgitignore += ",laravel"
				$useSail = Write-YesNoQuestion "Install Laravel Sail for your current location?"
				if ($useSail.ToUpper() -eq 'Y') { $Sail = $True } else { $Sail = $False }
				Initialize-ProjectPHP-Laravel -Name $ProjectName -Sail:$Sail
				Write-LinkInformation "https://laravel.com/docs/11.x"
			}

			"Symfony" {
				$langgitignore += ",symfony"
				$useWebApp = Write-YesNoQuestion "Build a traditional web application with Symfony?"
				if ($useWebApp.ToUpper() -eq 'Y') { $WebApp = $True } else { $WebApp = $False }
				Initialize-ProjectPHP-Symfony -Name "$ProjectName" -WebApp:$WebApp
				Write-LinkInformation "https://symfony.com/doc/current/index.html"
			}

			"CodeIgniter" {
				$langgitignore += ",codeigniter"
				Initialize-ProjectPHP-CodeIgniter -Name $ProjectName
				Write-LinkInformation "https://codeigniter.com/user_guide"
			}

			"Zend Framework/Laminas Project" {
				$langgitignore += ",zendframework"
				Initialize-ProjectPHP-Laminas -Name $ProjectName
				Write-LinkInformation "https://docs.laminas.dev/tutorials/"
			}

			"Yii Framework" {
				$langgitignore += ",yii,yii2"
				Initialize-ProjectPHP-Yii -Name $ProjectName
				Write-LinkInformation "https://www.yiiframework.com/doc/guide/2.0/en"
			}

			"CakePHP" {
				$langgitignore += ",cakephp2,cakephp,cakephp3"
				Initialize-ProjectPHP-CakePHP -Name $ProjectName
				Write-LinkInformation "https://book.cakephp.org/5/en/index.html"
			}

			"Slim" {
				Initialize-ProjectPHP-Slim -Name $ProjectName
				Write-LinkInformation "https://www.slimframework.com/docs/v4/"
			}

			Default { break }
		}

		Add-ProjectGitignore -ProjectPath "$ProjectRoot/$ProjectName" -ProjectFramework "$langgitignore"
		Remove-Variable langgitignore

		Add-License -ProjectRoot $ProjectRoot -ProjectName $ProjectName
		Add-Readme -ProjectRoot $ProjectRoot -ProjectName $ProjectName
	}
}
