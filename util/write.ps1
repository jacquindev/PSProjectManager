function Write-PromptInput {
	param (
		[Parameter(Position = 0)][string]$Prompt,
		[Parameter(Position = 1)][string]$Placeholder = "Type something...",
		[Parameter(Position = 2)][string]$QuickNote
	)

	$betterPrompt = gum style --foreground="#a6e3a1" "$Prompt"
	$betterPlaceholder = gum style --foreground="#cdd6f4" --faint "$Placeholder"
	$separator = gum style --foreground="#a6e3a1" --bold "❯"

	if ($QuickNote) {
		$note = gum style --foreground="#a6e3a1" --faint --italic "($QuickNote)"
		Write-Host "✍️  $betterPrompt $note$separator $betterPlaceholder " -NoNewline; Read-Host
	} else {
		Write-Host "✍️  $betterPrompt$separator $betterPlaceholder " -NoNewline; Read-Host
	}
}

function Write-Note {
	param (
		[Parameter(Position = 0)][string]$Text,
		[Parameter(Position = 1)][string]$Highlight
	)

	$hl = gum style --italic --bold --foreground="#8aadf4" "$Highlight"
	Write-Host "⭐ $Text $hl"
}

function Write-Link {
	param (
		[Parameter(Position = 0)][string]$Text,
		[Parameter(Position = 1)][string]$Link
	)

	$lk = gum style --italic --bold --foreground="#74c7ec" "$Link"
	Write-Host "🔗 $Text $lk"
}

function Write-YesNo {
	param (
		[Parameter(Position = 0)][string]$Text,
		[switch]$y,
		[switch]$n
	)

	$txt = gum style --foreground="#94e2d5" --italic "$Text"
	$yn = gum style --foreground="#9399b2" --bold "[Y/n]:"

	$dfY = gum style --foreground="#94e2d5" --faint "(default: y)"
	$dfN = gum style --foreground="#94e2d5" --faint "(default: n)"

	if ($y) { Write-Host "❔ $txt $dfY $yn " -NoNewline; Read-Host }
	elseif ($n) { Write-Host "❔ $txt $dfN $yn " -NoNewline; Read-Host }
	else { Write-Host "❔ $txt $yn " -NoNewline; Read-Host }
}
