
function Get-Fahrenheit ([double] $CelsiusTemp)
  
    { $Fahrenheit = ($CelsiusTemp*1.8)+32
      $Fahrenheit
        
    }

 function Get-Celsius ([double] $FahrenheitTemp)
    
    { $Celsius = ($FahrenheitTemp-32)/1.8
      $Celsius
        
    }


$FahrenheitTemp = Read-Host 'Input a temperature in Fahrenheit'
$result1 =[decimal](Get-Celsius($FahrenheitTemp))
Write-Host "$result1 Celsius"

$CelsiusTemp = Read-Host 'Input a temperature in Celsius'
$result2 =[decimal](Get-Fahrenheit($CelsiusTemp))
Write-Host "$result2 Fahrenheit"


