<#
.SYNOPSIS
Get-JumpLists.ps1
When run via Kansa.ps1 with -Pushbin flag, this module will copy 
JLECmd.exe to the remote system, then run 
JLECmd.exe --csv $AppCompatCacheParserOutputPath on the remote system, 
and return the output data as a powershell object.
This script is required to run before Get-CustomDest.ps1 as it generates
the output files.

JLECmd.exe can be downloaded from http://ericzimmerman.github.io/

.NOTES
Kansa.ps1 directives
OUTPUT CSV
BINDEP .\Modules\bin\JLECmd.exe
#>

#Setup Variables
$JLECmdParserPath = ($env:SystemRoot + "\JLECmd.exe")
$Runtime = ([String] (Get-Date -Format yyyyMMddHHmmss))
$JLECmdParserOutputPath = $($env:Temp + "\JLECmd-$($Runtime)")

#Create the output folder
try {
    $suppress = New-Item -Name "JLECmd-$($Runtime)" -ItemType Directory -Path $env:Temp -Force
}
catch {
    Write-Error "Unable to create the output folder. Error: $_"
}

#Find and execute JLECmd.exe
if (Test-Path ($JLECmdParserPath)) {
    #Run JLECmd.exe
    try {
        $suppress = & $JLECmdParserPath --csv $JLECmdParserOutputPath -d "C:\users"
    }
    catch { 
        Write-Error "Unable to Execute. Error: $_"
    }

    #Grab The Automatic Destinations.
    try {
        if (Test-Path "$JLECmdParserOutputPath\*_AutomaticDestinations.csv") {
            Import-Csv -Delimiter "`t" "$JLECmdParserOutputPath\*_AutomaticDestinations.csv"
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