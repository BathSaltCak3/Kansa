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
$suppress = New-Item -Name "RBCmd-$($Runtime)" -ItemType Directory -Path $env:Temp -Force
$RBCmdParserOutputPath = $($env:Temp + "\RBCmd-$($Runtime)")

if (Test-Path ($AppCompatCacheParserPath)) {
    #Run AppCompatCacheParser.exe
    $suppress = & $RBCmdPath --csv $RBCmdParserOutputPath

    #Output the data.
    Import-Csv -Delimiter "`t" "$RBCmdParserOutputPath\*.tsv"
    
    #Delete the output folder.
    $suppress = Remove-Item $RBCmdParserOutputPath -Force -Recurse
        
} else {
    Write-Error "RBCmd.exe not found on $env:COMPUTERNAME"
}