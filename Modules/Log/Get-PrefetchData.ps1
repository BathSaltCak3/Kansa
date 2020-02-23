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
BINDEP .\Modules\bin\PECmd.exe
#>

#Setup Variables
$PECmdParserPath = ($env:SystemRoot + "\PECmd.exe")
$Runtime = ([String] (Get-Date -Format yyyyMMddHHmmss))
$PECmdParserOutputPath = $($env:Temp + "\PEcmd-$($Runtime)")

#Create the output folder
try {
    $suppress = New-Item -Name "PEcmd-$($Runtime)" -ItemType Directory -Path $env:Temp -Force
}
catch {
    Write-Error "Unable to create the output folder. Error: $_"
}

#Find and execute PECmd.exe
if (Test-Path ($PECmdParserPath)) {
    #Run PECmd.exe
    try {
        $suppress = & $PECmdParserPath --csv $PECmdParserOutputPath -d "C:\Windows\Prefetch"
    }
    catch { 
        Write-Error "Unable to Execute. Error: $_"
    }
    
    #Output the data.
    try {
        if (Test-Path "$PECmdParserOutputPath\*.csv") {
            Import-Csv -Delimiter "`t" "$PECmdParserOutputPath\*_PECmd_Output.csv"
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