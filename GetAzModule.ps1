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

    # $DataOfAzModules = (Get-ChildItem -Name -Path $Path)
    $DataOfAzModules = Get-Content -Path "D:\_Code\Script\Az.Module.txt"

    function Get-AzModuleDataFunction{
        param (
            $AzModuleData
        )
        $OutPutTitle = @("Module Name,Module Version,Release Date,Cmdlet Name,Cmdlet Type,Az Version")
        $parameters = @{
         TypeName = 'System.Collections.Generic.HashSet[string]'
         ArgumentList = ([string[]]$OutPutTitle, [System.StringComparer]::OrdinalIgnoreCase)
        }
        $AzModuleOutPut = New-Object @parameters

        foreach ($AzModule in $AzModuleData){
            # $AzModuleOutPut = New-Object PSObject
            # Add-Member -InputObject $AzModuleOutPut -MemberType NoteProperty -Name Module -Value $NULL
            # Add-Member -InputObject $AzModuleOutPut -MemberType NoteProperty -Name ModuleVersion -Value $NULL
            # Add-Member -InputObject $AzModuleOutPut -MemberType NoteProperty -Name ReleaseDate -Value $NULL
            # Add-Member -InputObject $AzModuleOutPut -MemberType NoteProperty -Name AzVersion -Value $NULL
            # Add-Member -InputObject $AzModuleOutPut -MemberType NoteProperty -Name CmdletName -Value $NULL
            # Add-Member -InputObject $AzModuleOutPut -MemberType NoteProperty -Name CmdletType -Value $NULL
            
            $ModuleName = $AzModule
            $ModuleVersion = ""
            $ReleaseDate = ""
            $CmdletName = ""
            $CmdletType = ""
            $AzVersion = ""

            $ModuleList = find-module $ModuleName -Repository PSgallery -AllVersions
            $CmdLetData = Get-Command -Module $ModuleName

            foreach ($item in $CmdLetData){
                $ModuleVersion = $ModuleList[0].Version
                $ReleaseDate = $ModuleList[0].PublishedDate
                $CmdletName = $item.Name
                $CmdletType = $item.CommandType
                $AzVersion = $item.Version

                $null = $AzModuleOutPut.Add("$ModuleName,$ModuleVersion,$ReleaseDate,$CmdletName,$CmdletType,$AzVersion")
            }
        }

        $designFile = 'AzModuleDesign.txt'
        $outFilePath = Join-Path $OutPath $designFile
        $AzModuleOutPut | Out-File -FilePath $outFilePath -Append -ErrorAction Stop

        Write-Host -ForegroundColor Green "Genereated $designFile completed in $OutPath. path."
        return
    }

    Get-AzModuleDataFunction -AzModuleData $DataOfAzModules

}
catch {
    throw
    return
}