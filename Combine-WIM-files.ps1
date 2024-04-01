$location = Get-Location
$ParentLocation =  Split-Path -Path $location -Parent
$resultFilename = "install.wim"
$ResultFilePath = $ParentLocation+"\"+$resultFilename
Write-Progress -Activity "Reading WIM files"
$Wims = Get-ChildItem "*.wim"
$endresult = @()
ForEach ($WimFile in $Wims) {
    $ImageFileInfos = $null
    $ImageFileInfos = Get-WindowsImage -ImagePath $WimFile.FullName
    $ExpandedWIMinfo = @() 
    ForEach ($ImageInfo in $ImageFileInfos) {
        $row = [pscustomobject]@{
            WimFilePath = $WimFile.FullName
            WimIndex = $ImageInfo.ImageIndex
            ImageName = $ImageInfo.ImageName
            ImageDescription = $ImageInfo.ImageDescription
        }
        $ExpandedWIMinfo += $row
    }
    $endresult += $ExpandedWIMinfo
}

Write-Progress -Activity "Wim files read. Starting combine process."
$imagecount = $endresult.Count
$index = 0
foreach ($InstallImage in $endresult) {
    $index = $index + 1
    Write-Progress -PercentComplete ($index/$imagecount) -Activity "Working on image $index of $imagecount"
    Start-Sleep -Milliseconds 2000
    Export-WindowsImage -SourceImagePath $InstallImage.WimFilePath -SourceIndex $InstallImage.ImageIndex -DestinationImagePath $ResultFilePath -DestinationName $InstallImage.ImageName
}
[console]::beep(2000,500)