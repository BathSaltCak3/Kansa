<#
.SYNOPSIS
Get-AppCompatCache.ps1
When run via Kansa.ps1 with -Pushbin flag, this module will copy 
AppCompatCacheParser.exe to the remote system, then run 
AppCompatCacheParser.exe --csv $AppCompatCacheParserOutputPath on the remote system, 
and return the output data as a powershell object.

AppCompatCacheParser.exe can be downloaded from http://ericzimmerman.github.io/

.NOTES
Kansa.ps1 directives
OUTPUT CSV
BINDEP .\Modules\bin\AppCompatCacheParser.exe
#>

#Setup Variables
$AppCompatCacheParserPath = ($env:SystemRoot + "\AppCompatCacheParser.exe")
$Runtime = ([String] (Get-Date -Format yyyyMMddHHmmss))
$AppCompatCacheParserOutputPath = $($env:Temp + "\ACCP-$($Runtime)")

#Create the output folder
try {
    $suppress = New-Item -Name "ACCP-$($Runtime)" -ItemType Directory -Path $env:Temp -Force
}
catch {
    Write-Error "Unable to create the output folder. Error: $_"
}

#Find and execute AppCompatCacheParser.exe
if (Test-Path ($AppCompatCacheParserPath)) {
    #Run AppCompatCacheParser.exe
    try {
        $suppress = & $AppCompatCacheParserPath --csv $AppCompatCacheParserOutputPath
    }
    catch { 
        Write-Error "Unable to Execute. Error: $_"
    }
    
    #Output the data.
    try {
        Import-Csv -Delimiter "`t" "$AppCompatCacheParserOutputPath\*.csv"
    }
    catch {
        Write-Error "Unable to Import the CSV. Error: $_"
    }        
}
else {
    Write-Error "AppCompatCacheParser.exe not found on $env:COMPUTERNAME"
}

try {
    if (Test-path ($AppCompatCacheParserOutputPath)) {
        $suppress = Remove-Item $AppCompatCacheParserOutputPath -Force -Recurse
    } 
}
catch {
    Write-Error "Failed to remove Output folder: $AppCompatCacheParserOutputPath."
}