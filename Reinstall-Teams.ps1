# Check if the current session is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
Write-Error "Not running as Administrator. Please run the script with elevated privileges."
Exit
} else {
Write-Host "Running as Administrator."
}
$ConfirmPreference = $false
#Check process arch
if ([Environment]::Is64BitOperatingSystem  -ne $true){
    Write-Error "This script only support x86_64/64bit OS installs. 32bit/x86 systems are not supported"
    Exit
}
#Kill Teams if running
Get-Process ms-teams -ErrorAction:SilentlyContinue|Stop-Process -Force -Confirm:$false -ErrorAction:SilentlyContinue
#Uninstall Teams
Get-AppxPackage *MSTeams* -AllUsers|Remove-AppxPackage -AllUsers
$TeamsInstall = Get-ChildItem 'C:\Program Files\WindowsApps\*Teams*'
ForEach ($tobedeleted in $TeamsInstall) {
    takeown /R /A /F $tobedeleted.FullName
    Set-location $tobedeleted.FullName
    $NewAcl = Get-Acl -Path ".\"
    # Set properties
    $identity = "BUILTIN\Administrators"
    $fileSystemRights = "FullControl"
    $type = "Allow"
    # Create new rule
    $fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
    $fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
    # Apply new rule
    $NewAcl.SetAccessRule($fileSystemAccessRule)
    Set-Acl -Path ".\" -AclObject $NewAcl
    Get-ChildItem -Recurse | ForEach-Object {Set-Acl -Path $_.FullName -AclObject $NewAcl}
    Set-Location ..
    remove-item -Force -Recurse -Path $tobedeleted.FullName -Confirm:$false -ErrorAction:Continue
}
$TeamsTempInstall = "C:\temp\newteams.msix"
New-Item -ItemType Directory -Path C:\temp -ErrorAction:SilentlyContinue
Write-Host ""
C:\Windows\System32\curl.exe -L "https://go.microsoft.com/fwlink/?linkid=2196106" -o "$TeamsTempInstall"
Add-AppPackage -Path $TeamsTempInstall -Confirm:$false
Remove-Item $TeamsTempInstall -Confirm:$false