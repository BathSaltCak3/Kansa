<#
.SYNOPSIS
Get-JumpLists.ps1
When run via Kansa.ps1 with -Pushbin flag, this module will copy 
JLECmd.exe to the remote system, then run 
JLECmd.exe --csv $AppCompatCacheParserOutputPath on the remote system, 
and return the output data as a powershell object.

JLECmd.exe can be downloaded from http://ericzimmerman.github.io/

.NOTES
Kansa.ps1 directives
OUTPUT CSV
BINDEP .\Modules\bin\JLECmd.exe
#>

#Setup Variables
$JLECmdParserOutputPath = (Get-ChildItem -Path "$env:Temp" -Filter "JLECmd-*").FullName

#Create the output folder
try {
    $suppress = New-Item -Name "JLECmd-$($Runtime)" -ItemType Directory -Path $env:Temp -Force
}
catch {
    Write-Error "Unable to create the output folder. Error: $_"
}

#Grab The Custom Destinations.
try {
    if (Test-Path "$JLECmdParserOutputPath\*_CustomDestinations.csv") {
        Import-Csv -Delimiter "`t" "$JLECmdParserOutputPath\*_CustomDestinations.csv"
    }
    else { 
        Write-Error "Unable to locate output file." 
    }
}
catch {
    Write-Error "Unable to Import the CSV. Error: $_"
}        
else {
    Write-Error "AppCompatCacheParser.exe not found on $env:COMPUTERNAME"
}

try {
    if (Test-path ($JLECmdParserOutputPath)) {
        $suppress = Remove-Item $JLECmdParserOutputPath -Force -Recurse
    } 
}
catch {
    Write-Error "Failed to remove Output folder: $JLECmdParserOutputPath."
}