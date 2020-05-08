$allTestcaseFolders = Get-ChildItem -name
function getAnother([string] $FolderName)
{   
  $FolderName
    if($FolderName.Contains("json") -and !$FolderName.Contains("Async"))
  {
    $FolderNameAsync =$FolderName -replace ".json","Async.json"
    copy-item $FolderName $FolderNameAsync
  }else
  {
    cd $FolderName
    $allTestcase = Get-ChildItem -name
    ForEach($folderDetail in $allTestcase)
    {
      getAnother($folderDetail);
    }
    cd ..
  }
}
ForEach($folder in $allTestcaseFolders)
{
  getAnother($folder);
}