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

    Get-Date

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

    Write-Host -ForegroundColor Green "The file has $itemLin elements"

    for ($index = 2; $index -le $itemLin; $index++) {
        # Need use Col of 2B, 4D, 6F
        $dataB = $Sheet.Cells.Item($index, 2).Text
        $dataD = $Sheet.Cells.Item($index, 4).Text
        $dataF = $Sheet.Cells.Item($index, 6).Text

        $absoluteValue1 = [Math]::Abs($dataB - $dataD)
        $absoluteValue2 = [Math]::Abs($dataB - $dataF)
        $absoluteValue3 = [Math]::Abs($dataD - $dataF)

        if ($absoluteValue1 -le $absoluteValue2 -and $absoluteValue1 -le $absoluteValue3) {
            $dataF = (@($dataB, $dataD) | Measure-Object -Average).Average
            $dataF = [Math]::Ceiling($dataF)
        }
        elseif ($absoluteValue2 -le $absoluteValue1 -and $absoluteValue2 -le $absoluteValue3) {
            $dataD = (@($dataB, $dataF) | Measure-Object -Average).Average
            $dataD = [Math]::Ceiling($dataD)
        }
        elseif ($absoluteValue3 -le $absoluteValue1 -and $absoluteValue3 -le $absoluteValue2) {
            $dataB = (@($dataD, $dataF) | Measure-Object -Average).Average
            $dataB = [Math]::Ceiling($dataB)
        }
     
        $Sheet.Cells.Item($index, 2) = $dataB
        $Sheet.Cells.Item($index, 4) = $dataD
        $Sheet.Cells.Item($index, 6) = $dataF

        # Need use Col of 8H, 10J, 12L
        $dataH = $Sheet.Cells.Item($index, 8).Text
        $dataJ = $Sheet.Cells.Item($index, 10).Text
        $dataL = $Sheet.Cells.Item($index, 12).Text

        $absoluteValue1 = [Math]::Abs($dataH - $dataJ)
        $absoluteValue2 = [Math]::Abs($dataH - $dataL)
        $absoluteValue3 = [Math]::Abs($dataJ - $dataL)

        if ($absoluteValue1 -le $absoluteValue2 -and $absoluteValue1 -le $absoluteValue3) {
            $dataL = (@($dataH, $dataJ) | Measure-Object -Average).Average
            $dataL = [Math]::Ceiling($dataL)
        }
        elseif ($absoluteValue2 -le $absoluteValue1 -and $absoluteValue2 -le $absoluteValue3) {
            $dataJ = (@($dataH, $dataL) | Measure-Object -Average).Average
            $dataJ = [Math]::Ceiling($dataJ)
        }
        elseif ($absoluteValue3 -le $absoluteValue1 -and $absoluteValue3 -le $absoluteValue2) {
            $dataH = (@($dataJ, $dataL) | Measure-Object -Average).Average
            $dataH = [Math]::Ceiling($dataH)
        }
     
        $Sheet.Cells.Item($index, 8) = $dataH
        $Sheet.Cells.Item($index, 10) = $dataJ
        $Sheet.Cells.Item($index, 12) = $dataL
    }

    # Out file path
    $conversionFile = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss") + ".xlsx"
    $outFilePath = Join-Path $PSScriptRoot $conversionFile
    $Workbook.SaveAs($outFilePath)
    $Excel.Quit()

    Write-Host -ForegroundColor Green "Genereated $conversionFile completed in $outFilePath path."
    Get-Date
    return
}
catch {
    throw
    return
}
