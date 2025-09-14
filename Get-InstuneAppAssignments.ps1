#Requires -version 7.4 -Modules PSWriteHTML, Microsoft.Graph.Authentication, Microsoft.Graph.Beta.Devices.CorporateManagement, Microsoft.Graph.Devices.CorporateManagement 

#Graph connect if no session open.
Write-Host "Checking Graph connection and automatically connecting if no session is found."
if ($null -eq (Get-MgContext)) {Connect-MgGraph -ContextScope Process -Scopes DeviceManagementApps.Read.All}

Write-Host "Getting all Groups from Graph. Please wait as this might take some time."
#caching groups to use later as variable.
if ($null -eq $groups) {$groups = Get-MgGroup -All}

Write-Host "Getting all Intune Apps. Please wait. This may take some time."
$apps = Get-MgBetaDeviceAppManagementMobileApp -All
Write-Host "App list received."
$assignedapps = $apps| Select-Object Id,DisplayName,IsAssigned | Where-Object {$_.IsAssigned -eq 'True'}
Write-Host "$($assignedapps.count) / $($apps.Count) were assigned."

Write-Host "Starting to go through all assigned apps."
$a=0

$AssignmentsResult = $assignedapps | ForEach-Object {
    $a++
    Write-Progress "Gettings details of app number $($a)." -PercentComplete ([Int16](100*($a/$($assignedapps.Count))))
    $app = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $_.Id -ExpandProperty 'assignments'
    $count = ($app.Assignments).count
    for ($i = 0;$i -lt $count;$i++) {
        $app | Select-Object Id,DisplayName,@{Name="Scope";expression={if (($_.Assignments[$i].Id) -like "adadadad-808e-44e2-905a-0b7873a8a531*") {"All Devices"}elseif (($_.Assignments[$i].Id) -like "acacacac-9df4-4c7d-9d50-4ef0226f57a9*") {"All Users"}else{$AssignedGroupId = $_.Assignments[$i].Id;$AssignedGroupId = ($AssignedGroupId -replace '_[0-9]+_[0-9]+','');($groups | Where-Object {$_.Id -eq $AssignedGroupId}).DisplayName}}},@{Name="Intent";expression={($_.Assignments[$i].Intent)}},@{Name="Source";expression={($_.Assignments[$i].Source)}},@{Name="SourceId";expression={($_.Assignments[$i].SourceId)}}
    }
}
Write-Progress -PercentComplete 100 -Completed -Activity "Completed. Opening results to default browser."
$AssignmentsResult | Out-HtmlView
Write-Progress -PercentComplete 100 -Completed -Activity "Results opened to default browser."

