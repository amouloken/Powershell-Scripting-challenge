Function Get-NumberSum {
    [cmdletbinding()]
    [OutputType([Int])]
    [OutputType("NumberSum")]
    [Alias("gns")]
    Param(
         [ValidateScript({
            if ($_.ToString().Length -le 10) {
                $True
            }
            else {
                Throw "Specify a value of 10 digits or less."
                $False
            }
        })]
        [int64]$Value,
        [switch]$Quiet
    )

    Write-Verbose "Processing $Value"
    #define a regex pattern to match a single digit
    [regex]$rx = "\d{1}"

    $values = $rx.Matches($Value).Value
    Write-Verbose ($values -join "+")

    $measure =  $Values | Measure-Object -Sum
    Write-Verbose "Equals $($measure.sum)"

    if ($Quiet) {
        $measure.sum
    }
    else {
        [pscustomobject]@{
            PSTypeName = "NumberSum"
            Value = $Value
            Elements = $values
            Sum = $measure.sum
        }
    }
}
