function Initialize-ProjectRust {
	param ([string]$ProjectRoot, [string]$ProjectName, [switch]$WebFramework)

	if (!(Get-Command cargo-binstall -ErrorAction SilentlyContinue)) {
		Set-ExecutionPolicy Unrestricted -Scope Process
		Invoke-Expression (Invoke-WebRequest "https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.ps1").Content
		Set-PSDebug -Off
	}

	Set-Location "$ProjectRoot"

	if ($WebFramework) {
		$webFrameworkType = (gum choose --limit=1 --header="Choose FrontEnd / BackEnd web framework type:" "Frontend" "Backend").Trim()

		switch ($webFrameworkType) {
			"Frontend" {
				$rustFrontends = (gum choose --limit=1 --header="Choose a Frontend Web Framework:" "Wasm" "Yew" "Perseus").Trim()
				switch ($rustFrontends) {
					"Wasm" {
						if (!(Get-Command 'wasm-pack' -ErrorAction SilentlyContinue)) { cargo-binstall --no-confirm wasm-pack }
						gum spin --title="Creating new project with wasm-pack..." -- wasm-pack new $ProjectName
						Set-Location "./$ProjectName"
						gum spin --title="Building project webpack..." -- wasm-pack build --target web
						Write-LinkInformation "https://rustwasm.github.io/docs/wasm-pack/"
					}

					"Yew" {
						$generate = Get-Command 'cargo-generate' -ErrorAction SilentlyContinue
						$trunk = Get-Command 'trunk' -ErrorAction SilentlyContinue
						if (!$generate) { gum spin --title="Installing cargo-generate..." -- cargo-binstall --no-confirm cargo-generate }
						if (!$trunk) { gum spin --title="Installing trunk..." -- cargo-binstall --no-confirm trunk }

						cargo generate --git "https://github.com/yewstack/yew-trunk-minimal-template" --name $ProjectName
						Set-Location "./$ProjectName"
						Write-LinkInformation "https://yew.rs/docs/getting-started/introduction"
					}

					"Perseus" {
						$perseus = Get-Command perseus -ErrorAction SilentlyContinue
						if (!$perseus) { gum spin --title="Installing perseus-cli..." -- cargo-binstall --no-confirm perseus-cli }
						perseus new $ProjectName
						Set-Location "./$ProjectName"
					}
				}
			}
			"Backend" {
				$rustBackends = (gum choose --limit=1 --header="Choose a Backend Web Framework:" "Actix Web" "Axum" "Gotham" "Rocket" "Rouille" "Tide" "Thruster" "Warp").Trim()
				switch ($rustBackends) {
					"Actix Web" {
						cargo new $ProjectName
						Set-Location "./$ProjectName"
						gum spin --title="Adding Actix Web to dependencies list..." -- cargo add actix-web
						Remove-Item "./src/main.rs" -Force -ErrorAction SilentlyContinue
						Copy-Item -Path "$PSScriptRoot/../templates/rust_actix.rs" -Destination "./src/main.rs" -ErrorAction SilentlyContinue
						Write-LinkInformation ""
					}

					"Axum" {
						cargo new $ProjectName
						Set-Location "./$ProjectName"
						gum spin --title="Adding Axum to dependencies list..." -- cargo add axum
						gum spin --title="Adding Tokio to dependencies list..." -- cargo add tokio --features="full"
						Remove-Item "./src/main.rs" -Force -ErrorAction SilentlyContinue
						Copy-Item -Path "$PSScriptRoot/../templates/rust_axum.rs" -Destination "./src/main.rs" -ErrorAction SilentlyContinue
						Write-LinkInformation "https://docs.rs/axum/latest/axum/"
					}

					"Gotham" {
						cargo new $ProjectName
						Set-Location "./$ProjectName"
						gum spin --title="Adding Gotham to dependencies list..." -- cargo add gotham
						Remove-Item "./src/main.rs" -Force -ErrorAction SilentlyContinue
						Copy-Item -Path "$PSScriptRoot/../templates/rust_gotham.rs" -Destination "./src/main.rs" -ErrorAction SilentlyContinue
						Write-LinkInformation "https://gotham.rs/"
					}

					"Rocket" {
						cargo new $ProjectName --bin
						Set-Location "./$ProjectName"
						gum spin --title="Adding Rocket to dependencies list..." -- cargo add rocket
						Remove-Item "./src/main.rs" -Force -ErrorAction SilentlyContinue
						Copy-Item -Path "$PSScriptRoot/../templates/rust_rocket.rs" -Destination "./src/main.rs" -ErrorAction SilentlyContinue
						Write-LinkInformation "https://rocket.rs/guide/v0.5/"
					}

					"Rouille" {
						cargo new $ProjectName
						Set-Location "./$ProjectName"
						gum spin --title="Adding Rouille to dependencies list..." -- cargo add rouille
						Remove-Item "./src/main.rs" -Force -ErrorAction SilentlyContinue
						Copy-Item -Path "$PSScriptRoot/../templates/rust_rouille.rs" -Destination "./src/main.rs" -ErrorAction SilentlyContinue
						Write-LinkInformation "https://docs.rs/rouille/latest/rouille/"
					}

					"Tide" {
						cargo new $ProjectName
						Set-Location "./$ProjectName"
						gum spin --title="Adding Tide to dependencies list..." -- cargo add tide
						gum spin --title="Adding AsyncStd to dependencies list..." -- cargo add async-std --features="attributes"
						gum spin --title="Adding Serde to dependencies list..." -- cargo add serde --features="derive"
						Remove-Item "./src/main.rs" -Force -ErrorAction SilentlyContinue
						Copy-Item -Path "$PSScriptRoot/../templates/rust_tide.rs" -Destination "./src/main.rs" -ErrorAction SilentlyContinue
						Write-LinkInformation "https://docs.rs/tide/latest/tide/"
					}

					"Thruster" {
						cargo new $ProjectName --bin
						Set-Location "./$ProjectName"
						gum spin --title="Adding Thruster to dependencies list..." -- cargo add thruster --features="hyper_server"
						gum spin --title="Adding Tokio to dependencies list..." -- cargo add tokio --features="rt,rt-multi-thread,macros"
						gum spin --title="Adding EnvLogger to dependencies list..." -- cargo add env_logger
						gum spin --title="Adding Log to dependencies list..." -- cargo add log
						Remove-Item "./src/main.rs" -Force -ErrorAction SilentlyContinue
						Copy-Item -Path "$PSScriptRoot/../templates/rust_thruster.rs" -Destination "./src/main.rs" -ErrorAction SilentlyContinue
						Write-LinkInformation "https://mertz.gitbook.io/thruster"
					}

					"Warp" {
						cargo new $ProjectName
						Set-Location "./$ProjectName"
						gum spin --title="Adding Warp to dependencies list..." -- cargo add warp
						gum spin --title="Adding Tokio to dependencies list..." -- cargo add tokio --features="full"
						Remove-Item "./src/main.rs" -Force -ErrorAction SilentlyContinue
						Copy-Item -Path "$PSScriptRoot/../templates/rust_warp.rs" -Destination "./src/main.rs" -ErrorAction SilentlyContinue
						Write-LinkInformation "https://docs.rs/warp/latest/warp/"
					}
				}
			}
		}
	} else {
		cargo new $ProjectName
		Set-Location "./$ProjectName"
	}
}
