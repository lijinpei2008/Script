# 获取文件流
$item = Get-Content -Path .\track.txt

$lastNum = 0
$lastItem = ",,"
$valueItem = @()
$folderName = @{}

for($index=0; $index -lt $item.Length; $index++) {
    $datas = $item[$index].Split(',')

    $resourceProvider = $datas[0]
    $VersionType = $datas[1]
    $ApiVersionStr = $datas[2]
    $fileName = $datas[3]
    $canGenerate = $datas[4]
    $canBuild = $datas[5]

    $keyItem = $resourceProvider + "," + $VersionType + "," + $ApiVersionStr

    if ($lastItem.Contains($keyItem)) {
        $valueItem = ($lastNum, $index)

        $folderName.Remove($keyItem)

        $folderName.Add($keyItem, $valueItem)
    }
    else {
        $lastNum = $index
        $lastItem = $keyItem

        $valueItem = ($lastNum, $index)

        $folderName.Add($keyItem, $valueItem)
    }
}

$OutPutTitle = @("resourceProvider,VersionType,ApiVersionStr,fileName,CanGenerate,CanBuild")
$parameters = @{
    TypeName = 'System.Collections.Generic.HashSet[string]'
    ArgumentList = ([string[]]$OutPutTitle, [System.StringComparer]::OrdinalIgnoreCase)
}
$AzModuleOutPut = New-Object @parameters

for($index=0; $index -lt $item.Length; $index++) {
    cd C:\_AzureCode\Azure-TestPowershell\src

    $datas = $item[$index].Split(',')

    $resourceProvider = $datas[0]
    $VersionType = $datas[1]
    $ApiVersionStr = $datas[2]
   
    $fileNames = New-Object System.Collections.ArrayList
    $canGenerate = ""
    $canBuild = ""

    $keyItem = $resourceProvider + "," + $VersionType + "," + $ApiVersionStr
    $numArray = $folderName[$keyItem]


    # 在指定位置创建文件夹
    if (Test-Path C:\_AzureCode\Azure-TestPowershell\src\$keyItem){
        continue
    }

    Write-output "======================================================= Run $keyItem ======================================================="
    New-Item -Path ".\" -Name $keyItem -ItemType "directory"

    # 将resourceProvider 和 fileName替换到字符串中
    $outputString = ""
    $outputString += "### AutoRest Configuration `n"
    $outputString += "> see https://aka.ms/autorest `n`n"

    $outputString += "`````` yaml `n"
    $outputString += "branch: main `n"
    $outputString += "require: `n"
    $outputString += "  - `$(this-folder)/../readme.azure.noprofile.md `n"
    $outputString += "input-file: `n"
  
    for($n = $numArray[0]; $n -le $numArray[1]; $n++){
        $fileName = $item[$n].Split(',')[3]
        $outputString += "  - `$(repo)${fileName} `n`n"
        $fileNames.Add("${fileName}")
    }

    $outputString += "title: ${resourceProvider} `n"
    $outputString += "module-version: 0.1.0 `n"
    $outputString += "subject-prefix: `$(service-name) `n"
    $outputString += "identity-correction-for-post: true `n"
    $outputString += "`````` "


    # 写入到README.md中
    New-Item -Path ".\$keyItem" -Name "README.md" -ItemType "file" -Value $outputString

    # 运行命令 autorest
    Write-output "======================================================= Run autorest ======================================================="
    cd C:\_AzureCode\Azure-TestPowershell\src\$keyItem
    autorest.ps1
    if ($LASTEXITCODE -eq 1){
        $canGenerate = "No"
    }
    else{
        $canGenerate = "Yes"
    }

    # 运行命令 .\build-module.ps1
    Write-output "============================================ Run build ======================================================="
    .\build-module.ps1

    if ($LastExitCode -eq 1){
        $canBuild = "No"
    }
    else{
        $canBuild = "Yes"
    }

    foreach($fileName in $fileNames){
        $null = $AzModuleOutPut.Add("$resourceProvider,$VersionType,$ApiVersionStr,$fileName,$canGenerate,$canBuild")
    }
}

$designFile = 'new-track.txt'
$outFilePath = Join-Path "C:\_AzureCode" $designFile
$AzModuleOutPut | Out-File -FilePath $outFilePath -Append -ErrorAction Stop