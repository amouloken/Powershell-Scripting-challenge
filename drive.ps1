#log directory
if ($PSVersionTable.Platform -eq 'Unix') {
    $logPath = '/tmp'
}
else {
    $logPath = 'C:\Logs'
}

$logFile = "$logPath\driveCheck.log" #logfile
#verify  if the log directory exists
try {
     if (-not (Test-Path -Path $logPath -ErrorAction Stop)){
         # output dir is not found.Create the dir
         New-Item -ItemType Directory -Path $logPath -ErrorAction Stop | Out-Null
         New-Item -ItemType File -Path $logFile -ErrorAction Stop | Out-Null
        }
}
catch {
    throw
}
Add-Content -Path $logFile -Value "[INFO] Running $PSCommandPath"

# verify that PoshGram is installed
if ( -not (Get-Module -Name PoshGram -ListAvailable)) {
     Add-Content -Path $logFile -Value "[ERROR] PoshGram is not installed."
     throw

}
else {
    Add-Content -Path $logFile -Value "[INFO] PoshGram is installed."

}
# get hard drive information
try {
# get hard drive information
if ($PSVersionTable.Platform -eq 'Unix') {
    
    # used
    # free
    $volume = Get-PSDrive -Name $Drive -ErrorAction Stop
    # verify volume actually exists
    if ($volume) {
     $total = $volume.Used + $volume.Free
     $percentFree = [int](($volume.Free / $total) * 100)
     Add-Content -Path $logFile -Value "[INFO] Percent Free: $percentFree%"
    }
    else {
        Add-Content -Path $logFile -Value "[ERROR] $Drive was not found."
        throw    
    }
}
else   {
       $volume = Get-Volume -ErrorAction Stop | Where-Object {$_.DriveLetter -eq $Drive}
       if ($volume) {
           $total =  $volume.Size
           $percentFree = [int](($volume.SizeRemaining / $total) * 100)
           Add-Content -Path $logFile -Value "[INFO] Percent Free: $percentFree%"
        }
        else {
            Add-Content -Path $logFile -Value "[ERROR] $Drive was not found."
            throw    
        }
   } 
}
catch {
    Add-Content -Path $logFile -Value "[ERROR] Unable to retrieve volume information."  
    Add-Content -Path $logFile -Value $_
    throw

}       

# send telegram message if the drive is low
if ($percentFree -le 20) {
    try {
        Import-Module -Name Poshgram -ErrorAction Stop
        Add-Content -Path $logFile -Value "[INFO] Imported PoshGram succesfully."
    
    }
    catch {
        Add-Content -Path $logFile -Value "[INFO] Poshgram could not be imported:"
        Add-Content -Path $logFile -Value $_
    }
    Add-Content -Path $logFile -Value "[INFO] Sending Telegram notification"
}
$botToken = 'nnnnnnnnn:xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxx'
$chat = '-nnnnnnnnn'
Send-TelegramTextMessage -BotToken $botToken -ChatID $chat -Message "Your drive is low"
