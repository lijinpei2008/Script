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

    $DataOfAzModules = (Get-Content -Path $Path)

    function Get-AzModuleDataFunction{
        param (
            $AzModuleData
        )

        $OutPutTitle = @("Module,CurrentVersion,AssemblyName,NumberOfCmdlets,NumberOfUpdatesIn2020,NumberOfUpdatesIn2021")
        $parameters = @{
         TypeName = 'System.Collections.Generic.HashSet[string]'
         ArgumentList = ([string[]]$OutPutTitle, [System.StringComparer]::OrdinalIgnoreCase)
        }
        $AzModuleOutPut = New-Object @parameters

        foreach ($AzModule in $AzModuleData){
            # $AzModuleOutPut = New-Object PSObject
            # Add-Member -InputObject $AzModuleOutPut -MemberType NoteProperty -Name Module -Value $NULL
            # Add-Member -InputObject $AzModuleOutPut -MemberType NoteProperty -Name CurrentVersion -Value $NULL
            # Add-Member -InputObject $AzModuleOutPut -MemberType NoteProperty -Name AssemblyName -Value $NULL
            # Add-Member -InputObject $AzModuleOutPut -MemberType NoteProperty -Name NumberOfCmdlets -Value $NULL
            # Add-Member -InputObject $AzModuleOutPut -MemberType NoteProperty -Name NumberOfUpdatesIn2020 -Value $NULL
            # Add-Member -InputObject $AzModuleOutPut -MemberType NoteProperty -Name NumberOfUpdatesIn2021 -Value $NULL
            
            $Name = $AzModule.Split(" ")[0]
            $CurrentVersion = $AzModule.Split(" ")[1]
            $AssemblyName = $AzModule.Split(" ")[2]

            $NumberOfCmdlets = (Get-Command -Module $Name).length
            # $NumberOfCmdlets = (Get-Command -Module $Name -CommandType Cmdlet,Function).length

            $NumberOfUpdatesIn2020 = 0
            $NumberOfUpdatesIn2021 = 0

            $ModuleList = find-module $Name -Repository PSgallery -AllVersions
            foreach ($item in $ModuleList){
                $PublishedDate = $item.PublishedDate.ToString("yyyyMMdd")
                if ("20200101" -le $PublishedDate -And $PublishedDate -le "20201231"){
                    $NumberOfUpdatesIn2020++
                }

                if ("20210101" -le $PublishedDate -And $PublishedDate -le "20211231"){
                    $NumberOfUpdatesIn2021++
                }
            }

            $null = $AzModuleOutPut.Add("$Name,$CurrentVersion,$AssemblyName,$NumberOfCmdlets,$NumberOfUpdatesIn2020,$NumberOfUpdatesIn2021")
        }

        $designFile = 'Az1Module.txt'
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