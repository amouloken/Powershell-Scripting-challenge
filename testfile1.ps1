#region funcs
function checkSum {
    param (
        $upnums,
        [int]$diceroll
    )
    $sum = ($upnums | Measure-Object -sum).Sum
    for ($i=0; $i -lt $upnums.count; $i++){
        for ($j=0; $j -lt $upnums.count; $j++){
          if (($upnums[$i] + $upnums[$j] -eq $diceroll) -and ($i -ne $j) -or ($upnums[$i] -eq $diceroll) -or ($sum -eq $diceroll)){ 
            return $true
          }
        }  
    }   
    return $false
}

function displayBoxes {
    param (
        [int]$min,
        [int]$max,
        [array]$downnums
    )
    $disp = ($min..$max| % {Write-Output "|$_|"})
    
    foreach ($d in $downnums){
       $disp = $disp -replace $d,'X'
    }
    return (Write-Host $disp -NoNewline)
}

function checkWin {
    param (
        [array]$upnums
    )
    if ($upnums.Count -eq 0){
        return $true
    }
    return $false
}

function rollDice{
    $d = get-random -min 1 -max 7
    return $d
}

#endregion

#region settings
cls
$downnums = New-Object Collections.Generic.List[Int]
$upnums = New-Object Collections.Generic.List[Int]
$min = 1
$max = 9
$min..$max | % {$upnums.Add($_)}

#endregion

#region game
while ($true){

    #display the open/closed boxes
    displayBoxes -min $min -max $max -downnums $downnums

    #check if play has won
    if (checkWin -upnums $upnums){
        return 'YOU WIN'
    }

    #roll the dice
    $dice1 = rollDice
    $dice2 = rollDice
    $diceroll = $dice1 + $dice2
    Write-Output "`nyou rolled $diceroll `ndice one = $dice1, dice two = $dice2"

    #check if a move is possible
    if(!(checkSum -upnums $upnums -diceroll $diceroll)){
        "lose, can't finish turn with this roll"
        break
    }

    #box selection cycle
    [int]$door = $null
    $accum = New-Object Collections.Generic.List[Int]
    $sum = 0
    while ($sum -lt $diceroll){

        do{ 
            
            $door = Read-Host -Prompt "which door numbers to close? $sum of $diceroll used"           
            if (
                ($door -gt $diceroll) -or `
                ($door -le 0) -or `
                ($door -eq'[a-z]') -or `
                (($accum | ? {$door -eq $_}) -eq $door) -or `
                (($downnums | ? {$door -eq $_}) -eq $door) -or `
                ($door -gt $max)
                ){
                'invalid, try again'
                $accum = New-Object Collections.Generic.List[Int]
                $sum = 0
            }else {              
            $accum.add($door)
            $sum = ($accum | Measure-Object -Sum).sum
                if ($sum -gt $diceroll){
                    'invalid, try again'
                    $accum = New-Object Collections.Generic.List[Int]
                    $sum = 0
                }
            }
        }until($sum-eq $diceroll)

        for ($i=0;$i-lt$accum.count;$i++){
            $downnums.Add($accum[$i]) | Out-Null
            $upnums.Remove($accum[$i]) | Out-Null

        }
    }  
}
#endregion
