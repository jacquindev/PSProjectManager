function Initialize-ProjectPython-Django {
	param ([string]$Name, [string]$ProjectManager, [switch]$Addons)

	switch -regex ($Name) {
		"^[a-z]+(-[a-z]+)*$" { $subProjectName = (Convert-NamingConventionCase -inputString "$Name" -snake).Trim() }
		"^[a-z]+(?:_[a-z]+)*$" { $subProjectName = "$Name" }
		"^[A-Z][a-z]+(?:[A-Z][a-z]+)*$" {	$subProjectName = $Name.ToLower() }
	}

	if ($Addons) {
		Write-Host "DJANGO ADDONS:" -ForegroundColor Blue
		Write-Host "--------------" -ForegroundColor Blue

		$packages = @()
		$djangoAddons = (gum choose --no-limit --header="Choose Django Addons:" "apitally" "django-admin-interface" "django-admin-honeypot" "django-admin-sortable2" "django-allauth" "django-braces" "django-cachalot" "django-cacheops" "django-celery-beat" "django-choices-field" "django-cleanup" "django-components" "django-compressor" "django-configurations" "django-constance" "django-cors-headers" "django-cms" "django-crispy-forms" "django-elasticsearch-dsl" "django-environ" "django-extensions" "django-extra-views" "django-filter" "django-grappelli" "django-haystack" "django-hijack" "django-imagekit" "django-impersonate" "django-import-export" "django-jazzmin" "django-modeltranslation" "django-money" "django-ninja" "django-phonenumber-field" "django-polymorphic" "django-prometheus" "django-silk" "django-simple-history" "django-sockpuppet" "django-split-settings" "django-sql-explorer" "django-storages" "django-summernote" "django-rest-framework" "django-rest-knox" "djangorestframework-simplejwt" "dj-database-url" "dj-rest-auth" "djoser" "djongo" "django-redis" "django-reversion" "django-rosetta" "django-rq" "django-tables2" "django-taggit" "django-tastypie" "django-tinymce" "django-typer" "django-unfold" "django-unicorn" "django-watson" "django-webpack-loader" "django-widget-tweaks" "drf-spectacular" "drf-yasg" "dynaconf" "environs" "flower" "graphene-django" "Mezzanine" "py-spy" "pyinstrument" "python-slugify" "scout-apm" "sentry-sdk" "sorl-thumbnail" "starlette" "strawberry-graphql" "reactpy-django" "wagtail").Trim()

		switch ($djangoAddons) {
			{ $_ -match "apitally" } {
				$apitallyTemplate = (gum choose --limit=1 --header="Choose Extra Apitally for Django:" "django_rest_framework" "django_ninja").Trim()
				switch ($apitallyTemplate) {
					"django_rest_framework" { $packages += @('apitally[django_rest_framework]') }
					"django_ninja" { $packages += @('apitally[django_ninja]') }
				}
			}
			{ $_ -match "django-admin-interface" } { $packages += @('django-admin-interface') }
			{ $_ -match "django-admin-honeypot" } { $packages += @('django-admin-honeypot') }
			{ $_ -match "django-admin-sortable2" } { $packages += @('django-admin-sortable2') }
			{ $_ -match "django-allauth" } {
				$packages += @('django-allauth-ui', 'django-widget-tweaks', 'slippers')
				$depsAdd = $(Write-Host "Add social account functionality? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') { $packages += @('django-allauth[socialaccount]') }
				else { $packages += @('django-allauth') }
			}
			{ $_ -match "django-braces" } { $packages += @('django-braces') }
			{ $_ -match "django-cachalot" } { $packages += @('django-cachalot') }
			{ $_ -match "django-cacheops" } { $packages += @('django-cacheops') }
			{ $_ -match "django-celery-beat" } { $packages += @('django-celery-beat') }
			{ $_ -match "django-choices-field" } { $packages += @('django-choices-field') }
			{ $_ -match "django-cleanup" } { $packages += @('django-cleanup') }
			{ $_ -match "django-components" } { $packages += @('django-components') }
			{ $_ -match "django-compressor" } { $packages += @('django-compressor') }
			{ $_ -match "django-configurations" } { $packages += @('django-configurations') }
			{ $_ -match "django-constance" } { $packages += @('django-constance[redis]') }
			{ $_ -match "django-cors-headers" } { $packages += @('django-cors-headers') }
			{ $_ -match "django-cms" } { $packages += @('django-cms') }
			{ $_ -match "django-crispy-forms" } { $packages += @('django-crispy-forms') }
			{ $_ -match "django-elasticsearch-dsl" } { $packages += @('django-elasticsearch-dsl') }
			{ $_ -match "django-environ" } { $packages += @('django-environ') }
			{ $_ -match "django-extensions" } { $packages += @('django-extensions') }
			{ $_ -match "django-extra-views" } { $packages += @('django-extra-views') }
			{ $_ -match "django-filter" } { $packages += @('django-filter') }
			{ $_ -match "django-grappelli" } { $packages += @('django-grappelli') }
			{ $_ -match "django-haystack" } { $packages += @('django-haystack') }
			{ $_ -match "django-hijack" } { $packages += @('django-hijack') }
			{ $_ -match "django-imagekit" } { $packages += @('django-imagekit') }
			{ $_ -match "django-impersonate" } { $packages += @('django-impersonate') }
			{ $_ -match "django-import-export" } { $packages += @('django-import-export') }
			{ $_ -match "django-jazzmin" } { $packages += @('django-jazzmin') }
			{ $_ -match "django-lifecycle" } { $packages += @('django-lifecycle') }
			{ $_ -match "django-modeltranslation" } { $packages += @('django-modeltranslation') }
			{ $_ -match "django-money" } { $packages += @('django-money') }
			{ $_ -match "django-ninja" } { $packages += @('django-ninja') }
			{ $_ -match "django-phonenumber-field" } { $packages += @('django-phonenumber-field') }
			{ $_ -match "django-polymorphic" } { $packages += @('django-polymorphic') }
			{ $_ -match "django-prometheus" } { $packages += @('django-prometheus') }
			{ $_ -match "django-rest-framework" } { $packages += @('djangorestframework') }
			{ $_ -match "django-rest-knox" } { $packages += @('django-rest-knox') }
			{ $_ -match "djangorestframework-simplejwt" } { $packages += @('djangorestframework-simplejwt') }
			{ $_ -match "dj-database-url" } { $packages += @('dj-database-url') }
			{ $_ -match "dj-rest-auth" } { $packages += @('dj-rest-auth') }
			{ $_ -match "djoser" } { $packages += @('djoser') }
			{ $_ -match "djongo" } { $packages += @('djongo') }
			{ $_ -match "django-redis" } { $packages += @('django-redis') }
			{ $_ -match "django-reversion" } { $packages += @('django-reversion') }
			{ $_ -match "django-rosetta" } { $packages += @('django-rosetta') }
			{ $_ -match "django-rq" } { $packages += @('django-rq') }
			{ $_ -match "django-silk" } { $packages += @('django-silk') }
			{ $_ -match "django-simple-history" } { $packages += @('django-simple-history') }
			{ $_ -match "django-sockpuppet" } { $packages += @('django-sockpuppet[lxml]') }
			{ $_ -match "django-split-settings" } { $packages += @('django-split-settings') }
			{ $_ -match "django-sql-explorer" } { $packages += @('django-sql-explorer') }
			{ $_ -match "django-storages" } { $packages += @('django-storages') }
			{ $_ -match "django-summernote" } { $packages += @('django-summernote') }
			{ $_ -match "django-tables2" } { $packages += @('django-tables2') }
			{ $_ -match "django-taggit" } { $packages += @('django-taggit') }
			{ $_ -match "django-tastypie" } { $packages += @('django-tastypie') }
			{ $_ -match "django-tinymce" } { $packages += @('django-tinymce') }
			{ $_ -match "django-typer" } { $packages += @('django-typer[rich]') }
			{ $_ -match "django-unfold" } { $packages += @('django-unfold') }
			{ $_ -match "django-unicorn" } { $packages += @('django-unicorn') }
			{ $_ -match "django-watson" } { $packages += @('django-watson') }
			{ $_ -match "django-webpack-loader" } { $packages += @('django-webpack-loader') }
			{ $_ -match "django-widget-tweaks" } { $packages += @('django-widget-tweaks') }
			{ $_ -match "drf-spectacular" } { $packages += @('drf-spectacular') }
			{ $_ -match "drf-yasg" } {
				$depsAdd = $(Write-Host "Use built-in validation mechanisms with 'drf-yasg'? (y/n) " -ForegroundColor Cyan -NoNewline; Read-Host)
				if ($depsAdd.ToUpper() -eq 'Y') { $packages += @('drf-yasg[validation]') }
				else { $packages += @('drf-yasg') }
			}
			{ $_ -match "dynaconf" } { $packages += @('dynaconf') }
			{ $_ -match "environs" } { $packages += @('environs') }
			{ $_ -match "flower" } { $packages += @('flower') }
			{ $_ -match "graphene-django" } { $packages += @('graphene-django') }
			{ $_ -match "Mezzanine" } { $packages += @('Mezzanine') }
			{ $_ -match "py-spy" } { $packages += @('py-spy') }
			{ $_ -match "pyinstrument" } { $packages += @('pyinstrument') }
			{ $_ -match "python-slugify" } { $packages += @('python-slugify[unidecode]') }
			{ $_ -match "scout-apm" } { $packages += @('scout-apm') }
			{ $_ -match "sentry-sdk" } { $packages += @('sentry-sdk[django]') }
			{ $_ -match "sorl-thumbnail" } { $packages += @('sorl-thumbnail') }
			{ $_ -match "starlette" } { $packages += @('starlette[full]') }
			{ $_ -match "strawberry-graphql" } { $packages += @('strawberry-graphql[debug-server]') }
			{ $_ -match "reactpy-django" } { $packages += @('reactpy-django', 'channels[daphne]') }
			{ $_ -match "wagtail" } { $packages += @('wagtail') }
		}

		switch ($ProjectManager) {
			"pdm" { foreach ($p in $packages) { pdm add --quiet --no-sync "$p" } }
			"pipenv" { foreach ($p in $packages) { gum spin --title="pipenv: installing $p ..." -- pipenv install "$p" } }
			"poetry" { foreach ($p in $packages) { poetry add --quiet -- "$p" } }
			"rye" { foreach ($p in $packages) { rye add --quiet "$p" } }
			"uv" { foreach ($p in $packages) { uv add --no-sync --no-progress -q "$p" } }
		}

		Write-LinkInformation "https://awesomedjango.org/"
	}

	switch ($ProjectManager) {
		"pdm" {
			pdm run django-admin startproject $subProjectName .
		}
		"pipenv" {
			pipenv run django-admin startproject $subProjectName .
		}
		"poetry" {
			poetry run django-admin startproject $subProjectName .
		}
		"rye" {
			rye run django-admin startproject $subProjectName src
		}
		"uv" {
			uv run django-admin startproject $subProjectName .
		}
	}
}
