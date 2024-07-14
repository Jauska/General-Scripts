try {
    $Errors = 
    Start-Transcript -Path "C:\Windows\Logs\Windows-FeaturesCheck.log"
    $ToBeInstalled = "TelnetClient,TFTP,SimpleTCP,NetFx3"
    $InstallFeatures = $ToBeInstalled.Split(",")
    $ToBeRemoved = "WorkFolders-Client"
    $RemoveFeatures = $ToBeRemoved.Split(",")
    $CurrentState = Get-WindowsOptionalFeature -Online 
    $Result = 0

    ForEach ($FeatureName in $InstallFeatures) {
        if (($CurrentState | Where-Object -Property "FeatureName" -eq -Value $FeatureName).State -eq "Enabled") {
            Write-Host "Feature $($FeatureName) already installed."
        } else {
            Write-Host "Feature $($FeatureName) not installed."
            $Result++

        }
    }
    ForEach ($RFeatureName in $RemoveFeatures) {
        if (($CurrentState | Where-Object -Property "FeatureName" -eq -Value $RFeatureName).State -eq "Disabled") {
            Write-Host "Feature $($RFeatureName) already uninstalled."
        } elseif (($CurrentState | Where-Object -Property "FeatureName" -eq -Value $RFeatureName).State -eq "Enabled") {
            Write-Host "Feature $($RFeatureName) not uninstalled."
            $Result++
        }
    }

}
catch {
    Write-Host "Installation failure! please see error below!"
    $Errors
}
finally {
    Stop-Transcript
    if ($Result -eq 0) {
        exit 0
    }else{
        exit 1
    }
}