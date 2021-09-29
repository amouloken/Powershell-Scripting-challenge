#ref: https://ironscripter.us/another-powershell-math-challenge/
<#
Intermediate Level
Given a value like this:
 
$i = 2568
What is the total sum of all the individual integers? That is to say
 
2+5+6+8
Write a function that will accept a value and return the sum.
 
Bonus Elements
Limit the length of the number to 10 digits
Include Verbose output to show the operation
Write a variation on the function that writes an object to the pipeline that shows the original number, the number of individual elements and the sum.
#>
Function Calculation2 {
    param (
       $InPutNumber
 
    )
    if($InPutNumber.GetType().Name -like '*Int*' ){
 
#Turn on Verbose    
$VerbosePreference = "continue"
$DigitLenghtLimit = 11
$MaxNumber = $DigitLenghtLimit - 1
$TotalNumbers = ($InputNumber.ToString() | Measure-Object -Character).Characters
If($TotalNumbers -lt $DigitLenghtLimit){
     
    $Calculation = $null
    $i = 0
    while($i -lt $TotalNumbers){
        $PreviousCalc = $Calculation
        $Calculation = $Calculation + [int](($InputNumber.ToString())[$i]).ToString()
 
     if($i -eq 0){
 
     }#If $i is zero do nada
     else{
    $PreviousNumber = [int](($InputNumber.ToString())[($i -1)]).ToString()
    $Number = [int](($InputNumber.ToString())[$i]).ToString()
    Write-Verbose "$PreviousCalc + $Number = $Calculation"
     }#else continue
 
 
 
        $i ++
    }
    $Calculation
    ############Variation #################
###### to write an object to the pipeline which shows the original number, the number of individual elements and the sum
foreach($char in ($InputNumber.ToString()).ToCharArray()){
    $FormatChar = $char + "+"
        $Sum += $FormatChar
     
    }#FE Character create Sum output
    $Sum = $Sum.TrimEnd("+")
     
     
    New-Object psobject -Property @{
        "Original Number"     = $InPutNumber
        "Number of Elements"  = $TotalNumbers
        "Sum"         = $Sum
             
    }#New PSOBJECT
    ############Variation #################
}
 
else{
   Write-Output "$InputNumber has $TotalNumbers Digits. Max is $MaxNumber "
}
    }#Is int32 so continue
    else{
        Write-Output "Please Enter an Integer with maximum 10 digits"
         }#Else Nada
 
}#Function Calculation2
