function New-DirectoryIfNotExist {
	param ([string]$Path)

	if (!(Test-Path $Path -PathType Container)) {
		New-Item $Path -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
	}
}
