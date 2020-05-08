#requires -version 2.0

[cmdletbinding()]

$file="c:\TrackV2Validation.xlsx"

function AutoTextFunction($path){
    $Obj = "what"| Select-Object -Property HasSpecConfiguration,Generate,Build
    $mainpath= 'C:\AME\azure-sdk-for-net\sdk'
    cd $mainpath
    #get current path from excel
    $currentpath= $path
    $loadEnvPath
    cd $currentpath
    $fileList =ls -Name
    foreach($file in $fileList)
    {
       if($file.startswith('Azure.Management'))
        {
            $loadEnvPath= $file + '\src'
            break
        }
    }
    #then comfirm the path
    if (-Not (Test-Path -Path $loadEnvPath)) {
        #obj can not be find,end
        $Obj.HasSpecConfiguration="NO"
        cd ../../..
    }else
    {
        #obj can be find,continue
        $Obj.HasSpecConfiguration="YES"
        #enter the foldfile
        cd $loadEnvPath
        $generateString = dotnet msbuild /t:GenerateCode |Out-string
        $isGenSuccess = $generateString.contains("EXEC : error") -or $generateString.contains("): error")
        #if not exist then continue 'build'
        if(!$isGenSuccess)
        {
            #write 'Yes' in line 'Generated' of excel
            $Obj.Generate="YES"
            #run 'dotnet msbuild'
            dotnet restore
            $buildString = dotnet msbuild |Out-string
            $isBuildSuccess = $buildString.contains("): error")
            #if not exist then write 'Yes' in line 'Generated' of excel
            if(!$isBuildSuccess)
            {
                #write 'Yes' in line 'Build' of excel
                $Obj.Build="YES"
            }else
            {
                #write 'NO' in line 'Build' of excel
                $Obj.Build="NO"
                dotnet msbuild > C:\AME\ErrorLogs\$currentpath-Build.log
            }
        }else
        {
             #write 'NO' in line 'Generated' of excel
            $Obj.Generate="NO"
            #log
            dotnet msbuild /t:GenerateCode > C:\AME\ErrorLogs\$currentpath-generate.log
        }
        cd ../../../../../..
    }
    return $Obj
}

#excel软件本身
$Excel=New-Object -ComObject "Excel.Application" 
#打开excel文件
$Workbook=$Excel.Workbooks.Open($file)
#选中工作表
$Sheet = $Workbook.Worksheets.Item('generator-v0326')
#添加工作表并重命名为当前日期
$newSheet = $Workbook.Worksheets.Add()
$newSheet.Name = "generator-v$(Get-date -Format 'MMdd')"
#初始化第一行
$newSheet.Cells.Item(1,1) = 'Service Name'
$newSheet.Cells.Item(1,2) = 'Has Spec Configuration'
$newSheet.Cells.Item(1,3) = 'Can Generate'
$newSheet.Cells.Item(1,4) = 'Can Build'
#excel是否可见
$Excel.visible=$true
#excel内容变更时，警告是否可见
$Excel.displayAlerts=$true

$Row=2

$hasSpecConfiguration=$Null
$generateMessage=$Null
$buildMessage=$Null

do {
  #循环获取A2~A100单元格的内容
  $serviceName=$Sheet.Range("A$Row").Text

  if ($serviceName) {
    #调用方法，获取执行结果返回值
    $message = "what"| Select-Object -Property HasSpecConfiguration,Generate,Build
    $message = AutoTextFunction($serviceName)
    
    if($message.HasSpecConfiguration){
      $hasSpecConfiguration=$message.HasSpecConfiguration
    }else{
      $hasSpecConfiguration=$Null
    }

    if($message.Generate){
      $generateMessage=$message.Generate
    }else{
      $generateMessage=$Null
    }

    if($message.Build){
      $buildMessage=$message.Build
    }
    else{
      $buildMessage=$Null
    }

    #添加serviceName
    $newSheet.Cells.Item($Row,1) = $serviceName

    #修改单元格B2~B101的内容
    $newSheet.Cells.Item($Row,2) = $hasSpecConfiguration

    #修改单元格C2~C101的内容
    $newSheet.Cells.Item($Row,3) = $generateMessage
    #如果$generateMessage的值是no，则改变单元格颜色为 红
    if($generateMessage -eq "NO"){
      $newSheet.cells.item($Row,3).Interior.ColorIndex = 3
    }

    #修改单元格D2~D101的内容
    $newSheet.Cells.Item($Row,4) = $buildMessage
    #如果$buildMessage的值是no，则改变单元格颜色为 黄
    if($buildMessage -eq "NO"){
      $newSheet.cells.item($Row,4).Interior.ColorIndex = 6
    }
  }
  $Row++
} While ($Row -le 101)

$Workbook.Close()
$Excel.Quit()

Write-Verbose "Finished"