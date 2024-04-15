$ParentPath = $env:LOCALAPPDATA
$foldername = "testiappi"
$configfiletoedit = "settings_.dat"
$KillProcess = "notepad.exe"
$FullSearchPath = $ParentPath+"\"+$foldername
$FullSearchPathExists = Test-Path -Path $FullSearchPath
if ($FullSearchPathExists -ne $true) {
    exit 1
}
If (((Get-Process).ProcessName -contains $KillProcess)) {
    Stop-Process -Name $KillProcess -Force -Confirm:$false
}
$FilesToBeEdited = Get-ChildItem -Path $FullSearchPath -Recurse -Filter $configfiletoedit
$FilesToBeEdited.FullName
ForEach ($FileToEdit in $FilesToBeEdited) {
    $FileContent = Get-Content -Path $FileToEdit.FullName
    $FileBackup = $FileToEdit.FullName+".old"
    Move-Item -Path $FileToEdit.FullName -Destination $FileBackup
    $FileContent = $FileContent.Replace("ServerAddress=server1.jotain.com","ServerAddress=serverUUSI1.jotain.com")
    $FileContent = $FileContent.Replace("ServerAddress=server2.jotain.com","ServerAddress=serverUUSI2.jotain.com")
    $FileContent = $FileContent.Replace("ServerAddress=server3.jotain.com","ServerAddress=serverUUSI3.jotain.com")
    $FileContent = $FileContent.Replace("ServerAddress=server4.jotain.com","ServerAddress=serverUUSI4.jotain.com")
    Out-File -FilePath $FileToEdit.FullName -Encoding utf8 -InputObject $FileContent
}