$currentFolder = Get-Location

$files = Get-ChildItem -Path $currentFolder -File

$destinationFolder = "$currentFolder\CopyFiles"
New-Item -ItemType Directory -Path $destinationFolder

foreach ($file in $files) {
    $newFileName = "$($file.BaseName).jpg"
    Copy-Item -Path $file.FullName -Destination "$destinationFolder\$newFileName"
}

Write-Output "Files copied to $destinationFolder with new names."