foreach ($file in $(Get-ChildItem -Path "$PSScriptRoot/frameworks/php/*" -Include *.ps1 -Recurse)) {
	. "$file"
}
Remove-Variable file

function Initialize-ProjectPHP {
	param (
		[string]$ProjectRoot,
		[string]$ProjectName,
		[switch]$WebFramework
	)

	Set-Location "$ProjectRoot"

	if ($WebFramework) {
		$phpFrameworks = (gum choose --limit=1 --header="Choose a Project Framework:" "None" "Laravel" "Symfony" "CodeIgniter" "Zend Framework/Laminas Project" "Yii Framework" "CakePHP" "Slim").Trim()
		switch ($phpFrameworks) {
			"Laravel" {
				$useSail = $(Write-Host "Install Laravel Sail for your current location? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($useSail.ToUpper() -eq 'Y') { $Sail = $True } else { $Sail = $False }
				Initialize-ProjectPHP-Laravel -Name $ProjectName -Sail:$Sail
				Write-LinkInformation "https://laravel.com/docs/11.x"
			}

			"Symfony" {
				$useWebApp = $(Write-Host "Build a traditional web application with Symfony? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($useWebApp.ToUpper() -eq 'Y') { $WebApp = $True } else { $WebApp = $False }
				Initialize-ProjectPHP-Symfony -Name "$ProjectName" -WebApp:$WebApp
				Write-LinkInformation "https://symfony.com/doc/current/index.html"
			}

			"CodeIgniter" {
				Initialize-ProjectPHP-CodeIgniter -Name $ProjectName
				Write-LinkInformation "https://codeigniter.com/user_guide"
			}

			"Zend Framework/Laminas Project" {
				Initialize-ProjectPHP-Laminas -Name $ProjectName
				Write-LinkInformation "https://docs.laminas.dev/tutorials/"
			}

			"Yii Framework" {
				Initialize-ProjectPHP-Yii -Name $ProjectName
				Write-LinkInformation "https://www.yiiframework.com/doc/guide/2.0/en"
			}

			"CakePHP" {
				Initialize-ProjectPHP-CakePHP -Name $ProjectName
				Write-LinkInformation "https://book.cakephp.org/5/en/index.html"
			}

			"Slim" {
				Initialize-ProjectPHP-Slim -Name $ProjectName
				Write-LinkInformation "https://www.slimframework.com/docs/v4/"
			}

			Default { break }
		}
	}
}
