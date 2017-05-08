Clear-Host
Write-Host "`n`t`"Never send a human to do a machine's job.`"`n"


$global:LastCommandsHistoryId = 0

$ColorSeparator = [char]0xe0b0
# The custom prompt
function Prompt {
	$NextHistId = (Get-History -count 1).Id + 1

	# If command history id wasn't incremented means the last command was empty. The user probably needs some whitespace
	if ($global:LastCommandsHistoryId -eq $NextHistId){
		Write-Host "`r`n`r`n`r`n`r`n"
	} else {
		# show the last command in the title bar
		if ((Get-History).count -ge 1) {
			$Host.UI.RawUI.WindowTitle = "[PID:" + [System.Diagnostics.Process]::GetCurrentProcess().Id + "]  " + (Get-History -count 1).CommandLine
			
		}
	}
    Write-Host "" # Separator after the output
	Write-Host "[$(Get-Date -Format T)]" -Foreground Gray -BackgroundColor DarkBlue -NoNewLine
	Write-Host $ColorSeparator -NoNewline -Background Black -ForegroundColor DarkBlue
	Write-Host "$(Get-Location)" -Background Black -Foreground Green -NoNewLine
	
	# Fill the remainder of the line with some color!
	$RemainingSpace = ((Get-Host).UI.RawUI.BufferSize.Width - (Get-Host).UI.RawUI.CursorPosition.X) - 2
	Write-Host "$(" " * $RemainingSpace)" -Background Black -Foreground Green -NoNewLine
	Write-Host $ColorSeparator -Foreground Black -NoNewLine

	Write-Host " λ" -NoNewLine -Foreground Black -BackgroundColor DarkGray
	Write-Host $ColorSeparator -NoNewline -ForegroundColor DarkGray
	
	$global:LastCommandsHistoryId = $NextHistId
	return " "
}


# Make the cd command smarter - go to the parent folder if file path specified
function Set-LocationBetter {
	Param(
		[Parameter(ValueFromRemainingArguments=$true)]
		[string]$NewLocation = ""
	)

	if ($NewLocation -eq ""){
		Write-Host "Where to? " -NoNewline
		[console]::ForegroundColor = "Green"
		[console]::BackgroundColor= "Black"
		
		$NewLocation = Read-Host
		
		[console]::ResetColor()
	}
	
	if([string]::IsNullOrEmpty($NewLocation)){ return }

	# If a file is specified as the location go to that files folder
	if (Test-Path -Type Leaf $NewLocation){
		$NewLocation = Split-Path -Parent $NewLocation
	}
	Set-Location $NewLocation
	Write-Host
}
Set-Alias cd "Set-LocationBetter" -Option AllScope -Scope Global


$Host.UI.RawUI.WindowTitle = "[PID:" + [System.Diagnostics.Process]::GetCurrentProcess().Id + "]"

