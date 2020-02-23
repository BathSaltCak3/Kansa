<#
.SYNOPSIS
Get-PrefretchData.ps1
When run via Kansa.ps1 with -Pushbin flag, this module will copy 
PECmd.exe to the remote system, then run 
PECmd.exe --csv $PECmd on the remote system, 
and return the output data as a powershell object.
We expect Get-PrefetchData to be run before this. We grab the
timeline version of the output here and import it as its own tab.

PECmd.exe can be downloaded from http://ericzimmerman.github.io/

.NOTES
Kansa.ps1 directives
OUTPUT CSV
BINDEP .\Modules\bin\PECmd.exe
#>

#Setup Variables
$PECmdParserOutputPath = (Get-ChildItem -Path "$env:Temp" -Filter "PECmd-*").FullName

#Create the output folder
try {
    $suppress = New-Item -Name "PEcmd-$($Runtime)" -ItemType Directory -Path $env:Temp -Force
}
catch {
    Write-Error "Unable to create the output folder. Error: $_"
}

#Output the data.
try {
    if (Test-Path "$PECmdParserOutputPath\*_PECmd_Output_Timeline.csv") {
        Import-Csv -Delimiter "`t" "$PECmdParserOutputPath\*_PECmd_Output_Timeline.csv"
    }
    else { 
        Write-Error "Unable to locate output file." 
    }
}
catch {
    Write-Error "Unable to Import the CSV. Error: $_"
}
try {
    if (Test-path ($PECmdParserOutputPath)) {
        $suppress = Remove-Item $PECmdParserOutputPath -Force -Recurse
    } 
}
catch {
    Write-Error "Failed to remove Output folder: $PECmdParserOutputPath."
}