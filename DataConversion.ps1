[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, HelpMessage = "The current path as the value of the path parameter if not passed Path parameter.")]
    [string]
    $Path,

    [Parameter(Mandatory = $false, HelpMessage = "The Path parameter and the OutPath parameter are the same if not passed OutPath parameter.")]
    [string]
    $OutPath
)

try {
    # If the path parameter is null, let the current path as the value of the path parameter
    if (!$PSBoundParameters.ContainsKey("Path")) {
        $Path = $PSScriptRoot
    }
    if (!$PSBoundParameters.ContainsKey("OutPath")) {
        $OutPath = $Path
    }

    # Open Excel App
    $Excel = New-Object -ComObject Excel.Application
    $Excel.Visible = $false
    $Excel.DisplayAlerts = $true

    # Open Excel File
    $Workbook = $Excel.Workbooks.Open($Path)

    # Open was named 'expression' sheet table
    $Sheet = $Workbook.Worksheets.Item('expression')

    # Have Excel Lines number
    $itemLin = $Sheet.UsedRange.Rows.Count
    # Have Excel Column number
    # $itemCol = $Sheet.UsedRange.Columns.Count
    
    for ($index = 2; $index -le $itemLin; $index++) {
        # Need use Col of 3C,5E,7G
        $dataC = $Sheet.Cells.Item($index, 3).Text
        $dataE = $Sheet.Cells.Item($index, 5).Text
        $dataG = $Sheet.Cells.Item($index, 7).Text

        $absoluteValue1 = [Math]::Abs($dataC - $dataE)
        $absoluteValue2 = [Math]::Abs($dataC - $dataG)
        $absoluteValue3 = [Math]::Abs($dataE - $dataG)

        if ($absoluteValue1 -le $absoluteValue2 -and $absoluteValue1 -le $absoluteValue3) {
            $dataG = (@($dataC, $dataE) | Measure-Object -Average).Average
        }
        elseif ($absoluteValue2 -le $absoluteValue1 -and $absoluteValue2 -le $absoluteValue3) {
            $dataE = (@($dataC, $dataG) | Measure-Object -Average).Average
        }
        elseif ($absoluteValue3 -le $absoluteValue1 -and $absoluteValue3 -le $absoluteValue2) {
            $dataC = (@($dataE, $dataG) | Measure-Object -Average).Average
        }
     
        $Sheet.Cells.Item($index, 3) = $dataC
        $Sheet.Cells.Item($index, 5) = $dataE
        $Sheet.Cells.Item($index, 7) = $dataG

        # Need use Col of 9I,11K,13M
        $dataI = $Sheet.Cells.Item($index, 9).Text
        $dataK = $Sheet.Cells.Item($index, 11).Text
        $dataM = $Sheet.Cells.Item($index, 13).Text

        $absoluteValue1 = [Math]::Abs($dataI - $dataK)
        $absoluteValue2 = [Math]::Abs($dataI - $dataM)
        $absoluteValue3 = [Math]::Abs($dataK - $dataM)

        if ($absoluteValue1 -le $absoluteValue2 -and $absoluteValue1 -le $absoluteValue3) {
            $dataM = (@($dataI, $dataK) | Measure-Object -Average).Average
        }
        elseif ($absoluteValue2 -le $absoluteValue1 -and $absoluteValue2 -le $absoluteValue3) {
            $dataK = (@($dataI, $dataM) | Measure-Object -Average).Average
        }
        elseif ($absoluteValue3 -le $absoluteValue1 -and $absoluteValue3 -le $absoluteValue2) {
            $dataI = (@($dataK, $dataM) | Measure-Object -Average).Average
        }
     
        $Sheet.Cells.Item($index, 9) = $dataI
        $Sheet.Cells.Item($index, 11) = $dataK
        $Sheet.Cells.Item($index, 13) = $dataM
    }

    # Out file path
    $conversionFile = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss") + ".xlsx"
    $outFilePath = Join-Path $PSScriptRoot $conversionFile
    $Workbook.SaveAs($outFilePath)
    $Excel.Quit()

    Write-Host -ForegroundColor Green "Genereated $conversionFile completed in $outFilePath path."
    return
}
catch {
    throw
    return
}
