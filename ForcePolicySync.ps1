#Requires -Version 5.1 -psedition Desktop
[Windows.Management.MdmSessionManager,Windows.Management,ContentType=WindowsRuntime]
$session = [Windows.Management.MdmSessionManager]::TryCreateSession()
$session.StartAsync()