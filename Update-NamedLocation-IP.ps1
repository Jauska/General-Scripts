#Requires -Modules Microsoft.Graph.Authentication; Microsoft.Graph.Identity.SignIns -PSEdition Desktop -Version 7.4

$TenantId = ""
$ClientId = ""
$CertificateThumbprint = ""
$DDNS_named_locationname = ""

Connect-MgGraph -TenantId:$TenantId -ClientId:$ClientId -CertificateThumbprint:$CertificateThumbprint 

$WantedNamedLocation = Get-MgIdentityConditionalAccessNamedLocation -Filter:"(DisplayName eq '$DDNS_named_locationname')"
$LocalPublicIP = (curl -s https://ip.hetzner.com)
$params = @{
	"@odata.type" = "#microsoft.graph.ipNamedLocation"
	DisplayName = "$DDNS_named_locationname"
    isTrusted = $true
    }
	$IpRanges = @{}
    $params.Add("IpRanges",@())
    $IpRanges.add("@odata.type", "#microsoft.graph.iPv4CidrRange")
    $IpRanges.add("CidrAddress", "$LocalPublicIP/32")
    $params.IpRanges += $IpRanges
Update-MgIdentityConditionalAccessNamedLocation -NamedLocationId $WantedNamedLocation.Id -BodyParameter $params
Disconnect-MgGraph