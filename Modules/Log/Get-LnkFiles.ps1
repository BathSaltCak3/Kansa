<#
.SYNOPSIS
Get-PrefretchData.ps1
When run via Kansa.ps1 with -Pushbin flag, this module will copy 
PECmd.exe to the remote system, then run 
PECmd.exe --csv $PECmd on the remote system, 
and return the output data as a powershell object.
We leave the output folder here and expect Get-PrefetchTimeline 
to be run after the fact for cleanup.

PECmd.exe can be downloaded from http://ericzimmerman.github.io/

.NOTES
Kansa.ps1 directives
OUTPUT CSV
BINDEP .\Modules\bin\LECmd.exe
#>

#Setup Variables
$LECmdParserPath = ($env:SystemRoot + "\LECmd.exe")
$Runtime = ([String] (Get-Date -Format yyyyMMddHHmmss))
$LECmdParserOutputPath = $($env:Temp + "\LECmd-$($Runtime)")

#Create the output folder
try {
    $suppress = New-Item -Name "LECmd-$($Runtime)" -ItemType Directory -Path $env:Temp -Force
}
catch {
    Write-Error "Unable to create the output folder. Error: $_"
}

#Find and execute LECmd.exe
if (Test-Path ($LECmdParserPath)) {
    #Run LECmd.exe
    try {
        $suppress = & $LECmdParserPath --csv $LECmdParserOutputPath -d "c:\"
    }
    catch { 
        Write-Error "Unable to Execute. Error: $_"
    }
    
    #Output the data.
    try {
        if (Test-Path "$LECmdParserOutputPath\*.csv") {
            Import-Csv -Delimiter "`t" "$LECmdParserOutputPath\*.csv"
        }
        else { 
            Write-Error "Unable to locate output file." 
        }
    }
    catch {
        Write-Error "Unable to Import the CSV. Error: $_"
    }        
}
else {
    Write-Error "AppCompatCacheParser.exe not found on $env:COMPUTERNAME"
}
try {
    if (Test-path ($PECmdParserOutputPath)) {
        $suppress = Remove-Item $PECmdParserOutputPath -Force -Recurse
    } 
}
catch {
    Write-Error "Failed to remove Output folder: $PECmdParserOutputPath."
}