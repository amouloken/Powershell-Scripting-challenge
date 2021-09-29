

# .DATE: 5/1/2020
# .AUTHOR: FULLFLOW 
# .CHALLENGE: https://ironscripter.us/a-powershell-word-play-challenge/
 
$w = "FULLFLOW the Iron Scripter!"
 
foreach ($a in [char[]]$w) { 
$b = [char]$a -as [int]
$c += $b
}
 
Write-Host "$c"
