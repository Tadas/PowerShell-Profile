Clear-Host

# http://nerdfonts.com/#cheat-sheet
$Glyphs = @{
	FilledTriangleRight = [char]0xe0b0
	RightSoftDivider = [char]0xe0b1
	
	FilledTriangleLeft = [char]0xe0b2
	LeftSoftDivider = [char]0xe0b3

	FilledTriangleLowerLeft = [char]0xe0b8
	FilledTriangleLowerRight = [char]0xe0ba
	FilledTriangleUpperLeft = [char]0xe0bc
	FilledTriangleUpperRight = [char]0xe0be
	
	Clock = [char]0xf43a
	
	DoubleLeftAngle = "«"
	DoubleRightAngle = "»"

	Branch = [char]0xe0a0
	Folder = [char]0xf07c

	gitAdded = [char]0xf457
	gitDeleted = [char]0xf458
	gitModified = [char]0xf459

}

$Colors = @{
	ActiveTextFore = "Gray" # Like the command prompt
	PassiveTextFore = "DarkGray" # Like the clock

	StatusLineBackground = "Black" # Path background
	StatusLineForeground = "Green" # Path text
	TerminalBackgroundColor = $Host.UI.RawUI.BackgroundColor # For things that can be transparent
}

Write-Host "`n`tNever send a human to do a machine's job`n" -ForegroundColor $Colors.ActiveTextFore

$global:LastCommandsHistoryId = 0

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
	Write-Host "" # Separator after the last command's output

	# The small arrow before the clock
	Write-Host " " -Background Black -Foreground Black -NoNewline
	Write-Host $Glyphs.FilledTriangleRight -Foreground Black -NoNewline

	# Clock
	Write-Host "$($Glyphs.Clock) $(Get-Date -Format T)" -Foreground DarkGray -NoNewLine
	Write-Host $Glyphs.FilledTriangleRight -Background $Colors.StatusLineBackground -ForegroundColor $Colors.TerminalBackgroundColor -NoNewline
	
	# Current path
	Write-Host "$($Glyphs.Folder) $(Get-Location)" -Background $Colors.StatusLineBackground -Foreground $Colors.StatusLineForeground -NoNewLine
	
	# git info (requires posh-git)
	if(Get-Command Get-GitStatus -ErrorAction SilentlyContinue){
		$GitStatus = Get-GitStatus
		if($GitStatus){
			Write-Host $Glyphs.FilledTriangleUpperLeft -ForegroundColor Black -BackgroundColor Gray -NoNewline
			Write-Host " $($Glyphs.Branch) $($GitStatus.Branch)" -BackgroundColor Gray -ForegroundColor Black -NoNewline

			if($GitStatus.HasWorking){
				# Write-Host $Glyphs.FilledTriangleUpperLeft -ForegroundColor Gray -BackgroundColor DarkGray -NoNewline
				Write-Host $Glyphs.FilledTriangleRight -ForegroundColor Gray -BackgroundColor DarkGray -NoNewline

				if($GitStatus.Working.Added.count -gt 0){
					Write-Host " $($Glyphs.gitAdded)" -BackgroundColor DarkGray -ForegroundColor Black -NoNewline
					Write-Host $GitStatus.Working.Added.count -BackgroundColor DarkGray -ForegroundColor Black -NoNewline
				}

				if($GitStatus.Working.Deleted.count -gt 0){
					Write-Host " $($Glyphs.gitDeleted)" -BackgroundColor DarkGray -ForegroundColor Black -NoNewline
					Write-Host $GitStatus.Working.Deleted.count -BackgroundColor DarkGray -ForegroundColor Black -NoNewline
				}

				if($GitStatus.Working.Modified.count -gt 0){
					Write-Host " $($Glyphs.gitModified)" -BackgroundColor DarkGray -ForegroundColor Black -NoNewline
					Write-Host $GitStatus.Working.Modified.count -BackgroundColor DarkGray -ForegroundColor Black -NoNewline
				}

				# If there were no working changed then render end of git working block
				Write-Host $Glyphs.FilledTriangleUpperLeft -ForegroundColor DarkGray -BackgroundColor Black -NoNewline
			} else {
				# If there were no working changed then render end of git block
				Write-Host $Glyphs.FilledTriangleUpperLeft -ForegroundColor Gray -BackgroundColor Black -NoNewline
			}
		}
	}
	
	# and fill the remainder of the line with background color!
	$RemainingSpace = ((Get-Host).UI.RawUI.BufferSize.Width - (Get-Host).UI.RawUI.CursorPosition.X) - 2
	Write-Host "$(" " * $RemainingSpace)" -Background $Colors.StatusLineBackground -NoNewLine
	Write-Host $Glyphs.FilledTriangleRight -Foreground $Colors.StatusLineBackground -NoNewLine

	# Prompt line below the status line
	Write-Host " λ »" -NoNewLine -Foreground $Colors.ActiveTextFore
	
	$global:LastCommandsHistoryId = $NextHistId
	return " " # return something otherwise we get PS> added
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

