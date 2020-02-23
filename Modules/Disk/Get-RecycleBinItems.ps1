<#
.SYNOPSIS
Get-RecycleBinItems.ps1 runs Eric Zimmermans tools to dump the contents of all Recycle Bins.
.NOTES
Next line is required by kansa.ps1 for proper handling of script output
OUTPUT tsv
BINDEP .\Modules\bin\RBCmd.exe
#>

#Setup Variables
$RBCmdPath = ($env:SystemRoot + "\RBCmd.exe")
$Runtime = ([String] (Get-Date -Format yyyyMMddHHmmss))
$RBCmdParserOutputPath = $($env:Temp + "\RBCmd-$($Runtime)")

#create the output folder
try {
    $suppress = New-Item -Name "RBCmd-$($Runtime)" -ItemType Directory -Path $env:Temp -Force
}
catch {
    Write-Error "Unable to create the output folder. Error: $_"
}

#Find and Execute RBCmd.exe
if (Test-Path ($RBCmdPath)) {
    #Run RBCmd.exe
    try {
        $suppress = & $RBCmdPath --csv $RBCmdParserOutputPath -d 'c:\'
    }
    catch { 
        Write-Error "Unable to Execute. Error: $_"
    }
    
    #Output the data.
    try {
        Import-Csv -Delimiter "`t" "$RBCmdParserOutputPath\*.csv"  
    }
    catch {
        Write-Error "Unable to Import the CSV. Error: $_"
    }
}
else {
    Write-Error "RBCmd.exe not found on $env:COMPUTERNAME"
}

#Remove the folder we created.
try {
    if (Test-path ($RBCmdParserOutputPath)) {
        $suppress = Remove-Item $RBCmdParserOutputPath -Force -Recurse
    } 
}
catch {
    Write-Error "Failed to remove Output folder: $RBCmdParserOutputPath."
}