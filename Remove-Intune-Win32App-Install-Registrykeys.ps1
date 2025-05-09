﻿#	.NOTES
#	===========================================================================
#	 Created on:   	12/01/2025 01.49
#	 Modified on:	07/05/2025 20:58
#	 Filename:     	Remove Intune Win32App Install Registrykeys
#	 Version:		0.4.0
#	===========================================================================
#	.DESCRIPTION
#		A script to run manually on workstation that has had a failed deployment of win32 app after cleaning Intune cache.
#		Note that this script does nothing for the possible detection method that might or might not be in place already.
#Requires -Version 5.1

param (
	[Parameter(Mandatory=$false)]
	[string]$Id = $null
)

Clear-Host
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
{Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
Exit}

function Remove-Intune-Win32App-Install-Registrykeys {

$AppID = $null
$OperationalReg = $null
$InstalledReg = $null
$AppAuthorityReg = $null
$GRSHash = $null

$Win32AppsRegPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps"

if ($Id.Length -gt 15) {
	$AppID = $Id
}else{

$Question1Answer = Read-Host -Prompt "Read Intune AppId from Clipboard? Y/N"
If ($Question1Answer -eq "Y") {
	$AppIDCandinate = Get-Clipboard
	$Question2Answer = Read-Host "Read value $AppIDCandinate. Is that Correct? Y/N"
	if ($Question2Answer -eq "Y") {
		$AppID = $AppIDCandinate
	}else{
	Write-Host "Okay. Then input it below."
	$AppID = Read-Host -Prompt "Enter the Intune application ID of the app you want to clear from registy"
}
}else {
	Write-Host "Okay. Then input it below."
	$AppID = Read-Host -Prompt "Enter the Intune application ID of the app you want to clear from registy"
}
}

If ($AppID.Length -lt 15) {
	Write-Error "No Appid given!"
}else{

function DeleteReg ($List)
{
	foreach ($Item in $List)
	{
		Write-Host  "Removing registry path $($item.PsPath)"
		Remove-Item -Force -Recurse -Path $Item.PsPath -Confirm:$false
	}
}

function DeleteRegistryProperty ($PropertyList, $AppID)
{
	foreach ($Property in $PropertyList)
	{
		Write-Host  "Removing registry path $($Property.PsPath)"
		Remove-ItemProperty -Path $Property.PSPath -Name $AppID -Force -Confirm:$false
	}
}

Try
{
	$InstalledReg = (Get-Item $Win32AppsRegPath\*\$($AppID)_*\)
	if (($InstalledReg).count -gt 0)
	{
		DeleteReg -List $InstalledReg 
	}
	else
	{
		Write-Host -Object "No AppId $($AppID) found in registry under Win32Apps."
	}
	
	$OperationalReg = (Get-Item $Win32AppsRegPath\OperationalState\*\$($AppID)\)
	if (($OperationalReg).count -gt 0)
	{
		DeleteReg -List $OperationalReg 
	}
	else
	{
		Write-Host -Object "No AppId $($AppID) found in registry under Win32Apps\OperationalState."
	}
	
	$ReportingReg = Get-Item -Path $Win32AppsRegPath\Reporting\*\$($AppId)\
	if (($ReportingReg).count -gt 0)
	{
		DeleteReg  -List $ReportingReg 
	}
	else
	{
		Write-Host -Object "No AppId $($AppID) found in registry under Win32Apps\Reporting."
	}
	
	$AppAuthorityReg = Get-ItemProperty -Path $Win32AppsRegPath\Reporting\AppAuthority -Name $AppID -ErrorAction SilentlyContinue
	if ($null -ne ($AppAuthorityReg))
	{
		DeleteRegistryProperty -PropertyList $AppAuthorityReg -AppID $AppID
	}
	else
	{
		Write-Host -Object "No AppId $($AppID) found in registry under Win32Apps\Reporting\AppAuthority."
	}
	
	$GRSHash = (Get-ChildItem -Path $Win32AppsRegPath\*\Grs -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Property -eq $AppID })
	if ($null -ne $GRSHash)
	{
		DeleteReg -List $GrsHash 
	}
	else
	{
		Write-Host -Object "No value GRSHash found in registry under Win32Apps\*\GRS"
	}
}
catch
{
	"Something did not work correctly!"
}
finally
{
	$RestartPreference = Read-Host -Prompt "Do you want to start IntuneManagementExtension service on this workstation? (Y/N)"
	if ('Y', 'yes' -contains $RestartPreference)
	{
		Write-Host -Object "Restarting Intune Management Service"
		Restart-Service -Name IntuneManagementExtension -Force -Confirm:$false
	}
}
}
}

Remove-Intune-Win32App-Install-Registrykeys
