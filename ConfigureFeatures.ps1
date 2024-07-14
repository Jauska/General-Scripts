try {
    $Errors = 
    Start-Transcript -Path "C:\Windows\Logs\Windows-Features.log"
    $ToBeInstalled = "TelnetClient,TFTP,SimpleTCP,NetFx3"
    $InstallFeatures = $ToBeInstalled.Split(",")
    $ToBeRemoved = "WorkFolders-Client"
    $RemoveFeatures = $ToBeRemoved.Split(",")
    $CurrentState = Get-WindowsOptionalFeature -Online 

    #Installing features
    ForEach ($FeatureName in $InstallFeatures) {
        if (($CurrentState | Where-Object -Property "FeatureName" -eq -Value $FeatureName).State -eq "Disabled") {
            Write-Host "Installing $($FeatureName)"
            Enable-WindowsOptionalFeature -FeatureName $FeatureName -Online -NoRestart -ErrorAction Continue -ErrorVariable Errors
        } elseif (($CurrentState | Where-Object -Property "FeatureName" -eq -Value $FeatureName).State -eq "Enabled") {
            Write-Host "Feature $($FeatureName) already installed."
        } else {
            Write-Host "While installing $($FeatureName) got unknown installstate. WTF?"
        }
    }

    #Removing features
    ForEach ($RFeatureName in $RemoveFeatures) {
        if (($CurrentState | Where-Object -Property "FeatureName" -eq -Value $RFeatureName).State -eq "Disabled") {
            Write-Host "Feature $($RFeatureName) already uninstalled."
        } elseif (($CurrentState | Where-Object -Property "FeatureName" -eq -Value $RFeatureName).State -eq "Enabled") {
            Write-Host "Removing $($RFeatureName)"
            Disable-WindowsOptionalFeature -FeatureName $RFeatureName -Online -NoRestart -ErrorAction Continue -ErrorVariable Errors
        } else {
            Write-Host "While uninstalling $($RFeatureName) got unknown installstate. WTF?"
        }
    }

}
catch {
    Write-Host "Installation failure! please see error below!"
    $Errors
}
finally {
    Stop-Transcript
}