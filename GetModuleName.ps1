[CmdletBinding()]
param (
    [Parameter(Mandatory=$false,
    HelpMessage="The current path as the value of the path parameter if not passed Path parameter."
    )]
    [string]
    $Path,

    [Parameter(Mandatory=$false,
    HelpMessage="The Path parameter and the OutPath parameter are the same if not passed OutPath parameter."
    )]
    [string]
    $OutPath
)
try  {
    if (!$PSBoundParameters.ContainsKey("Path")) {
        $Path = $PSScriptRoot
    }

    if (!$PSBoundParameters.ContainsKey("OutPath")) {
        $OutPath = $PSScriptRoot
    }

    $AllList = (Get-ChildItem -Path $Path -Recurse -ErrorAction Stop)

    $AzPrivateList = (Get-ChildItem -Path $Path -Recurse -Filter 'Az.*.Private.dll' -ErrorAction Stop)
    $MicrosoftAzureManagementList = (Get-ChildItem -Path $Path -Recurse -Filter 'Microsoft.Azure.Management.*.dll' -ErrorAction Stop)
    $MicrosoftAzureCmdletsList = (Get-ChildItem -Path $Path -Recurse -Filter 'Microsoft.Azure.PowerShell.Cmdlets.*.dll' -ErrorAction Stop)
    $XmlList = (Get-ChildItem -Path $Path -Recurse -Filter ' Microsoft.Azure.PowerShell.Cmdlets.*.dll-Help.xml' -ErrorAction Stop)

    $AllList = ($AllList | Where {$AzPrivateList -NotContains $_})
    $AllList = ($AllList | Where {$MicrosoftAzureManagementList -NotContains $_})
    $AllList = ($AllList | Where {$MicrosoftAzureCmdletsList -NotContains $_})
    $returnPath = ($AllList | Where {$XmlList -NotContains $_})

    $ModuleData = $returnPath | Select-Object -Property $returnPath.FullName.Split("\")[6]
    $ModuleData | Add-Member -NotePropertyName ModuleVersion -NotePropertyValue $null
    $ModuleData | Add-Member -NotePropertyName ModuleDllName -NotePropertyValue $null

    for($index=0; $index -lt $returnPath.FullName.Length; $index++){
        $UrIElements = $returnPath.FullName[$index].Split("\")

        if ($UrIElements.Count -eq 8){
            $ModuleData[$index]."Az.Accounts" = $UrIElements[6]
            $ModuleData[$index].ModuleVersion = $UrIElements[7]
        } elseif ($UrIElements.Count -eq 9){
            if ($UrIElements[8] -match ".dll"){
                $ModuleData[$index]."Az.Accounts" = $UrIElements[6]
                $ModuleData[$index].ModuleVersion = $UrIElements[7]
                $ModuleData[$index].ModuleDllName = $UrIElements[8]
            }
        }
    }

    $designFile = 'Get-Az.Module.txt'

    $outFilePath = Join-Path $OutPath $designFile

    $ModuleData = $ModuleData | Sort-Object -Property @{Expression = "Az.Accounts"; Descending = $true},@{Expression = "ModuleVersion"; Descending = $true}
    $ModuleData | Out-File -FilePath $outFilePath -Append -ErrorAction Stop

    Write-Host -ForegroundColor Green "Genereated $designFile completed in $outFilePath. path."
    return
}
catch {
    throw
    return
}